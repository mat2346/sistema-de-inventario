from django.contrib import admin
from django.utils.html import format_html
from .models import Producto

@admin.register(Producto)
class ProductoAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'categoria', 'precio_compra', 'precio_venta', 'imagen_preview')
    list_filter = ('categoria',)
    search_fields = ('nombre', 'descripcion')
    readonly_fields = ('imagen_preview',)
    
    def imagen_preview(self, obj):
        """Mostrar preview de la imagen en el admin"""
        if obj.imagen:
            return format_html(
                '<img src="{}" style="width: 50px; height: 50px; object-fit: cover;" />',
                obj.imagen_thumbnail_url
            )
        return "Sin imagen"
    imagen_preview.short_description = "Vista previa"
