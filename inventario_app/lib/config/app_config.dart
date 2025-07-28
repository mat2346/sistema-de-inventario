class AppConfig {
  // Configuración del backend - URL DE PRODUCCIÓN EN KOYEB
  static String get baseUrl {
    // URL de producción en Koyeb
    return 'https://honest-sibley-jssre-3d530483.koyeb.app/api';

    // Para desarrollo local, puedes comentar la línea de arriba y descomentar las siguientes:
    /*
    import 'dart:io';
    import 'package:flutter/foundation.dart';
    
    if (kIsWeb) {
      // Para web usar localhost
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      // Para Android emulador usar la IP especial del host
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      // Para iOS simulator
      return 'http://localhost:8000/api';
    } else {
      // Para Windows/Desktop
      return 'http://127.0.0.1:8000/api';
    }
    */
  }

  // URLs específicas del sistema de autenticación ÚNICO
  static Map<String, String> get endpoints {
    final base = baseUrl.replaceAll('/api', '');
    return {
      'login': '$base/api/auth/login/',
      'logout': '$base/api/auth/logout/',
      'session': '$base/api/auth/session/',
      'status': '$base/api/auth/status/',
    };
  }

  // Configuración de la aplicación
  static const String appName = 'Sistema de Inventario';
  static const String version = '1.0.0';

  // Configuración de timeouts
  static const int timeoutDuration = 30; // segundos

  // Configuración de paginación
  static const int itemsPerPage = 20;

  // Configuración de stock bajo
  static const int stockBajoLimite = 10;

  // Credenciales de prueba
  static const Map<String, String> testCredentials = {
    'admin': '123456',
    'vendedor': '123456',
  };
}
