from django.contrib import admin
from .models import Inventario

@admin.register(Inventario)
class InventarioAdmin(admin.ModelAdmin):
    list_display = ('producto', 'sucursal', 'cantidad')
    list_filter = ('sucursal', 'producto__categoria')
    search_fields = ('producto__nombre', 'sucursal__nombre')
