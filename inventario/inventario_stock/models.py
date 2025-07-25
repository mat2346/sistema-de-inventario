from django.db import models
from productos.models import Producto
from sucursales.models import Sucursal

class Inventario(models.Model):
    producto = models.ForeignKey(Producto, on_delete=models.CASCADE)
    sucursal = models.ForeignKey(Sucursal, on_delete=models.CASCADE)
    cantidad = models.IntegerField(default=0)
    
    def __str__(self):
        return f"{self.producto.nombre} - {self.sucursal.nombre}: {self.cantidad}"
    
    class Meta:
        verbose_name = "Inventario"
        verbose_name_plural = "Inventarios"
        unique_together = ('producto', 'sucursal')
