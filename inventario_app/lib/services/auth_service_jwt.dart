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
      final url = '$baseUrl/auth/login/';
   

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'nombre': nombre, 'password': password}),
      );

      

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
      print('💥 AuthService Error: $e');
      return {
        'success': false,
        'message': 'Error de conexión: ${e.toString()}',
      };
    }
  }

  /// Logout con JWT
  static Future<Map<String, dynamic>> logout() async {
    try {
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

        if (response.statusCode == 200) {
          await TokenStorage.clearTokens();
          return {'success': true, 'message': 'Sesión cerrada exitosamente'};
        }
      }

      // Limpiar tokens locales independientemente de la respuesta del servidor
      await TokenStorage.clearTokens();

      return {'success': true, 'message': 'Sesión cerrada exitosamente'};
    } catch (e) {
      // Aún así limpiar tokens locales
      await TokenStorage.clearTokens();
      return {'success': true, 'message': 'Sesión cerrada localmente'};
    }
  }

  /// Verificar sesión actual con JWT
  static Future<Map<String, dynamic>> checkSession() async {
    try {
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

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await TokenStorage.saveTokens(
          data['access'],
          data['refresh'] ?? refreshToken,
        );
        return true;
      } else {
        return false;
      }
    } catch (e) {
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
