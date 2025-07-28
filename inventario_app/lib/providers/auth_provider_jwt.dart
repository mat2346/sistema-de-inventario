import 'package:flutter/material.dart';
import '../models/empleado.dart';
import '../services/auth_service_jwt.dart';
import '../services/token_storage.dart';
import '../services/credentials_storage.dart';

class AuthProviderJWT extends ChangeNotifier {
  Empleado? _currentEmpleado;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  // Getters
  Empleado? get currentEmpleado => _currentEmpleado;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  /// Inicializar el provider verificando si hay tokens guardados
  Future<void> initialize() async {
    _setLoading(true);

    try {
      final hasTokens = await TokenStorage.hasTokens();
      if (hasTokens) {
        await checkCurrentSession();
      } else {
        _setAuthenticated(false);
      }
    } catch (e) {
      _setError('Error de inicialización');
    } finally {
      _setLoading(false);
    }
  }

  /// Login con JWT
  Future<bool> login(String nombre, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await AuthServiceJWT.login(nombre, password);

      if (result['success']) {
        _currentEmpleado = result['empleado'];
        _setAuthenticated(true);
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout con JWT
  Future<void> logout({bool clearSavedCredentials = false}) async {
    _setLoading(true);

    try {
      await AuthServiceJWT.logout();

      // Limpiar credenciales guardadas si se solicita
      if (clearSavedCredentials) {
        await CredentialsStorage.clearCredentials();
      }

      _currentEmpleado = null;
      _setAuthenticated(false);
    } catch (e) {
      // Aún así limpiar el estado local
      _currentEmpleado = null;
      _setAuthenticated(false);
    } finally {
      _setLoading(false);
    }
  }

  /// Verificar sesión actual
  Future<void> checkCurrentSession() async {
    try {
      final result = await AuthServiceJWT.checkSession();

      if (result['authenticated']) {
        _currentEmpleado = result['empleado'];
        _setAuthenticated(true);
      } else {
        _currentEmpleado = null;
        _setAuthenticated(false);
      }
    } catch (e) {
      _currentEmpleado = null;
      _setAuthenticated(false);
    }
  }

  /// Verificar si hay tokens válidos
  Future<bool> hasValidTokens() async {
    return await AuthServiceJWT.hasValidTokens();
  }

  /// Limpiar error
  void clearError() {
    _setError(null);
  }

  // Métodos privados para actualizar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Obtener información del empleado actual
  String get empleadoNombre => _currentEmpleado?.nombre ?? 'Usuario';
  String get empleadoCargo => _currentEmpleado?.cargo ?? 'Sin cargo';
  String? get empleadoSucursal => _currentEmpleado?.sucursalNombre;
  int? get empleadoId => _currentEmpleado?.id;

  /// Verificar si es administrador
  bool get isAdmin => _currentEmpleado?.cargo.toLowerCase() == 'administrador';

  /// Verificar si es vendedor
  bool get isVendedor => _currentEmpleado?.cargo.toLowerCase() == 'vendedor';

  @override
  void dispose() {
    super.dispose();
  }
}
