#!/usr/bin/env bash
# build-supabase.sh - Build script for Supabase deployment with psycopg3

set -o errexit  # exit on error

echo "🐍 Verificando versión de Python..."
python --version
which python

echo "🔧 Actualizando pip, setuptools y wheel..."
pip install --upgrade pip setuptools wheel

echo "📦 Instalando psycopg[binary] específicamente..."
pip install "psycopg[binary]==3.2.9"

echo "📦 Instalando resto de dependencias..."
pip install -r requirements.txt

echo "🗄️ Configurando variable para usar Supabase..."
export FORCE_SQLITE=false

echo "📂 Recolectando archivos estáticos..."
python manage.py collectstatic --no-input

echo "🗄️ Ejecutando migraciones en Supabase..."
python manage.py migrate

echo "👤 Configurando datos iniciales..."
python manage.py setup_production || echo "⚠️ No se pudo ejecutar setup_production, continuando..."

echo "✅ Build completado exitosamente con Supabase y psycopg3!"
