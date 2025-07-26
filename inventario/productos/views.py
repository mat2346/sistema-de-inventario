from rest_framework import viewsets, filters, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Producto
from .serializers import ProductoSerializer, ProductoCreateSerializer, ProductoImageUploadSerializer
import cloudinary.uploader

class ProductoViewSet(viewsets.ModelViewSet):
    queryset = Producto.objects.select_related('categoria').all()
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['categoria', 'categoria__nombre']
    search_fields = ['nombre', 'descripcion']
    ordering_fields = ['nombre', 'precio_venta', 'precio_compra']
    ordering = ['nombre']
    
    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return ProductoCreateSerializer
        elif self.action == 'upload_image':
            return ProductoImageUploadSerializer
        return ProductoSerializer
    
    @action(detail=True, methods=['post'])
    def upload_image(self, request, pk=None):
        """Endpoint específico para subir imágenes de productos"""
        producto = self.get_object()
        
        if 'imagen' not in request.FILES:
            return Response(
                {'error': 'No se encontró archivo de imagen'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Subir imagen a Cloudinary
            upload_result = cloudinary.uploader.upload(
                request.FILES['imagen'],
                folder="productos",
                public_id=f"producto_{producto.id}",
                overwrite=True,
                transformation=[
                    {'width': 800, 'height': 800, 'crop': 'limit'},
                    {'quality': 'auto', 'fetch_format': 'auto'}
                ]
            )
            
            # Actualizar el producto con la nueva imagen
            producto.imagen = upload_result['public_id']
            producto.save()
            
            serializer = ProductoSerializer(producto)
            return Response({
                'message': 'Imagen subida exitosamente',
                'producto': serializer.data,
                'imagen_info': {
                    'url': upload_result['secure_url'],
                    'public_id': upload_result['public_id']
                }
            })
            
        except Exception as e:
            return Response(
                {'error': f'Error al subir imagen: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['delete'])
    def delete_image(self, request, pk=None):
        """Endpoint para eliminar imagen de producto"""
        producto = self.get_object()
        
        if not producto.imagen:
            return Response(
                {'error': 'El producto no tiene imagen'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Eliminar imagen de Cloudinary
            cloudinary.uploader.destroy(producto.imagen.public_id)
            
            # Limpiar campo imagen del producto
            producto.imagen = None
            producto.save()
            
            return Response({'message': 'Imagen eliminada exitosamente'})
            
        except Exception as e:
            return Response(
                {'error': f'Error al eliminar imagen: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
