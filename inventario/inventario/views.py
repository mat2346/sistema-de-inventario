from django.http import JsonResponse
from django.urls import reverse

def api_root(request):
    """Vista para mostrar todos los endpoints disponibles"""
    api_urls = {
        'sucursales': request.build_absolute_uri('/api/sucursales/'),
        'categorias': request.build_absolute_uri('/api/categorias/'),
        'productos': request.build_absolute_uri('/api/productos/'),
        'proveedores': request.build_absolute_uri('/api/proveedores/'),
        'empleados': request.build_absolute_uri('/api/empleados/'),
        'inventario': request.build_absolute_uri('/api/inventario/'),
        'entradas': request.build_absolute_uri('/api/entradas/'),
        'salidas': request.build_absolute_uri('/api/salidas/'),
        'admin': request.build_absolute_uri('/admin/'),
        'api_auth': request.build_absolute_uri('/api-auth/'),
    }
    
    auth_endpoints = {
        'login': request.build_absolute_uri('/api/auth/login/'),
        'logout': request.build_absolute_uri('/api/auth/logout/'),
        'session': request.build_absolute_uri('/api/auth/session/'),
        'status': request.build_absolute_uri('/api/auth/status/'),
    }
    
    special_endpoints = {
        'inventario_bajo_stock': request.build_absolute_uri('/api/inventario/bajo_stock/'),
        'inventario_sin_stock': request.build_absolute_uri('/api/inventario/sin_stock/'),
    }
    
    return JsonResponse({
        'message': 'API de Sistema de Inventario',
        'version': '1.0',
        'endpoints': api_urls,
        'authentication': auth_endpoints,
        'special_endpoints': special_endpoints,
        'instructions': {
            'login': 'POST a /api/auth/login/ con {"nombre": "nombre_empleado", "password": "contraseña"}',
            'logout': 'POST a /api/auth/logout/',
            'check_session': 'GET a /api/auth/session/ para verificar sesión actual'
        }
    })
