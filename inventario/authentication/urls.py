from django.urls import path
from .views import (
    empleado_login, 
    empleado_logout, 
    empleado_session, 
    check_auth_status,
    test_login,
    token_refresh
)

urlpatterns = [
    # Sistema de autenticación con JWT para empleados
    path('api/auth/login/', empleado_login, name='empleado-login'),
    path('api/auth/logout/', empleado_logout, name='empleado-logout'),
    path('api/auth/session/', empleado_session, name='empleado-session'),
    path('api/auth/refresh/', token_refresh, name='token-refresh'),
    path('api/auth/status/', check_auth_status, name='auth-status'),
    path('api/auth/test/', test_login, name='test-login'),  # Endpoint de testing
]
