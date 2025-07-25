from rest_framework import serializers
from .models import Inventario
from productos.serializers import ProductoSerializer
from sucursales.serializers import SucursalSerializer

class InventarioSerializer(serializers.ModelSerializer):
    producto_detalle = ProductoSerializer(source='producto', read_only=True)
    sucursal_detalle = SucursalSerializer(source='sucursal', read_only=True)
    
    class Meta:
        model = Inventario
        fields = ['id', 'producto', 'producto_detalle', 'sucursal', 
                 'sucursal_detalle', 'cantidad']

class InventarioCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Inventario
        fields = '__all__'
