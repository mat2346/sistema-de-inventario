from rest_framework import viewsets, filters, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db import transaction
from .models import Salida
from .serializers import SalidaSerializer, SalidaCreateSerializer
from inventario_stock.models import Inventario

class SalidaViewSet(viewsets.ModelViewSet):
    queryset = Salida.objects.select_related(
        'producto', 'sucursal', 'empleado'
    ).all()
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['sucursal', 'empleado', 'producto', 'motivo']
    search_fields = ['producto__nombre', 'empleado__nombre', 'motivo']
    ordering_fields = ['fecha']
    ordering = ['-fecha']
    
    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return SalidaCreateSerializer
        return SalidaSerializer
    
    @transaction.atomic
    def create(self, request, *args, **kwargs):
        """Crear salida y actualizar inventario automáticamente"""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Verificar si hay suficiente inventario
        try:
            inventario = Inventario.objects.get(
                producto=serializer.validated_data['producto'],
                sucursal=serializer.validated_data['sucursal']
            )
            if inventario.cantidad < serializer.validated_data['cantidad']:
                return Response(
                    {'error': 'No hay suficiente inventario disponible'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
        except Inventario.DoesNotExist:
            return Response(
                {'error': 'No existe inventario para este producto en esta sucursal'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        salida = serializer.save()
        
        # Actualizar inventario
        inventario.cantidad -= salida.cantidad
        inventario.save()
        
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
