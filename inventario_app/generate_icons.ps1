# Script para generar iconos de la aplicación en diferentes resoluciones
# Basado en el logo de TOYOSAKI (carro azul en círculo)

Write-Host "Generando iconos para TOYOSAKI Inventario App..."

# Función para crear un icono PNG simple usando PowerShell
function Create-Icon {
    param(
        [int]$Size,
        [string]$OutputPath
    )
    
    Write-Host "Creando icono de ${Size}x${Size} en $OutputPath"
    
    # Crear un archivo SVG temporal
    $svgContent = @"
<svg width="$Size" height="$Size" viewBox="0 0 432 432" xmlns="http://www.w3.org/2000/svg">
  <!-- Fondo circular azul -->
  <circle cx="216" cy="216" r="216" fill="#2E7CD6"/>
  
  <!-- Carro blanco -->
  <g transform="translate(126, 130)">
    <!-- Cuerpo principal del carro -->
    <rect x="20" y="60" width="140" height="40" rx="8" fill="white"/>
    
    <!-- Parabrisas -->
    <path d="M30 60 L150 60 L140 40 L40 40 Z" fill="white"/>
    
    <!-- Ruedas -->
    <circle cx="40" cy="110" r="8" fill="#2E7CD6"/>
    <circle cx="140" cy="110" r="8" fill="#2E7CD6"/>
    
    <!-- Línea divisoria -->
    <rect x="20" y="85" width="140" height="4" fill="#2E7CD6"/>
    
    <!-- Plataforma/base -->
    <rect x="0" y="130" width="180" height="12" rx="6" fill="white"/>
    
    <!-- Poste central -->
    <rect x="86" y="142" width="8" height="20" rx="4" fill="white"/>
  </g>
</svg>
"@
    
    # Por ahora, crear un archivo de marcador ya que no podemos convertir SVG a PNG sin herramientas adicionales
    $placeholderContent = "# Icono ${Size}x${Size} para TOYOSAKI App - Reemplazar con PNG generado"
    Set-Content -Path "$OutputPath.placeholder" -Value $placeholderContent
}

# Crear directorios si no existen
$androidRes = "android\app\src\main\res"

# Generar iconos para diferentes densidades
Create-Icon -Size 48 -OutputPath "$androidRes\mipmap-mdpi\ic_launcher.png"
Create-Icon -Size 72 -OutputPath "$androidRes\mipmap-hdpi\ic_launcher.png"
Create-Icon -Size 96 -OutputPath "$androidRes\mipmap-xhdpi\ic_launcher.png"
Create-Icon -Size 144 -OutputPath "$androidRes\mipmap-xxhdpi\ic_launcher.png"
Create-Icon -Size 192 -OutputPath "$androidRes\mipmap-xxxhdpi\ic_launcher.png"

Write-Host "Iconos marcadores creados. Para generar los PNG reales:"
Write-Host "1. Usa una herramienta como Inkscape o un generador online"
Write-Host "2. O usa el comando flutter_launcher_icons package"
Write-Host "3. Reemplaza los archivos .placeholder con los PNG reales"
