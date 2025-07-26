#!/usr/bin/env bash
# build.sh

set -o errexit  # exit on error

echo "🔧 Actualizando pip y setuptools..."
pip install --upgrade pip setuptools

echo "📦 Instalando dependencias..."
pip install -r requirements.txt

echo "� Recolectando archivos estáticos..."
python manage.py collectstatic --no-input

echo "🗄️ Ejecutando migraciones..."
python manage.py migrate

echo "👤 Configurando datos iniciales..."
python manage.py setup_production

echo "✅ Build completado exitosamente!"
