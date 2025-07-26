#!/usr/bin/env bash
# build-alternative.sh

set -o errexit  # exit on error

echo "🔧 Actualizando pip..."
pip install --upgrade pip

echo "🗄️ Instalando dependencias básicas..."
pip install setuptools wheel

echo "📦 Instalando psycopg2 directamente..."
pip install psycopg2-binary==2.9.7 --no-deps

echo "📦 Instalando Django y dependencias básicas..."
pip install Django==5.1.9
pip install gunicorn==20.1.0
pip install whitenoise==6.5.0
pip install dj-database-url==2.1.0
pip install python-dotenv==1.0.0
pip install djangorestframework==3.14.0
pip install django-cors-headers==4.3.1

echo "📂 Recolectando archivos estáticos..."
python manage.py collectstatic --no-input

echo "🗄️ Ejecutando migraciones..."
python manage.py migrate

echo "✅ Build alternativo completado!"
