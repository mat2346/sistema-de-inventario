from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q
from .models import Inventario
from .serializers import InventarioSerializer, InventarioCreateSerializer

class InventarioViewSet(viewsets.ModelViewSet):
    queryset = Inventario.objects.select_related('producto', 'sucursal', 'producto__categoria').all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['sucursal', 'producto', 'producto__categoria']
    search_fields = ['producto__nombre', 'sucursal__nombre']
    ordering_fields = ['producto__nombre', 'cantidad']
    ordering = ['producto__nombre']
    
    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return InventarioCreateSerializer
        return InventarioSerializer
    
    @action(detail=False, methods=['get'])
    def bajo_stock(self, request):
        """Obtener productos con stock bajo (menos de 10 unidades)"""
        inventario_bajo = self.queryset.filter(cantidad__lt=10)
        serializer = self.get_serializer(inventario_bajo, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def sin_stock(self, request):
        """Obtener productos sin stock"""
        inventario_sin_stock = self.queryset.filter(cantidad=0)
        serializer = self.get_serializer(inventario_sin_stock, many=True)
        return Response(serializer.data)
