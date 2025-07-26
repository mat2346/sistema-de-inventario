from rest_framework import viewsets, filters
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from .models import Empleado
from .serializers import EmpleadoSerializer, EmpleadoCreateSerializer

class EmpleadoViewSet(viewsets.ModelViewSet):
    queryset = Empleado.objects.select_related('sucursal').all()
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['cargo', 'sucursal']
    search_fields = ['nombre', 'correo', 'cargo']
    ordering_fields = ['nombre', 'cargo']
    ordering = ['nombre']
    
    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return EmpleadoCreateSerializer
        return EmpleadoSerializer
