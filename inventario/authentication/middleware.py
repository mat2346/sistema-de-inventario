"""
Middleware personalizado para manejar autenticación
"""

from django.http import JsonResponse
from rest_framework import status
import logging

logger = logging.getLogger(__name__)

class AuthenticationDebugMiddleware:
    """
    Middleware para debuggear problemas de autenticación
    """
    
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Log para ver qué headers de autorización llegan
        auth_header = request.META.get('HTTP_AUTHORIZATION')
        if auth_header:
            logger.info(f"Authorization header present: {auth_header[:20]}...")
        
        # Log para endpoints que requieren autenticación
        if request.path.startswith('/api/') and not request.path.startswith('/api/auth/'):
            if not auth_header:
                logger.warning(f"No auth header for protected endpoint: {request.path}")
        
        response = self.get_response(request)
        return response


class PublicEndpointMiddleware:
    """
    Middleware para permitir endpoints públicos específicos
    """
    
    PUBLIC_ENDPOINTS = [
        '/api/auth/login/',
        '/api/auth/test/',
        '/api/auth/status/',
        '/admin/',
        '/',
        '/api/',
    ]
    
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Verificar si es un endpoint público
        if any(request.path.startswith(endpoint) for endpoint in self.PUBLIC_ENDPOINTS):
            # Agregar header para identificar endpoint público
            request.META['IS_PUBLIC_ENDPOINT'] = True
        
        response = self.get_response(request)
        return response
