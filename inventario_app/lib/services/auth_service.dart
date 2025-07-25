import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/empleado.dart';
import '../models/auth_session.dart';

class AuthService {
  static const String _sessionKeyPrefs = 'session_key';
  static const String _empleadoDataPrefs = 'empleado_data';

  // Headers para mantener la sesión
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Login del empleado
  Future<AuthSession> login(String nombre, String password) async {
    try {
      final loginUrl = AppConfig.endpoints['login']!;
      print('🔗 Intentando login en: $loginUrl'); // Debug log para URL

      final loginRequest = LoginRequest(nombre: nombre, password: password);

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: _headers,
        body: json.encode(loginRequest.toJson()),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final authSession = AuthSession.fromJson(data);

        // Guardar datos de sesión localmente
        await _saveSessionData(authSession);

        return authSession;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error en el login');
      }
    } catch (e) {
      print('Error en login: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  /// Logout del empleado
  Future<String> logout() async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.endpoints['logout']!),
        headers: _headers,
      );

      print('Logout response status: ${response.statusCode}');
      print('Logout response body: ${response.body}');

      // Limpiar datos locales independientemente del resultado
      await _clearSessionData();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['message'] ?? 'Sesión cerrada';
      } else {
        return 'Sesión cerrada localmente';
      }
    } catch (e) {
      print('Error en logout: $e');
      await _clearSessionData();
      return 'Sesión cerrada localmente';
    }
  }

  /// Verificar sesión actual
  Future<AuthSession> checkSession() async {
    try {
      // Primero verificar si hay datos guardados localmente
      final localSession = await _getLocalSession();
      if (localSession == null) {
        return AuthSession(
          authenticated: false,
          message: 'No hay sesión local',
        );
      }

      final response = await http.get(
        Uri.parse(AppConfig.endpoints['session']!),
        headers: _headers,
      );

      print('Check session response status: ${response.statusCode}');
      print('Check session response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final authSession = AuthSession.fromJson(data);

        // Actualizar datos locales
        await _saveSessionData(authSession);

        return authSession;
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        // Sesión expirada o inválida
        await _clearSessionData();
        return AuthSession(authenticated: false, message: 'Sesión expirada');
      } else {
        // Usar datos locales si hay problema de red
        return localSession;
      }
    } catch (e) {
      print('Error verificando sesión: $e');

      // Intentar usar datos locales
      final localSession = await _getLocalSession();
      if (localSession != null) {
        return localSession;
      }

      return AuthSession(authenticated: false, message: 'Error de conexión');
    }
  }

  /// Verificar estado de autenticación (público)
  Future<bool> isAuthenticated() async {
    try {
      final response = await http.get(
        Uri.parse(AppConfig.endpoints['status']!),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['authenticated'] ?? false;
      }

      return false;
    } catch (e) {
      print('Error verificando autenticación: $e');

      // Verificar datos locales como fallback
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_empleadoDataPrefs);
    }
  }

  /// Guardar datos de sesión localmente
  Future<void> _saveSessionData(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();

    if (session.sessionKey != null) {
      await prefs.setString(_sessionKeyPrefs, session.sessionKey!);
    }

    if (session.empleado != null) {
      await prefs.setString(
        _empleadoDataPrefs,
        json.encode(session.empleado!.toJson()),
      );
    }
  }

  /// Obtener sesión guardada localmente
  Future<AuthSession?> _getLocalSession() async {
    final prefs = await SharedPreferences.getInstance();

    final empleadoDataString = prefs.getString(_empleadoDataPrefs);
    if (empleadoDataString != null) {
      final empleadoData = json.decode(empleadoDataString);
      final empleado = Empleado.fromJson(empleadoData);

      return AuthSession(
        authenticated: true,
        empleado: empleado,
        sessionKey: prefs.getString(_sessionKeyPrefs),
      );
    }

    return null;
  }

  /// Limpiar datos de sesión
  Future<void> _clearSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKeyPrefs);
    await prefs.remove(_empleadoDataPrefs);
  }

  /// Obtener empleado actual (si está logueado)
  Future<Empleado?> getCurrentEmpleado() async {
    final session = await _getLocalSession();
    return session?.empleado;
  }
}
