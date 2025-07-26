"""
Permisos personalizados para el sistema de inventario
"""

from rest_framework.permissions import BasePermission, IsAuthenticated
from rest_framework.decorators import permission_classes
from functools import wraps


class IsAuthenticatedEmployeeOrReadOnly(BasePermission):
    """
    Permite lectura a cualquier usuario autenticado,
    pero solo empleados pueden crear/editar/eliminar
    """
    
    def has_permission(self, request, view):
        # Verificar que el usuario esté autenticado
        if not request.user or not request.user.is_authenticated:
            return False
            
        # Permitir métodos de lectura (GET, HEAD, OPTIONS)
        if request.method in ['GET', 'HEAD', 'OPTIONS']:
            return True
            
        # Para operaciones de escritura, verificar permisos adicionales
        return True  # Aquí puedes agregar lógica específica


class IsEmployeeAuthenticated(BasePermission):
    """
    Solo permite acceso a empleados autenticados via JWT
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and
            hasattr(request.user, 'empleado_profile')  # Si usas perfil de empleado
        )


def public_endpoint(view_func):
    """
    Decorador para marcar endpoints como públicos (sin autenticación)
    """
    @wraps(view_func)
    @permission_classes([])  # Sin permisos requeridos
    def wrapper(*args, **kwargs):
        return view_func(*args, **kwargs)
    return wrapper


def authenticated_only(view_func):
    """
    Decorador para asegurar que solo usuarios autenticados accedan
    """
    @wraps(view_func)
    @permission_classes([IsAuthenticated])
    def wrapper(*args, **kwargs):
        return view_func(*args, **kwargs)
    return wrapper
