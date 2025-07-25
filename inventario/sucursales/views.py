from rest_framework import viewsets, filters
from django_filters.rest_framework import DjangoFilterBackend
from .models import Sucursal
from .serializers import SucursalSerializer

class SucursalViewSet(viewsets.ModelViewSet):
    queryset = Sucursal.objects.all()
    serializer_class = SucursalSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['ciudad']
    search_fields = ['nombre', 'ciudad', 'direccion']
    ordering_fields = ['nombre', 'ciudad']
    ordering = ['nombre']
