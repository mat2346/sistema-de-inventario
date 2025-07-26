#!/usr/bin/env bash
# build-sqlite.sh - Build script using SQLite instead of PostgreSQL

set -o errexit  # exit on error

echo "🐍 Verificando versión de Python..."
python --version
which python

echo "🔧 Actualizando pip, setuptools y wheel..."
pip install --upgrade pip setuptools wheel

echo "📦 Instalando dependencias de Python (sin PostgreSQL)..."
pip install -r requirements-sqlite.txt

echo "🗄️ Configurando variable de entorno para SQLite..."
export USE_SQLITE=true

echo "📂 Recolectando archivos estáticos..."
python manage.py collectstatic --no-input

echo "🗄️ Ejecutando migraciones..."
python manage.py migrate

echo "👤 Configurando datos iniciales..."
python manage.py setup_production

echo "✅ Build completado exitosamente con SQLite!"
