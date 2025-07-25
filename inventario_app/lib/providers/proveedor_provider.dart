import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/proveedor.dart';
import '../services/api_service.dart';

class ProveedorProvider with ChangeNotifier {
  List<Proveedor> _proveedores = [];
  bool _isLoading = false;
  String? _error;

  List<Proveedor> get proveedores => _proveedores;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProveedores() async {
    print('🔄 ProveedorProvider: Iniciando carga de proveedores...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '${ApiService.baseUrl}/proveedores/';
      print('🔄 ProveedorProvider: URL a llamar: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔄 ProveedorProvider: Status code: ${response.statusCode}');
      print('🔄 ProveedorProvider: Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);

          print(
            '🔍 ProveedorProvider: Response data type: ${responseData.runtimeType}',
          );
          print('🔍 ProveedorProvider: Response data: $responseData');

          if (responseData is Map<String, dynamic>) {
            // Manejar respuesta paginada del backend Django Rest Framework
            if (responseData.containsKey('results')) {
              final List<dynamic> results = responseData['results'] ?? [];
              _proveedores =
                  results.map((json) => Proveedor.fromJson(json)).toList();
              print(
                '🔍 ProveedorProvider: Respuesta paginada procesada - ${_proveedores.length} proveedores',
              );
            } else {
              // Si es un objeto individual
              _proveedores = [Proveedor.fromJson(responseData)];
              print('🔍 ProveedorProvider: Objeto individual procesado');
            }
          } else if (responseData is List) {
            // Si la respuesta es una lista directa
            _proveedores =
                responseData.map((json) => Proveedor.fromJson(json)).toList();
            print(
              '🔍 ProveedorProvider: Lista directa procesada - ${_proveedores.length} proveedores',
            );
          } else {
            print('🔍 ProveedorProvider: Formato de respuesta no reconocido');
            _proveedores = [];
          }

          print(
            '🔍 ProveedorProvider: Proveedores cargados: ${_proveedores.map((p) => '${p.id}: ${p.nombre}').toList()}',
          );
          _error = null;
        } catch (parseError) {
          print('❌ ProveedorProvider: Error al parsear: $parseError');
          _error = 'Error al procesar datos: $parseError';
          _proveedores = [];
        }
      } else {
        print('❌ ProveedorProvider: Error HTTP ${response.statusCode}');
        _error = 'Error al cargar proveedores: ${response.statusCode}';
      }
    } catch (e) {
      print('❌ ProveedorProvider: Error de conexión: $e');
      _error = 'Error de conexión: $e';
    } finally {
      print('🔄 ProveedorProvider: Finalizando carga - isLoading: false');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProveedor(Proveedor proveedor) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/proveedores/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(proveedor.toJson()),
      );

      if (response.statusCode == 201) {
        final newProveedor = Proveedor.fromJson(json.decode(response.body));
        _proveedores.add(newProveedor);
        notifyListeners();
      } else {
        throw Exception('Error al crear proveedor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> updateProveedor(int id, Proveedor proveedor) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/proveedores/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(proveedor.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedProveedor = Proveedor.fromJson(json.decode(response.body));
        final index = _proveedores.indexWhere((p) => p.id == id);
        if (index != -1) {
          _proveedores[index] = updatedProveedor;
          notifyListeners();
        }
      } else {
        throw Exception(
          'Error al actualizar proveedor: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteProveedor(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/proveedores/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        _proveedores.removeWhere((proveedor) => proveedor.id == id);
        notifyListeners();
      } else {
        throw Exception('Error al eliminar proveedor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
