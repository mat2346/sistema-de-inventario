#!/usr/bin/env bash
# build-fallback.sh - Build script con fallback para problemas de PostgreSQL

set -o errexit  # exit on error

echo "🐍 Verificando versión de Python..."
python --version
which python

echo "🔧 Actualizando pip, setuptools y wheel..."
pip install --upgrade pip setuptools wheel

echo "📦 Intentando instalar psycopg[binary]..."
if pip install "psycopg[binary]==3.1.18"; then
    echo "✅ psycopg[binary] instalado exitosamente"
    export USE_PSYCOPG3=true
else
    echo "⚠️ Error instalando psycopg[binary], usando SQLite como fallback"
    export FORCE_SQLITE=true
fi

echo "📦 Instalando resto de dependencias..."
pip install Django==5.1.9
pip install djangorestframework==3.15.2
pip install djangorestframework-simplejwt==5.2.2
pip install django-cors-headers==4.4.0
pip install django-filter==24.3
pip install python-dotenv==1.0.1
pip install whitenoise==6.6.0
pip install gunicorn==22.0.0
pip install dj-database-url==2.2.0
pip install cloudinary==1.40.0
pip install setuptools==69.5.1
pip install wheel==0.43.0
pip install Pillow==10.4.0
pip install requests==2.32.3

echo "📂 Recolectando archivos estáticos..."
python manage.py collectstatic --no-input

echo "🗄️ Ejecutando migraciones..."
python manage.py migrate

echo "👤 Configurando datos iniciales..."
python manage.py setup_production || echo "⚠️ No se pudo ejecutar setup_production, continuando..."

echo "✅ Build completado exitosamente!"
