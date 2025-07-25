from django.contrib import admin
from .models import Entrada

@admin.register(Entrada)
class EntradaAdmin(admin.ModelAdmin):
    list_display = ('producto', 'sucursal', 'proveedor', 'cantidad', 'fecha')
    list_filter = ('sucursal', 'proveedor', 'fecha')
    search_fields = ('producto__nombre', 'proveedor__nombre')
    date_hierarchy = 'fecha'
