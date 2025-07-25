import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_storage.dart';

class ApiServiceJWT {
  static String get baseUrl => AppConfig.baseUrl;

  // Obtener headers con JWT
  static Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  // Refrescar token si es necesario
  static Future<bool> _refreshTokenIfNeeded() async {
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
      }

      // Si el refresh token también expiró, limpiar todo
      await TokenStorage.clearTokens();
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      await TokenStorage.clearTokens();
      return false;
    }
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('🌐 GET: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      print('📊 Response status: ${response.statusCode}');

      // Si el token expiró, intentar refrescar
      if (response.statusCode == 401) {
        print('🔄 Token expirado, intentando refrescar...');
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          // Reintentar con el nuevo token
          final newHeaders = await _getHeaders();
          final retryResponse = await http.get(url, headers: newHeaders);
          print('🔄 Retry response status: ${retryResponse.statusCode}');
          return retryResponse;
        } else {
          print('❌ No se pudo refrescar el token');
        }
      }

      return response;
    } catch (e) {
      print('❌ Error en GET $url: $e');
      rethrow;
    }
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('🌐 POST: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );

      print('📊 Response status: ${response.statusCode}');

      // Si el token expiró, intentar refrescar
      if (response.statusCode == 401) {
        print('🔄 Token expirado, intentando refrescar...');
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          // Reintentar con el nuevo token
          final newHeaders = await _getHeaders();
          final retryResponse = await http.post(
            url,
            headers: newHeaders,
            body: json.encode(data),
          );
          print('🔄 Retry response status: ${retryResponse.statusCode}');
          return retryResponse;
        }
      }

      return response;
    } catch (e) {
      print('❌ Error en POST $url: $e');
      rethrow;
    }
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('🌐 PUT: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );

      print('📊 Response status: ${response.statusCode}');

      // Si el token expiró, intentar refrescar
      if (response.statusCode == 401) {
        print('🔄 Token expirado, intentando refrescar...');
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          final newHeaders = await _getHeaders();
          final retryResponse = await http.put(
            url,
            headers: newHeaders,
            body: json.encode(data),
          );
          print('🔄 Retry response status: ${retryResponse.statusCode}');
          return retryResponse;
        }
      }

      return response;
    } catch (e) {
      print('❌ Error en PUT $url: $e');
      rethrow;
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('🌐 DELETE: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);

      print('📊 Response status: ${response.statusCode}');

      // Si el token expiró, intentar refrescar
      if (response.statusCode == 401) {
        print('🔄 Token expirado, intentando refrescar...');
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          final newHeaders = await _getHeaders();
          final retryResponse = await http.delete(url, headers: newHeaders);
          print('🔄 Retry response status: ${retryResponse.statusCode}');
          return retryResponse;
        }
      }

      return response;
    } catch (e) {
      print('❌ Error en DELETE $url: $e');
      rethrow;
    }
  }

  // Método para verificar si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    return await TokenStorage.hasTokens();
  }

  // Método para limpiar autenticación
  static Future<void> clearAuth() async {
    await TokenStorage.clearTokens();
  }
}
