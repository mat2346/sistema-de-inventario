import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Guardar tokens
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    print('💾 TokenStorage.saveTokens() - Iniciando...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    print('💾 TokenStorage.saveTokens() - Tokens guardados');
  }

  // Obtener access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    print(
      '🔍 TokenStorage.getAccessToken() - Token: ${token != null ? "ENCONTRADO" : "NO ENCONTRADO"}',
    );
    return token;
  }

  // Obtener refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_refreshTokenKey);
    print(
      '🔍 TokenStorage.getRefreshToken() - Token: ${token != null ? "ENCONTRADO" : "NO ENCONTRADO"}',
    );
    return token;
  }

  // Limpiar tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Verificar si hay tokens guardados
  static Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }
}
