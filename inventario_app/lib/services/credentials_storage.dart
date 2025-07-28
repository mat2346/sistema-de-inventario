import 'package:shared_preferences/shared_preferences.dart';

class CredentialsStorage {
  static const String _usernameKey = 'saved_username';
  static const String _passwordKey = 'saved_password';
  static const String _rememberKey = 'remember_credentials';

  /// Guardar credenciales
  static Future<void> saveCredentials({
    required String username,
    required String password,
    required bool remember,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (remember) {
      await prefs.setString(_usernameKey, username);
      await prefs.setString(_passwordKey, password);
      await prefs.setBool(_rememberKey, true);
    } else {
      await clearCredentials();
    }
  }

  /// Obtener credenciales guardadas
  static Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();

    final remember = prefs.getBool(_rememberKey) ?? false;
    final username = prefs.getString(_usernameKey) ?? '';
    final password = prefs.getString(_passwordKey) ?? '';

    return {'username': username, 'password': password, 'remember': remember};
  }

  /// Verificar si hay credenciales guardadas
  static Future<bool> hasCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberKey) ?? false;
    final username = prefs.getString(_usernameKey) ?? '';

    return remember && username.isNotEmpty;
  }

  /// Limpiar credenciales guardadas
  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
    await prefs.remove(_passwordKey);
    await prefs.setBool(_rememberKey, false);
  }

  /// Obtener solo el username guardado (para autocompletado)
  static Future<String> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? '';
  }
}
