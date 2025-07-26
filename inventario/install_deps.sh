#!/bin/bash
# install_deps.sh - Script alternativo de instalación

set -e

echo "🔧 Instalando dependencias del sistema..."
apt-get update
apt-get install -y python3-dev libpq-dev build-essential

echo "🐍 Actualizando herramientas de Python..."
pip install --upgrade pip setuptools wheel

echo "📦 Instalando psycopg desde source si es necesario..."
pip install psycopg2==2.9.7 --no-binary psycopg2 || pip install psycopg[binary]==3.1.18

echo "📦 Instalando resto de dependencias..."
pip install -r requirements.txt

echo "✅ Dependencias instaladas!"
