import 'package:flutter/material.dart';
import '../models/proveedor.dart';
import '../services/api_service_jwt.dart';

class ProveedorProviderJWT with ChangeNotifier {
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
      
      _proveedores = await ApiServiceJWT.handleListRequest<Proveedor>(
        ApiServiceJWT.get('/proveedores/'),
        (json) => Proveedor.fromJson(json),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProveedor(Proveedor proveedor) async {
    try {
      final nuevoProveedor = await ApiServiceJWT.handleRequest<Proveedor>(
        ApiServiceJWT.post('/proveedores/', proveedor.toJson()),
        (json) => Proveedor.fromJson(json),
      );

      _proveedores.add(nuevoProveedor);
      notifyListeners();
    } catch (e) {
      ('❌ Error creando proveedor: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProveedor(int id, Proveedor proveedor) async {
    try {
      final updatedProveedor = await ApiServiceJWT.handleRequest<Proveedor>(
        ApiServiceJWT.put('/proveedores/$id/', proveedor.toJson()),
        (json) => Proveedor.fromJson(json),
      );

      final index = _proveedores.indexWhere((p) => p.id == id);
      if (index != -1) {
        _proveedores[index] = updatedProveedor;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProveedor(int id) async {
    try {
      final response = await ApiServiceJWT.delete('/proveedores/$id/');

      if (response.statusCode == 204) {
        _proveedores.removeWhere((proveedor) => proveedor.id == id);
        notifyListeners();
      } else {
        throw Exception('Error al eliminar proveedor: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
