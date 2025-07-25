from django.contrib import admin
from .models import Sucursal

@admin.register(Sucursal)
class SucursalAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'ciudad', 'telefono')
    search_fields = ('nombre', 'ciudad')
    list_filter = ('ciudad',)
