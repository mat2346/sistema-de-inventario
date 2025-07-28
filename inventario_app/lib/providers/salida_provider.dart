import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/salida.dart';
import '../services/api_service_jwt.dart';
import '../services/jwt_headers.dart';

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
      final headers = await JwtHeaders.getHeaders();
      final response = await http.get(
        Uri.parse('${ApiServiceJWT.baseUrl}/salidas/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);

          if (responseData is List) {
            _salidas =
                responseData.map((json) {
                  return Salida.fromJson(json);
                }).toList();
          } else if (responseData is Map<String, dynamic>) {
            // Si la respuesta es un objeto con resultados paginados
            if (responseData.containsKey('results')) {
              final results = responseData['results'] as List;

              _salidas =
                  results.map((json) {
                    return Salida.fromJson(json);
                  }).toList();
            } else {
              // Si la respuesta es un objeto individual
              _salidas = [Salida.fromJson(responseData)];
            }
          } else {
            _salidas = [];
          }
          _error = null;
        } catch (parseError) {
          _error = 'Error al procesar datos: $parseError';
          _salidas = [];
        }
      } else {
        _error = 'Error al cargar salidas: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSalida(Salida salida) async {
    try {
      final headers = await JwtHeaders.getHeaders();
      final response = await http.post(
        Uri.parse('${ApiServiceJWT.baseUrl}/salidas/'),
        headers: headers,
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
      final headers = await JwtHeaders.getHeaders();
      final response = await http.put(
        Uri.parse('${ApiServiceJWT.baseUrl}/salidas/$id/'),
        headers: headers,
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
      final headers = await JwtHeaders.getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiServiceJWT.baseUrl}/salidas/$id/'),
        headers: headers,
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
