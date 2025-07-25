import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/empleado.dart';
import 'token_storage.dart';

class AuthServiceJWT {
  static String get baseUrl => AppConfig.baseUrl;

  /// Login con JWT
  static Future<Map<String, dynamic>> login(
    String nombre,
    String password,
  ) async {
    try {
      print('🔐 Iniciando login JWT para: $nombre');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'nombre': nombre, 'password': password}),
      );

      print('📊 Login response status: ${response.statusCode}');
      print('📄 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['authenticated'] == true && data['tokens'] != null) {
          // Guardar tokens JWT
          await TokenStorage.saveTokens(
            data['tokens']['access'],
            data['tokens']['refresh'],
          );

          // Crear empleado desde la respuesta
          final empleado = Empleado.fromJson(data['empleado']);

          return {
            'success': true,
            'empleado': empleado,
            'message': data['message'],
            'tokens': data['tokens'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Error de autenticación',
          };
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Error del servidor',
        };
      }
    } catch (e) {
      print('❌ Error en login: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Logout con JWT
  static Future<Map<String, dynamic>> logout() async {
    try {
      print('🚪 Iniciando logout JWT');

      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/auth/logout/'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await TokenStorage.getAccessToken()}',
          },
          body: json.encode({'refresh_token': refreshToken}),
        );

        print('📊 Logout response status: ${response.statusCode}');
      }

      // Limpiar tokens locales independientemente de la respuesta del servidor
      await TokenStorage.clearTokens();

      return {'success': true, 'message': 'Sesión cerrada exitosamente'};
    } catch (e) {
      print('❌ Error en logout: $e');
      // Aún así limpiar tokens locales
      await TokenStorage.clearTokens();
      return {'success': true, 'message': 'Sesión cerrada localmente'};
    }
  }

  /// Verificar sesión actual con JWT
  static Future<Map<String, dynamic>> checkSession() async {
    try {
      print('🔍 Verificando sesión JWT');

      final accessToken = await TokenStorage.getAccessToken();
      if (accessToken == null) {
        return {'authenticated': false, 'message': 'No hay token de acceso'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/session/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('📊 Session check response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['authenticated'] == true) {
          final empleado = Empleado.fromJson(data['empleado']);
          return {
            'authenticated': true,
            'empleado': empleado,
            'token_info': data['token_info'],
          };
        }
      } else if (response.statusCode == 401) {
        // Token expirado, intentar refrescar
        print('🔄 Token expirado, intentando refrescar...');
        final refreshSuccess = await _refreshToken();
        if (refreshSuccess) {
          // Reintentar verificación de sesión
          return await checkSession();
        } else {
          await TokenStorage.clearTokens();
          return {
            'authenticated': false,
            'message': 'Token expirado y no se pudo refrescar',
          };
        }
      }

      return {'authenticated': false, 'message': 'Sesión inválida'};
    } catch (e) {
      print('❌ Error verificando sesión: $e');
      return {
        'authenticated': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Refrescar token JWT
  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      print('🔄 Refrescando token JWT...');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'refresh': refreshToken}),
      );

      print('📊 Refresh response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await TokenStorage.saveTokens(
          data['access'],
          data['refresh'] ?? refreshToken,
        );
        print('✅ Token refrescado exitosamente');
        return true;
      } else {
        print('❌ Error al refrescar token: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error en refresh token: $e');
      return false;
    }
  }

  /// Verificar si hay tokens guardados
  static Future<bool> hasValidTokens() async {
    return await TokenStorage.hasTokens();
  }

  /// Limpiar autenticación
  static Future<void> clearAuth() async {
    await TokenStorage.clearTokens();
  }
}
