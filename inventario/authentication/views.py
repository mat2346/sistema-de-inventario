from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import login, logout
from django.http import JsonResponse
from .serializers import EmpleadoLoginSerializer, EmpleadoSessionSerializer
from .tokens import EmpleadoRefreshToken
from empleados.models import Empleado

@api_view(['POST', 'GET'])
@permission_classes([AllowAny])
def empleado_login(request):
    """
    Login para empleados usando nombre y contraseña con JWT
    """
    if request.method == 'GET':
        return Response({
            'detail': 'Endpoint de login activo. Use POST con {"nombre": "usuario", "password": "contraseña"}',
            'method_required': 'POST',
            'expected_data': {
                'nombre': 'admin o vendedor',
                'password': '123456'
            },
            'test_usuarios': [
                {'nombre': 'admin', 'cargo': 'Administrador'},
                {'nombre': 'vendedor', 'cargo': 'Vendedor'}
            ]
        }, status=status.HTTP_200_OK)
    
    serializer = EmpleadoLoginSerializer(data=request.data)
    
    if serializer.is_valid():
        empleado = serializer.validated_data['empleado']
        
        # Generar tokens JWT
        refresh = EmpleadoRefreshToken.for_empleado(empleado)
        access_token = refresh.access_token
        
        # También mantener sesión para compatibilidad
        request.session['empleado_id'] = empleado.id
        request.session['empleado_nombre'] = empleado.get_full_name()
        request.session['empleado_cargo'] = empleado.cargo
        request.session['sucursal_id'] = empleado.sucursal.id if empleado.sucursal else None
        request.session['sucursal_nombre'] = empleado.sucursal.nombre if empleado.sucursal else None
        
        # Serializar datos del empleado
        empleado_data = EmpleadoSessionSerializer(empleado).data
        
        return Response({
            'authenticated': True,
            'message': f'Bienvenido {empleado.get_full_name()}',
            'empleado': empleado_data,
            'tokens': {
                'access': str(access_token),
                'refresh': str(refresh),
            },
            'session_key': request.session.session_key  # Para compatibilidad
        }, status=status.HTTP_200_OK)
    
    return Response({
        'authenticated': False,
        'message': 'Nombre o contraseña incorrectos',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def empleado_logout(request):
    """
    Logout para empleados con JWT
    """
    try:
        refresh_token = request.data.get("refresh_token")
        if refresh_token:
            token = RefreshToken(refresh_token)
            token.blacklist()
        
        # Limpiar sesión también para compatibilidad
        if 'empleado_id' in request.session:
            empleado_nombre = request.session.get('empleado_nombre', 'Usuario')
            request.session.flush()  # Elimina toda la sesión
            
            return Response({
                'authenticated': False,
                'message': f'Hasta luego {empleado_nombre}'
            }, status=status.HTTP_200_OK)
        
        return Response({
            'authenticated': False,
            'message': 'Sesión cerrada exitosamente'
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'error': 'Error al cerrar sesión',
            'detail': str(e)
        }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def empleado_session(request):
    """
    Obtener información de la sesión JWT actual
    """
    # Intentar obtener empleado del token JWT
    if hasattr(request, 'auth') and request.auth:
        try:
            empleado_id = request.auth.payload.get('empleado_id')
            if empleado_id:
                empleado = Empleado.objects.get(id=empleado_id, is_active=True)
                empleado_data = EmpleadoSessionSerializer(empleado).data
                
                return Response({
                    'authenticated': True,
                    'empleado': empleado_data,
                    'token_info': {
                        'empleado_id': empleado_id,
                        'cargo': request.auth.payload.get('cargo'),
                        'sucursal_id': request.auth.payload.get('sucursal_id'),
                        'sucursal_nombre': request.auth.payload.get('sucursal_nombre'),
                    }
                }, status=status.HTTP_200_OK)
        except Empleado.DoesNotExist:
            return Response({
                'authenticated': False,
                'message': 'Empleado no encontrado'
            }, status=status.HTTP_404_NOT_FOUND)
    
    # Fallback a sesión tradicional para compatibilidad
    if 'empleado_id' in request.session:
        try:
            empleado = Empleado.objects.get(
                id=request.session['empleado_id'],
                is_active=True
            )
            empleado_data = EmpleadoSessionSerializer(empleado).data
            
            return Response({
                'authenticated': True,
                'empleado': empleado_data,
                'session_info': {
                    'session_key': request.session.session_key,
                    'cargo': request.session.get('empleado_cargo'),
                    'sucursal_id': request.session.get('sucursal_id'),
                    'sucursal_nombre': request.session.get('sucursal_nombre'),
                }
            }, status=status.HTTP_200_OK)
            
        except Empleado.DoesNotExist:
            # Limpiar sesión inválida
            request.session.flush()
            return Response({
                'authenticated': False,
                'message': 'Empleado no encontrado'
            }, status=status.HTTP_404_NOT_FOUND)
    
    return Response({
        'authenticated': False,
        'message': 'No hay sesión activa'
    }, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['POST'])
@permission_classes([AllowAny])
def token_refresh(request):
    """
    Refrescar token JWT
    """
    try:
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return Response({
                'error': 'Token de refresh requerido'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        refresh = RefreshToken(refresh_token)
        access_token = refresh.access_token
        
        return Response({
            'access': str(access_token),
            'refresh': str(refresh)
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'error': 'Token inválido o expirado',
            'detail': str(e)
        }, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['GET'])
@permission_classes([AllowAny])
def check_auth_status(request):
    """
    Verificar estado de autenticación (público)
    """
    if 'empleado_id' in request.session:
        return Response({
            'authenticated': True,
            'empleado_nombre': request.session.get('empleado_nombre'),
            'cargo': request.session.get('empleado_cargo'),
            'sucursal': request.session.get('sucursal_nombre')
        })
    
    return Response({
        'authenticated': False
    })

@api_view(['POST', 'GET'])
@permission_classes([AllowAny])
def test_login(request):
    """
    Endpoint de testing para login rápido
    """
    if request.method == 'GET':
        return Response({
            'message': 'Endpoint de testing activo',
            'test_users': [
                {'nombre': 'admin', 'password': '123456', 'cargo': 'Administrador'},
                {'nombre': 'vendedor', 'password': '123456', 'cargo': 'Vendedor'}
            ],
            'how_to_test': 'POST {"nombre": "admin", "password": "123456"}'
        })
    
    # Login automático con admin para testing
    try:
        empleado = Empleado.objects.get(nombre='admin', is_active=True)
        
        # Crear sesión
        request.session['empleado_id'] = empleado.id
        request.session['empleado_nombre'] = empleado.get_full_name()
        request.session['empleado_cargo'] = empleado.cargo
        
        return Response({
            'authenticated': True,
            'message': 'Login de testing exitoso',
            'empleado': {
                'id': empleado.id,
                'nombre': empleado.nombre,
                'cargo': empleado.cargo
            }
        })
    except Empleado.DoesNotExist:
        return Response({
            'error': 'Usuario admin no encontrado. Ejecutar: python manage.py crear_empleados'
        }, status=400)
