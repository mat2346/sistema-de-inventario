from django.contrib import admin
from .models import Salida

@admin.register(Salida)
class SalidaAdmin(admin.ModelAdmin):
    list_display = ('producto', 'sucursal', 'empleado', 'cantidad', 'motivo', 'fecha')
    list_filter = ('sucursal', 'motivo', 'fecha')
    search_fields = ('producto__nombre', 'empleado__nombre')
    date_hierarchy = 'fecha'
