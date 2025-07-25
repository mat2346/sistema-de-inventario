from django.db import models
from django.utils import timezone
from productos.models import Producto
from sucursales.models import Sucursal
from empleados.models import Empleado

class Salida(models.Model):
    producto = models.ForeignKey(Producto, on_delete=models.CASCADE)
    sucursal = models.ForeignKey(Sucursal, on_delete=models.CASCADE)
    empleado = models.ForeignKey(Empleado, on_delete=models.CASCADE)
    cantidad = models.IntegerField()
    motivo = models.CharField(max_length=100, blank=True, null=True)
    fecha = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return f"Salida: {self.producto.nombre} - {self.cantidad} unidades"
    
    class Meta:
        verbose_name = "Salida"
        verbose_name_plural = "Salidas"
