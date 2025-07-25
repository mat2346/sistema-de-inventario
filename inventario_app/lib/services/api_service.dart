import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_storage.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

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

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('GET: $url'); // Para debug

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Verificar si el token expiró
      if (response.statusCode == 401) {
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          // Reintentar con el nuevo token
          final newHeaders = await _getHeaders();
          final retryResponse = await http.get(url, headers: newHeaders);
          print('Retry response status: ${retryResponse.statusCode}');
          return retryResponse;
        }
      }

      return response;
    } catch (e) {
      print('Error en GET $url: $e');
      rethrow;
    }
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('POST: $url');
    print('Data: ${json.encode(data)}');

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Verificar si el token expiró
      if (response.statusCode == 401) {
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          // Reintentar con el nuevo token
          final newHeaders = await _getHeaders();
          final retryResponse = await http.post(
            url,
            headers: newHeaders,
            body: json.encode(data),
          );
          print('Retry response status: ${retryResponse.statusCode}');
          return retryResponse;
        }
      }

      return response;
    } catch (e) {
      print('Error en POST $url: $e');
      rethrow;
    }
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('PUT: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );

      print('Response status: ${response.statusCode}');

      // Verificar si el token expiró
      if (response.statusCode == 401) {
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          final newHeaders = await _getHeaders();
          final retryResponse = await http.put(
            url,
            headers: newHeaders,
            body: json.encode(data),
          );
          print('Retry response status: ${retryResponse.statusCode}');
          return retryResponse;
        }
      }

      return response;
    } catch (e) {
      print('Error en PUT $url: $e');
      rethrow;
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('DELETE: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);

      print('Response status: ${response.statusCode}');

      // Verificar si el token expiró
      if (response.statusCode == 401) {
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          final newHeaders = await _getHeaders();
          final retryResponse = await http.delete(url, headers: newHeaders);
          print('Retry response status: ${retryResponse.statusCode}');
          return retryResponse;
        }
      }

      return response;
    } catch (e) {
      print('Error en DELETE $url: $e');
      rethrow;
    }
  }

  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    print('PATCH: $url');

    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode(data),
      );

      print('Response status: ${response.statusCode}');

      // Verificar si el token expiró
      if (response.statusCode == 401) {
        final refreshed = await _refreshTokenIfNeeded();
        if (refreshed) {
          final newHeaders = await _getHeaders();
          final retryResponse = await http.patch(
            url,
            headers: newHeaders,
            body: json.encode(data),
          );
          print('Retry response status: ${retryResponse.statusCode}');
          return retryResponse;
        }
      }

      return response;
    } catch (e) {
      print('Error en PATCH $url: $e');
      rethrow;
    }
  }

  // Método actualizado para manejar listas con paginación de DRF
  static Future<List<T>> handleListRequest<T>(
    Future<http.Response> request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic responseData = json.decode(response.body);

        // Si la respuesta es directamente una lista
        if (responseData is List) {
          return responseData
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
        }

        // Si la respuesta tiene paginación de DRF (con 'results')
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('results')) {
            final List<dynamic> results =
                responseData['results'] as List<dynamic>;
            return results
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList();
          }

          // Si es un mapa pero no tiene 'results', intentar convertir directamente
          return [fromJson(responseData)];
        }

        throw Exception('Formato de respuesta no reconocido: ${response.body}');
      } else {
        throw Exception(
          'Error del servidor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error en handleListRequest: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<T> handleRequest<T>(
    Future<http.Response> request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return fromJson(responseData);
      } else {
        throw Exception(
          'Error del servidor: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error en handleRequest: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
