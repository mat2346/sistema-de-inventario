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
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
      print(
        '🔑 JWT Header agregado: Bearer ${accessToken.substring(0, 20)}...',
      );
    } else {
      print('⚠️ No hay token JWT disponible');
    }

    return headers;
  }
}
