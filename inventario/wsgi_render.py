# Configuración específica para solucionar problemas de pkg_resources
import sys
import os

# Agregar al path si es necesario
if '/opt/render/project/src' not in sys.path:
    sys.path.insert(0, '/opt/render/project/src')

# Configurar variables de entorno
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'inventario.settings')

import django
django.setup()

from inventario.wsgi import application
