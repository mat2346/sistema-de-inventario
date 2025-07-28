import '../services/token_storage.dart';

/// Helper para obtener headers con JWT automáticamente
class JwtHeaders {
  /// Obtener headers con JWT para requests HTTP
  static Future<Map<String, String>> getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }
}
