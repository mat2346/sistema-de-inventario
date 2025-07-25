# Inventario App

Una aplicación móvil Flutter para gestión de inventario que se conecta con un backend Django REST API.

## Características

- ✅ Gestión de productos
- ✅ Gestión de categorías  
- ✅ Control de inventario por sucursal
- ✅ Interfaz intuitiva y moderna
- 🔄 Conexión con backend Django REST API
- 📊 Reportes básicos

## Estructura del Proyecto

```
lib/
├── models/           # Modelos de datos
│   ├── categoria.dart
│   ├── producto.dart
│   ├── sucursal.dart
│   └── inventario.dart
├── services/         # Servicios para API
│   ├── api_service.dart
│   ├── categoria_service.dart
│   ├── producto_service.dart
│   └── inventario_service.dart
├── providers/        # Gestión de estado
│   ├── categoria_provider.dart
│   ├── producto_provider.dart
│   └── inventario_provider.dart
├── screens/          # Pantallas de la app
│   ├── home_screen.dart
│   ├── productos_screen.dart
│   ├── categorias_screen.dart
│   └── inventario_screen.dart
└── main.dart         # Punto de entrada
```

## Instalación

1. **Instalar Flutter SDK**
   ```bash
   # Sigue las instrucciones en https://flutter.dev/docs/get-started/install
   ```

2. **Clonar y configurar el proyecto**
   ```bash
   git clone <tu-repositorio>
   cd inventario_app
   flutter pub get
   ```

3. **Configurar la conexión con el backend**
   
   Edita el archivo `lib/services/api_service.dart` y cambia la URL base:
   ```dart
   static const String baseUrl = 'http://TU_IP:8000/api'; // Cambia por tu URL
   ```

## Configuración del Backend Django

Para que la app Flutter funcione correctamente, necesitas configurar tu backend Django:

### 1. Instalar Django REST Framework

```bash
pip install djangorestframework
pip install django-cors-headers
```

### 2. Configurar settings.py

```python
INSTALLED_APPS = [
    # ... tus apps existentes
    'rest_framework',
    'corsheaders',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    # ... otros middlewares
]

# Configuración de CORS para desarrollo
CORS_ALLOW_ALL_ORIGINS = True  # Solo para desarrollo
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
]

# Configuración de REST Framework
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Cambiar en producción
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20
}
```

### 3. Actualizar URLs principales

En `inventario/urls.py`:
```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('productos.urls')),
    path('api/', include('categorias.urls')),
    path('api/', include('inventario_stock.urls')),
    path('api/', include('sucursales.urls')),
]
```

### 4. Crear ViewSets en cada app

Ejemplo para `productos/views.py`:
```python
from rest_framework import viewsets
from .models import Producto
from .serializers import ProductoSerializer

class ProductoViewSet(viewsets.ModelViewSet):
    queryset = Producto.objects.all()
    serializer_class = ProductoSerializer
```

### 5. Crear URLs para cada app

Ejemplo para `productos/urls.py`:
```python
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ProductoViewSet

router = DefaultRouter()
router.register(r'productos', ProductoViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
```

## Ejecutar la Aplicación

1. **Iniciar el backend Django**
   ```bash
   cd ../inventario  # Ir al directorio del backend
   python manage.py runserver 0.0.0.0:8000
   ```

2. **Ejecutar la app Flutter**
   ```bash
   cd inventario_app
   flutter run
   ```

## Funcionalidades Implementadas

### Pantalla Principal
- Dashboard con acceso rápido a todas las secciones
- Navegación intuitiva con iconos

### Gestión de Productos
- Crear, editar y eliminar productos
- Asignar categorías
- Definir precios de compra y venta
- Validación de formularios

### Gestión de Categorías
- CRUD completo de categorías
- Interfaz simple y efectiva

### Control de Inventario
- Ver stock por producto y sucursal
- Alertas de stock bajo
- Resumen de inventario
- Actualización de cantidades

## Próximas Funcionalidades

- [ ] Autenticación de usuarios
- [ ] Reportes avanzados
- [ ] Búsqueda y filtros
- [ ] Notificaciones push
- [ ] Modo offline
- [ ] Códigos de barras

## Notas de Desarrollo

### Para Conectar con Backend Real

1. Descomenta y configura los providers en `main.dart`:
   ```dart
   // Cuando tengas el backend funcionando, envuelve tu app con providers:
   MultiProvider(
     providers: [
       ChangeNotifierProvider(create: (_) => ProductoProvider()),
       ChangeNotifierProvider(create: (_) => CategoriaProvider()),
       ChangeNotifierProvider(create: (_) => InventarioProvider()),
     ],
     child: InventarioApp(),
   )
   ```

2. Reemplaza los datos de ejemplo en las pantallas con llamadas a los providers.

3. Configura la IP correcta en `api_service.dart` para tu backend.

### Para Desarrollo en Emulador

- Si usas emulador Android: `http://10.0.2.2:8000/api`
- Si usas dispositivo físico: `http://TU_IP_LOCAL:8000/api`
- Para iOS Simulator: `http://localhost:8000/api`

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu funcionalidad (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para detalles.
