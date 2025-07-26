#!/usr/bin/env bash
# build-supabase.sh - Build script for Supabase deployment without psycopg2

set -o errexit  # exit on error

echo "🐍 Verificando versión de Python..."
python --version
which python

echo "🔧 Actualizando pip, setuptools y wheel..."
pip install --upgrade pip setuptools wheel

echo "📦 Instalando dependencias (sin psycopg2)..."
pip install -r requirements-sqlite.txt

echo "🗄️ Configurando variable para usar Supabase directamente..."
export FORCE_SQLITE=false

echo "📂 Recolectando archivos estáticos..."
python manage.py collectstatic --no-input

echo "🗄️ Ejecutando migraciones en Supabase..."
python manage.py migrate

echo "👤 Configurando datos iniciales..."
python manage.py setup_production || echo "⚠️ No se pudo ejecutar setup_production, continuando..."

echo "✅ Build completado exitosamente con Supabase!"
