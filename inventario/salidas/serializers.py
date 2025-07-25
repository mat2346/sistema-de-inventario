from rest_framework import serializers
from .models import Salida
from productos.serializers import ProductoSerializer
from sucursales.serializers import SucursalSerializer
from empleados.serializers import EmpleadoSerializer

class SalidaSerializer(serializers.ModelSerializer):
    producto_detalle = ProductoSerializer(source='producto', read_only=True)
    sucursal_detalle = SucursalSerializer(source='sucursal', read_only=True)
    empleado_detalle = EmpleadoSerializer(source='empleado', read_only=True)
    
    class Meta:
        model = Salida
        fields = ['id', 'producto', 'producto_detalle', 'sucursal', 'sucursal_detalle',
                 'empleado', 'empleado_detalle', 'cantidad', 'motivo', 'fecha']

class SalidaCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Salida
        fields = '__all__'
