from rest_framework import serializers
from .models import Producto
from categorias.serializers import CategoriaSerializer

class ProductoSerializer(serializers.ModelSerializer):
    categoria_detalle = CategoriaSerializer(source='categoria', read_only=True)
    imagen_url = serializers.ReadOnlyField()
    imagen_thumbnail_url = serializers.ReadOnlyField()
    
    class Meta:
        model = Producto
        fields = ['id', 'nombre', 'descripcion', 'categoria', 'categoria_detalle', 
                 'precio_compra', 'precio_venta', 'imagen', 'imagen_url', 'imagen_thumbnail_url']

class ProductoCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Producto
        fields = '__all__'

class ProductoImageUploadSerializer(serializers.ModelSerializer):
    """Serializer específico para subida de imágenes"""
    class Meta:
        model = Producto
        fields = ['imagen']
