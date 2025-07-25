import 'package:flutter/material.dart';
import '../models/empleado.dart';
import '../models/auth_session.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  Empleado? _currentEmpleado;
  String? _error;
  String? _message;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  Empleado? get currentEmpleado => _currentEmpleado;
  String? get error => _error;
  String? get message => _message;

  // Información del usuario actual
  String get userDisplayName => _currentEmpleado?.nombreCompleto ?? 'Usuario';
  String get userCargo => _currentEmpleado?.cargo ?? '';
  String get userSucursal => _currentEmpleado?.sucursalNombre ?? 'Sin sucursal';

  /// Login del empleado
  Future<bool> login(String nombre, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final authSession = await _authService.login(nombre, password);

      if (authSession.authenticated && authSession.empleado != null) {
        _isAuthenticated = true;
        _currentEmpleado = authSession.empleado;
        _message = authSession.message;

        notifyListeners();
        return true;
      } else {
        _setError(authSession.message ?? 'Error en el login');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout del empleado
  Future<void> logout() async {
    _setLoading(true);

    try {
      final message = await _authService.logout();
      _message = message;

      _isAuthenticated = false;
      _currentEmpleado = null;
      _clearError();

      notifyListeners();
    } catch (e) {
      // Incluso si hay error, limpiamos la sesión local
      _isAuthenticated = false;
      _currentEmpleado = null;
      print('Error en logout: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Verificar sesión actual
  Future<void> checkSession() async {
    _setLoading(true);

    try {
      final authSession = await _authService.checkSession();

      _isAuthenticated = authSession.authenticated;
      _currentEmpleado = authSession.empleado;

      if (!authSession.authenticated) {
        _setError(authSession.message);
      } else {
        _clearError();
      }

      notifyListeners();
    } catch (e) {
      _setError('Error verificando sesión: ${e.toString()}');
      _isAuthenticated = false;
      _currentEmpleado = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Verificar si hay una sesión activa (más rápido)
  Future<bool> quickAuthCheck() async {
    try {
      return await _authService.isAuthenticated();
    } catch (e) {
      print('Error en quick auth check: $e');
      return false;
    }
  }

  /// Inicializar - verificar sesión al iniciar la app
  Future<void> initialize() async {
    await checkSession();
  }

  /// Limpiar error
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Limpiar mensaje
  void clearMessage() {
    _message = null;
    notifyListeners();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
