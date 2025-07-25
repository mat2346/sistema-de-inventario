from rest_framework import serializers
from .models import Empleado
from sucursales.serializers import SucursalSerializer

class EmpleadoSerializer(serializers.ModelSerializer):
    sucursal_detalle = SucursalSerializer(source='sucursal', read_only=True)
    nombre_completo = serializers.CharField(source='get_full_name', read_only=True)
    
    class Meta:
        model = Empleado
        fields = ['id', 'nombre', 'apellido', 'nombre_completo', 'cargo', 'correo', 'telefono', 
                 'sucursal', 'sucursal_detalle', 'is_active', 'fecha_ingreso']
        # Excluir password del serializer por seguridad

class EmpleadoCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    
    class Meta:
        model = Empleado
        fields = ['nombre', 'apellido', 'cargo', 'correo', 'telefono', 'password', 'sucursal', 'is_active']
    
    def create(self, validated_data):
        password = validated_data.pop('password')
        empleado = Empleado(**validated_data)
        empleado.set_password(password)
        empleado.save()
        return empleado
