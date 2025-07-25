from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Proveedor
from .serializers import ProveedorSerializer

class ProveedorViewSet(viewsets.ModelViewSet):
    queryset = Proveedor.objects.all()
    serializer_class = ProveedorSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['nombre', 'contacto', 'telefono']
    ordering_fields = ['nombre']
    ordering = ['nombre']
