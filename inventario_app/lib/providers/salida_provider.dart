import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/salida.dart';
import '../services/api_service.dart';

class SalidaProvider with ChangeNotifier {
  List<Salida> _salidas = [];
  bool _isLoading = false;
  String? _error;

  List<Salida> get salidas => _salidas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSalidas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 Cargando salidas desde: ${ApiService.baseUrl}/salidas/');
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/salidas/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);
          print('📊 Decoded data type: ${responseData.runtimeType}');

          if (responseData is List) {
            print('📊 Processing ${responseData.length} salidas...');
            _salidas =
                responseData.map((json) {
                  print('🔍 Processing salida: $json');
                  return Salida.fromJson(json);
                }).toList();
          } else if (responseData is Map<String, dynamic>) {
            // Si la respuesta es un objeto con resultados paginados
            if (responseData.containsKey('results')) {
              final results = responseData['results'] as List;
              print(
                '📊 Processing ${results.length} salidas from paginated response...',
              );
              _salidas =
                  results.map((json) {
                    print('🔍 Processing salida: $json');
                    return Salida.fromJson(json);
                  }).toList();
            } else {
              // Si la respuesta es un objeto individual
              print('📊 Processing single salida object...');
              _salidas = [Salida.fromJson(responseData)];
            }
          } else {
            print('⚠️ Unexpected response format');
            _salidas = [];
          }
          print('✅ Salidas cargadas: ${_salidas.length}');
          _error = null;
        } catch (parseError) {
          print('❌ Error al procesar datos: $parseError');
          _error = 'Error al procesar datos: $parseError';
          _salidas = [];
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        _error = 'Error al cargar salidas: ${response.statusCode}';
      }
    } catch (e) {
      print('❌ Error de conexión: $e');
      _error = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSalida(Salida salida) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/salidas/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(salida.toJson()),
      );

      if (response.statusCode == 201) {
        final newSalida = Salida.fromJson(json.decode(response.body));
        _salidas.add(newSalida);
        notifyListeners();
      } else {
        throw Exception('Error al crear salida: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> updateSalida(int id, Salida salida) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/salidas/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(salida.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedSalida = Salida.fromJson(json.decode(response.body));
        final index = _salidas.indexWhere((s) => s.id == id);
        if (index != -1) {
          _salidas[index] = updatedSalida;
          notifyListeners();
        }
      } else {
        throw Exception('Error al actualizar salida: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteSalida(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/salidas/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        _salidas.removeWhere((salida) => salida.id == id);
        notifyListeners();
      } else {
        throw Exception('Error al eliminar salida: ${response.statusCode}');
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
