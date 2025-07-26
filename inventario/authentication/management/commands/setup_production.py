from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from authentication.models import Empleado
import os

class Command(BaseCommand):
    help = 'Crear superusuario y empleado inicial para producción'

    def handle(self, *args, **options):
        # Crear superusuario si no existe
        if not User.objects.filter(username='admin').exists():
            User.objects.create_superuser(
                username='admin',
                email='admin@toyosaki.com',
                password=os.getenv('ADMIN_PASSWORD', 'admin123')
            )
            self.stdout.write(
                self.style.SUCCESS('Superusuario "admin" creado exitosamente')
            )
        
        # Crear empleado inicial si no existe
        if not Empleado.objects.filter(nombre='Admin').exists():
            empleado = Empleado.objects.create(
                nombre='Admin',
                apellido='Sistema',
                cargo='administrador',
                correo='admin@toyosaki.com',
                telefono='00000000'
            )
            empleado.set_password(os.getenv('ADMIN_PASSWORD', 'admin123'))
            empleado.save()
            
            self.stdout.write(
                self.style.SUCCESS('Empleado administrador creado exitosamente')
            )
        
        self.stdout.write(
            self.style.SUCCESS('Inicialización completada')
        )
