from rest_framework import serializers
from django.contrib.auth import authenticate
from empleados.models import Empleado

class EmpleadoLoginSerializer(serializers.Serializer):
    nombre = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate(self, attrs):
        nombre = attrs.get('nombre')
        password = attrs.get('password')
        
        if nombre and password:
            try:
                # Buscar empleado por nombre (pueden haber varios con el mismo nombre)
                empleados = Empleado.objects.filter(nombre__iexact=nombre, is_active=True)
                
                empleado_autenticado = None
                for empleado in empleados:
                    if empleado.check_password(password):
                        empleado_autenticado = empleado
                        break
                
                if empleado_autenticado:
                    attrs['empleado'] = empleado_autenticado
                    return attrs
                else:
                    raise serializers.ValidationError('Nombre o contraseña incorrectos.')
                    
            except Empleado.DoesNotExist:
                raise serializers.ValidationError('Nombre o contraseña incorrectos.')
        else:
            raise serializers.ValidationError('Debe proporcionar nombre y contraseña.')

class EmpleadoSessionSerializer(serializers.ModelSerializer):
    sucursal_nombre = serializers.CharField(source='sucursal.nombre', read_only=True)
    nombre_completo = serializers.CharField(source='get_full_name', read_only=True)
    
    class Meta:
        model = Empleado
        fields = ['id', 'nombre', 'apellido', 'nombre_completo', 'cargo', 
                 'correo', 'telefono', 'sucursal', 'sucursal_nombre', 'fecha_ingreso']
