from rest_framework import serializers
from .models import Entrada
from productos.serializers import ProductoSerializer
from sucursales.serializers import SucursalSerializer
from proveedores.serializers import ProveedorSerializer
from empleados.serializers import EmpleadoSerializer

class EntradaSerializer(serializers.ModelSerializer):
    producto_detalle = ProductoSerializer(source='producto', read_only=True)
    sucursal_detalle = SucursalSerializer(source='sucursal', read_only=True)
    proveedor_detalle = ProveedorSerializer(source='proveedor', read_only=True)
    empleado_detalle = EmpleadoSerializer(source='empleado', read_only=True)
    
    class Meta:
        model = Entrada
        fields = ['id', 'producto', 'producto_detalle', 'sucursal', 'sucursal_detalle',
                 'proveedor', 'proveedor_detalle', 'empleado', 'empleado_detalle',
                 'cantidad', 'fecha']

class EntradaCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Entrada
        fields = '__all__'
