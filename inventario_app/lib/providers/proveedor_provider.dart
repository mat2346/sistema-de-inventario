import 'package:flutter/material.dart';
import '../models/proveedor.dart';
import '../services/api_service_jwt.dart';

class ProveedorProvider with ChangeNotifier {
  List<Proveedor> _proveedores = [];
  bool _isLoading = false;
  String? _error;

  List<Proveedor> get proveedores => _proveedores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProveedores() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _proveedores = await ApiServiceJWT.handleListRequest(
        ApiServiceJWT.get('/proveedores/'),
        (json) => Proveedor.fromJson(json),
      );
    } catch (e) {
      _error = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProveedor(Proveedor proveedor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newProveedor = await ApiServiceJWT.handleRequest(
        ApiServiceJWT.post('/proveedores/', proveedor.toJson()),
        (json) => Proveedor.fromJson(json),
      );
      _proveedores.add(newProveedor);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error de conexión: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> updateProveedor(Proveedor proveedor) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedProveedor = await ApiServiceJWT.handleRequest(
        ApiServiceJWT.put('/proveedores/${proveedor.id}/', proveedor.toJson()),
        (json) => Proveedor.fromJson(json),
      );
      final index = _proveedores.indexWhere((p) => p.id == proveedor.id);
      if (index != -1) {
        _proveedores[index] = updatedProveedor;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Error de conexión: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<bool> deleteProveedor(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiServiceJWT.delete('/proveedores/$id/');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _proveedores.removeWhere((proveedor) => proveedor.id == id);
        notifyListeners();
        return true;
      } else {
        _error = 'Error al eliminar proveedor';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearProveedores() {
    _proveedores.clear();
    notifyListeners();
  }
}
