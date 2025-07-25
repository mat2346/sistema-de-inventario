from django.core.management.base import BaseCommand
from empleados.models import Empleado
from sucursales.models import Sucursal

class Command(BaseCommand):
    help = 'Crear empleados de prueba para el sistema de autenticación'

    def handle(self, *args, **options):
        # Crear o obtener sucursal principal
        sucursal, created = Sucursal.objects.get_or_create(
            nombre='Sucursal Principal',
            defaults={
                'direccion': 'Calle Principal 123',
                'telefono': '123-456-7890'
            }
        )
        
        if created:
            self.stdout.write(
                self.style.SUCCESS(f'Sucursal creada: {sucursal.nombre}')
            )

        # Crear empleado administrador
        if not Empleado.objects.filter(nombre='admin').exists():
            admin = Empleado(
                nombre='admin',
                apellido='administrador',
                cargo='Administrador',
                correo='admin@inventario.com',
                telefono='123-456-7890',
                sucursal=sucursal
            )
            admin.set_password('123456')
            admin.save()
            
            self.stdout.write(
                self.style.SUCCESS(
                    f'✅ Empleado creado: {admin.get_full_name()}\n'
                    f'   Usuario: admin\n'
                    f'   Contraseña: 123456\n'
                    f'   Cargo: {admin.cargo}'
                )
            )
        else:
            self.stdout.write(
                self.style.WARNING('⚠️  El empleado admin ya existe')
            )

        # Crear empleado vendedor
        if not Empleado.objects.filter(nombre='vendedor').exists():
            vendedor = Empleado(
                nombre='vendedor',
                apellido='principal',
                cargo='Vendedor',
                correo='vendedor@inventario.com',
                telefono='123-456-7891',
                sucursal=sucursal
            )
            vendedor.set_password('123456')
            vendedor.save()
            
            self.stdout.write(
                self.style.SUCCESS(
                    f'✅ Empleado creado: {vendedor.get_full_name()}\n'
                    f'   Usuario: vendedor\n'
                    f'   Contraseña: 123456\n'
                    f'   Cargo: {vendedor.cargo}'
                )
            )
        else:
            self.stdout.write(
                self.style.WARNING('⚠️  El empleado vendedor ya existe')
            )

        # Mostrar resumen
        empleados = Empleado.objects.filter(is_active=True)
        self.stdout.write(
            self.style.HTTP_INFO(
                f'\n📋 EMPLEADOS DISPONIBLES ({empleados.count()}):'
            )
        )
        
        for emp in empleados:
            self.stdout.write(
                f'   • {emp.get_full_name()} ({emp.nombre}) - {emp.cargo}'
            )
            
        self.stdout.write(
            self.style.HTTP_INFO(
                f'\n🔑 CREDENCIALES DE PRUEBA:'
                f'\n   admin / 123456 (Administrador)'
                f'\n   vendedor / 123456 (Vendedor)'
                f'\n\n🌐 URL DE LOGIN: http://127.0.0.1:8000/api/auth/login/'
            )
        )
