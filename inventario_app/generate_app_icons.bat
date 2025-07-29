@echo off
echo ================================================
echo   🚗 TOYOSAKI - Generador de Iconos de App
echo ================================================
echo.

echo 📥 Instalando dependencias...
flutter pub get

echo.
echo 🎨 Generando iconos para todas las plataformas...
flutter pub run flutter_launcher_icons:main

echo.
echo 🧹 Limpiando proyecto...
flutter clean

echo.
echo 📥 Reinstalando dependencias...
flutter pub get

echo.
echo ✅ ¡Iconos generados exitosamente!
echo.
echo 📝 Para ver los cambios:
echo    1. Desinstala la app del dispositivo
echo    2. Ejecuta: flutter run --release
echo    3. O genera APK: flutter build apk --release
echo.
echo 🎉 ¡Tu app TOYOSAKI ahora tiene el logo personalizado!
echo.
pause
