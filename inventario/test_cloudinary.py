"""
Script de testing para Cloudinary
Ejecutar desde Django shell: python manage.py shell sss
"""

import os
import sys
import django 
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Configurar Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'inventario.settings')
django.setup()

import cloudinary
import cloudinary.uploader
from cloudinary.utils import cloudinary_url

def test_cloudinary_connection():
    """Probar conexión con Cloudinary"""
    try:
        # Test upload con imagen de ejemplo
        upload_result = cloudinary.uploader.upload(
            "https://res.cloudinary.com/demo/image/upload/getting-started/shoes.jpg",
            public_id="test_shoes",
            folder="productos/test"
        )
        
        print("✅ Conexión exitosa con Cloudinary!")
        print(f"URL segura: {upload_result['secure_url']}")
        print(f"Public ID: {upload_result['public_id']}")
        
        # Test optimización
        optimize_url, _ = cloudinary_url(
            upload_result['public_id'], 
            fetch_format="auto", 
            quality="auto"
        )
        print(f"URL optimizada: {optimize_url}")
        
        # Test transformación
        auto_crop_url, _ = cloudinary_url(
            upload_result['public_id'], 
            width=500, 
            height=500, 
            crop="auto", 
            gravity="auto"
        )
        print(f"URL transformada: {auto_crop_url}")
        
        # Limpiar test
        cloudinary.uploader.destroy(upload_result['public_id'])
        print("🧹 Test image eliminada")
        
        return True
        
    except Exception as e:
        print(f"❌ Error en conexión con Cloudinary: {e}")
        return False

def create_test_product_with_image():
    """Crear producto de prueba con imagen"""
    from productos.models import Producto
    from categorias.models import Categoria
    
    try:
        # Crear categoría si no existe
        categoria, created = Categoria.objects.get_or_create(
            nombre="Productos de Prueba",
            defaults={'descripcion': 'Categoría para testing'}
        )
        
        # Upload imagen de prueba
        upload_result = cloudinary.uploader.upload(
            "https://res.cloudinary.com/demo/image/upload/getting-started/shoes.jpg",
            public_id="producto_prueba_zapatos",
            folder="productos",
            transformation=[
                {'width': 800, 'height': 800, 'crop': 'limit'},
                {'quality': 'auto', 'fetch_format': 'auto'}
            ]
        )
        
        # Crear producto
        producto = Producto.objects.create(
            nombre="Zapatos de Prueba",
            descripcion="Producto de prueba con imagen de Cloudinary",
            categoria=categoria,
            precio_compra=50.00,
            precio_venta=80.00,
            imagen=upload_result['public_id']
        )
        
        print(f"✅ Producto creado: {producto.nombre}")
        print(f"🖼️  Imagen URL: {producto.imagen_url}")
        print(f"📸 Thumbnail URL: {producto.imagen_thumbnail_url}")
        
        return producto
        
    except Exception as e:
        print(f"❌ Error creando producto: {e}")
        return None

# Ejecutar tests
if __name__ == "__main__":
    print("🧪 Testing Cloudinary Integration...")
    print("-" * 50)
    
    # Test 1: Conexión
    if test_cloudinary_connection():
        print("\n🔄 Creando producto de prueba...")
        create_test_product_with_image()
    
    print("\n✅ Testing completado!")
