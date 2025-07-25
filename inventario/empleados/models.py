from django.db import models
from django.contrib.auth.hashers import make_password, check_password
from sucursales.models import Sucursal

class Empleado(models.Model):
    nombre = models.CharField(max_length=100)
    apellido = models.CharField(max_length=100, default='Sin especificar')
    cargo = models.CharField(max_length=50, blank=True, null=True)
    correo = models.EmailField(unique=True)
    telefono = models.CharField(max_length=20, blank=True, null=True)
    password = models.CharField(max_length=255)
    sucursal = models.ForeignKey(Sucursal, on_delete=models.SET_NULL, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    fecha_ingreso = models.DateTimeField(auto_now_add=True)
    
    def set_password(self, raw_password):
        self.password = make_password(raw_password)
    
    def check_password(self, raw_password):
        return check_password(raw_password, self.password)
    
    def get_full_name(self):
        return f"{self.nombre} {self.apellido}"
    
    def __str__(self):
        return f"{self.get_full_name()} - {self.cargo}"
    
    class Meta:
        verbose_name = "Empleado"
        verbose_name_plural = "Empleados"
