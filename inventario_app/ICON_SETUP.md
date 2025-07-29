# 🚗 TOYOSAKI - Configuración del Icono de la App

## Pasos para configurar el icono de la aplicación:

### 1. Preparar el icono base
- Guarda tu imagen del logo como `assets/icons/app_icon.png`
- **Resolución recomendada:** 1024x1024 píxeles
- **Formato:** PNG con fondo transparente o sólido
- **Diseño:** El logo del carro azul que proporcionaste

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Generar iconos automáticamente
```bash
flutter pub run flutter_launcher_icons:main
```

### 4. Limpiar y reconstruir
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## 📱 Iconos generados automáticamente para:
- ✅ **Android:** Todos los tamaños (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ **iOS:** App Store y todos los dispositivos
- ✅ **Web:** PWA y favicon
- ✅ **Windows:** Aplicación de escritorio
- ✅ **macOS:** Aplicación nativa

## 🎨 Configuración actual:
- **Color de fondo:** `#2E7CD6` (azul del logo)
- **Tema:** Azul TOYOSAKI
- **Icono base:** `assets/icons/app_icon.png`

## 📝 Notas importantes:
1. El archivo `app_icon.png` debe ser de **1024x1024** píxeles para mejores resultados
2. Si cambias el icono, ejecuta nuevamente el comando de generación
3. Para Android, se generarán iconos adaptativos automáticamente
4. El icono aparecerá en el launcher después de reinstalar la app

## 🔄 Si ya tienes el PNG del logo:
1. Cópialo a `assets/icons/app_icon.png`
2. Ejecuta: `flutter pub run flutter_launcher_icons:main`
3. Reconstruye la app: `flutter build apk --release`

¡Tu app TOYOSAKI tendrá el logo profesional en todos los dispositivos! 🎉
