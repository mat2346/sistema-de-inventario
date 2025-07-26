#!/usr/bin/env bash
# build-python310.sh - Build script optimized for Python 3.10 compatibility

set -o errexit  # exit on error

echo "🐍 Verificando versión de Python..."
python --version
which python

echo "🔧 Actualizando pip, setuptools y wheel..."
pip install --upgrade pip==23.3.2 setuptools==69.5.1 wheel==0.43.0

echo "🗄️ Instalando dependencias del sistema para PostgreSQL..."
apt-get update || true
apt-get install -y libpq-dev gcc python3-dev || true

echo "📦 Instalando psycopg2-binary compatible con Python 3.10..."
pip install psycopg2-binary==2.9.5

echo "📦 Instalando Django y dependencias principales..."
pip install Django==5.1.9
pip install djangorestframework==3.15.2
pip install djangorestframework-simplejwt==5.2.2
pip install django-cors-headers==4.4.0
pip install django-filter==24.3
pip install python-dotenv==1.0.1
pip install dj-database-url==2.2.0
pip install whitenoise==6.6.0
pip install gunicorn==22.0.0
pip install cloudinary==1.40.0
pip install Pillow==10.4.0
pip install requests==2.32.3

echo "📂 Recolectando archivos estáticos..."
python manage.py collectstatic --no-input

echo "🗄️ Ejecutando migraciones..."
python manage.py migrate

echo "👤 Configurando datos iniciales..."
python manage.py setup_production

echo "✅ Build completado exitosamente!"
