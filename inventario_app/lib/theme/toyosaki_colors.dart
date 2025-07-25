import 'package:flutter/material.dart';

class ToyosakiColors {
  // Colores principales de TOYOSAKI
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color secondaryYellow = Color(0xFFFFC107);
  static const Color accentGreen = Color(0xFF2E7D32);
  static const Color errorRed = Color(0xFFD32F2F);

  // Variaciones de azul
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color blueGrey = Color(0xFF37474F);

  // Variaciones de amarillo
  static const Color lightYellow = Color(0xFFFFF59D);
  static const Color darkYellow = Color(0xFFF57F17);
  static const Color amberAccent = Color(0xFFFFD54F);

  // Colores neutros
  static const Color lightGrey = Color(0xFFF8F9FA);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);

  // Gradientes personalizados
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, lightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryYellow, amberAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [primaryBlue, darkBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient softBackgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFE3F2FD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Estados de componentes
  static Color success = accentGreen;
  static Color warning = secondaryYellow;
  static Color error = errorRed;
  static Color info = primaryBlue;

  // Colores para tipos de repuestos automotrices
  static const Color motorParts = Color(0xFF1976D2); // Azul para motor
  static const Color transmissionParts = Color(
    0xFF388E3C,
  ); // Verde para transmisión
  static const Color brakeParts = Color(0xFFD32F2F); // Rojo para frenos
  static const Color suspensionParts = Color(
    0xFF7B1FA2,
  ); // Púrpura para suspensión
  static const Color electricalParts = Color(
    0xFFF57C00,
  ); // Naranja para eléctrico
  static const Color bodyParts = Color(0xFF5D4037); // Marrón para carrocería
  static const Color tiresParts = Color(0xFF424242); // Negro para neumáticos
  static const Color oilParts = Color(0xFF795548); // Marrón oscuro para aceites

  // Método para obtener color por categoría
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'motor':
      case 'motores':
        return motorParts;
      case 'transmision':
      case 'transmisión':
        return transmissionParts;
      case 'frenos':
        return brakeParts;
      case 'suspension':
      case 'suspensión':
        return suspensionParts;
      case 'electrico':
      case 'eléctrico':
      case 'electricidad':
        return electricalParts;
      case 'carroceria':
      case 'carrocería':
      case 'chapa':
        return bodyParts;
      case 'neumaticos':
      case 'neumáticos':
      case 'llantas':
        return tiresParts;
      case 'aceites':
      case 'lubricantes':
        return oilParts;
      default:
        return primaryBlue;
    }
  }

  // Iconos por categoría de repuesto
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'motor':
      case 'motores':
        return Icons.engineering;
      case 'transmision':
      case 'transmisión':
        return Icons.settings;
      case 'frenos':
        return Icons.disc_full;
      case 'suspension':
      case 'suspensión':
        return Icons.height;
      case 'electrico':
      case 'eléctrico':
      case 'electricidad':
        return Icons.electrical_services;
      case 'carroceria':
      case 'carrocería':
      case 'chapa':
        return Icons.directions_car;
      case 'neumaticos':
      case 'neumáticos':
      case 'llantas':
        return Icons.tire_repair;
      case 'aceites':
      case 'lubricantes':
        return Icons.opacity;
      default:
        return Icons.build;
    }
  }

  // Sombras personalizadas
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryBlue.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryBlue.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get yellowAccentShadow => [
    BoxShadow(
      color: secondaryYellow.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}
