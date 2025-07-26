from rest_framework import viewsets, filters, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db import transaction
from .models import Entrada
from .serializers import EntradaSerializer, EntradaCreateSerializer
from inventario_stock.models import Inventario

class EntradaViewSet(viewsets.ModelViewSet):
    queryset = Entrada.objects.select_related(
        'producto', 'sucursal', 'proveedor', 'empleado'
    ).all()
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['sucursal', 'proveedor', 'empleado', 'producto']
    search_fields = ['producto__nombre', 'proveedor__nombre']
    ordering_fields = ['fecha']
    ordering = ['-fecha']
    
    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return EntradaCreateSerializer
        return EntradaSerializer
    
    @transaction.atomic
    def create(self, request, *args, **kwargs):
        """Crear entrada y actualizar inventario automáticamente"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        entrada = serializer.save()
        
        # Actualizar inventario
        inventario, created = Inventario.objects.get_or_create(
            producto=entrada.producto,
            sucursal=entrada.sucursal,
            defaults={'cantidad': 0}
        )
        inventario.cantidad += entrada.cantidad
        inventario.save()
        
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
