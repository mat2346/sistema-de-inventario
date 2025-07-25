from django.db import models
from categorias.models import Categoria
from cloudinary.models import CloudinaryField

class Producto(models.Model):
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True, null=True)
    categoria = models.ForeignKey(Categoria, on_delete=models.SET_NULL, null=True, blank=True)
    precio_compra = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    precio_venta = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    imagen = CloudinaryField('image', blank=True, null=True, 
                             transformation={'quality': 'auto', 'fetch_format': 'auto'})
    
    def __str__(self):
        return self.nombre
    
    @property
    def imagen_url(self):
        """Obtener URL optimizada de la imagen"""
        if self.imagen:
            # Si es un objeto CloudinaryResource, usar build_url
            if hasattr(self.imagen, 'build_url'):
                return self.imagen.build_url(
                    width=500, 
                    height=500, 
                    crop="fill", 
                    gravity="auto",
                    quality="auto",
                    fetch_format="auto"
                )
            # Si es un string, construir URL manualmente
            elif isinstance(self.imagen, str):
                from cloudinary.utils import cloudinary_url
                url, _ = cloudinary_url(
                    self.imagen,
                    width=500, 
                    height=500, 
                    crop="fill", 
                    gravity="auto",
                    quality="auto",
                    fetch_format="auto"
                )
                return url
        return None
    
    @property
    def imagen_thumbnail_url(self):
        """Obtener URL de thumbnail de la imagen"""
        if self.imagen:
            # Si es un objeto CloudinaryResource, usar build_url
            if hasattr(self.imagen, 'build_url'):
                return self.imagen.build_url(
                    width=150, 
                    height=150, 
                    crop="fill", 
                    gravity="auto",
                    quality="auto",
                    fetch_format="auto"
                )
            # Si es un string, construir URL manualmente
            elif isinstance(self.imagen, str):
                from cloudinary.utils import cloudinary_url
                url, _ = cloudinary_url(
                    self.imagen,
                    width=150, 
                    height=150, 
                    crop="fill", 
                    gravity="auto",
                    quality="auto",
                    fetch_format="auto"
                )
                return url
        return None
    
    class Meta:
        verbose_name = "Producto"
        verbose_name_plural = "Productos"
