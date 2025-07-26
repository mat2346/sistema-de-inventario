# 🚀 Guía de Despliegue en Render

## Pasos para desplegar tu API de Django en Render:

### 1. Preparar el repositorio
- Asegúrate de que todos los archivos estén commitidos en Git
- Sube el código a GitHub/GitLab

### 2. Crear cuenta en Render
- Ve a [render.com](https://render.com)
- Crea una cuenta gratuita
- Conecta tu cuenta de GitHub/GitLab

### 3. Crear base de datos PostgreSQL
1. En el dashboard de Render, haz clic en "New +"
2. Selecciona "PostgreSQL"
3. Nombre: `toyosaki-inventario-db`
4. Plan: Free
5. Crea la base de datos
6. **Importante**: Copia la "External Database URL" que aparece

### 4. Crear Web Service
1. En el dashboard, haz clic en "New +"
2. Selecciona "Web Service"
3. Conecta tu repositorio
4. Configuración:
   - **Name**: `inventario-backend`
   - **Environment**: `Python 3`
   - **Runtime**: `Python 3.11.8`
   - **Build Command**: `./build.sh`
   - **Start Command**: `gunicorn inventario.wsgi:application --bind 0.0.0.0:$PORT --workers 1 --timeout 120`

### 5. Variables de entorno
En la sección "Environment Variables", agrega:

```
SECRET_KEY=tu-clave-secreta-muy-larga-y-segura-aqui
DEBUG=False
DATABASE_URL=[pega-aqui-la-url-de-tu-base-de-datos]
RENDER_EXTERNAL_HOSTNAME=[nombre-de-tu-app].onrender.com
ADMIN_PASSWORD=tu-password-admin-seguro
CLOUDINARY_CLOUD_NAME=tu_cloud_name
CLOUDINARY_API_KEY=tu_api_key  
CLOUDINARY_API_SECRET=tu_api_secret
```

### 6. Desplegar
1. Haz clic en "Create Web Service"
2. Render empezará a construir y desplegar tu aplicación
3. El proceso tardará unos minutos

### 7. Verificar el despliegue
- Una vez completado, tendrás una URL como: `https://tu-app.onrender.com`
- Verifica que funcione visitando: `https://tu-app.onrender.com/api/`
- El admin estará en: `https://tu-app.onrender.com/admin/`

### 8. Configurar auto-deploy (opcional)
- En la configuración del servicio, activa "Auto-Deploy"
- Ahora cada push a la rama principal desplegará automáticamente

## URLs importantes después del despliegue:
- **API Base**: `https://tu-app.onrender.com/api/`
- **Admin**: `https://tu-app.onrender.com/admin/`
- **Login JWT**: `https://tu-app.onrender.com/api/auth/login/`
- **Documentación**: `https://tu-app.onrender.com/api/`

## Credenciales por defecto:
- **Usuario**: admin
- **Password**: [el que configuraste en ADMIN_PASSWORD]

## ⚠️ Notas importantes:
1. El plan gratuito de Render puede "dormir" después de 15 minutos de inactividad
2. El primer request después de dormir puede tardar hasta 30 segundos
3. Para producción real, considera usar un plan de pago
4. Cambia todas las credenciales por defecto antes de usar en producción

## 🔧 Comandos útiles después del despliegue:
```bash
# Ver logs en tiempo real
render logs --service tu-app-name

# Ejecutar comando en el servidor
render exec --service tu-app-name "python manage.py createsuperuser"
```
