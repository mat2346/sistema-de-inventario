from django.db import models
from django.utils import timezone
from productos.models import Producto
from sucursales.models import Sucursal
from proveedores.models import Proveedor
from empleados.models import Empleado

class Entrada(models.Model):
    producto = models.ForeignKey(Producto, on_delete=models.CASCADE)
    sucursal = models.ForeignKey(Sucursal, on_delete=models.CASCADE)
    proveedor = models.ForeignKey(Proveedor, on_delete=models.CASCADE)
    empleado = models.ForeignKey(Empleado, on_delete=models.CASCADE)
    cantidad = models.IntegerField()
    fecha = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return f"Entrada: {self.producto.nombre} - {self.cantidad} unidades"
    
    class Meta:
        verbose_name = "Entrada"
        verbose_name_plural = "Entradas"
