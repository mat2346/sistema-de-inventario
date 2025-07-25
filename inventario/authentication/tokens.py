# authentication/tokens.py
from rest_framework_simplejwt.tokens import RefreshToken
from empleados.models import Empleado

class EmpleadoRefreshToken(RefreshToken):
    @classmethod
    def for_empleado(cls, empleado):
        """
        Crear token JWT personalizado para empleados
        """
        token = cls()
        token['empleado_id'] = empleado.id
        token['nombre'] = empleado.get_full_name()
        token['cargo'] = empleado.cargo
        token['sucursal_id'] = empleado.sucursal.id if empleado.sucursal else None
        token['sucursal_nombre'] = empleado.sucursal.nombre if empleado.sucursal else None
        token['correo'] = empleado.correo  # Cambiado de 'email' a 'correo'
        return token
