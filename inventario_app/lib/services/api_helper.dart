import '../services/api_service_jwt.dart';
import 'dart:convert';

/// Helper para migrar providers de http directo a ApiServiceJWT
class ApiHelper {
  /// GET request con JWT automático
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await ApiServiceJWT.get(endpoint);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Error del servidor: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// POST request con JWT automático
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiServiceJWT.post(endpoint, data);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Error del servidor: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// PUT request con JWT automático
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiServiceJWT.put(endpoint, data);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Error del servidor: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// DELETE request con JWT automático
  static Future<bool> delete(String endpoint) async {
    final response = await ApiServiceJWT.delete(endpoint);
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
