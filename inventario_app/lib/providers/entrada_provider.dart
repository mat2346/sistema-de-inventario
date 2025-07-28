import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/entrada.dart';
import '../services/api_service_jwt.dart';
import '../services/jwt_headers.dart';

class EntradaProvider with ChangeNotifier {
  List<Entrada> _entradas = [];
  bool _isLoading = false;
  String? _error;

  List<Entrada> get entradas => _entradas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEntradas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '${ApiServiceJWT.baseUrl}/entradas/';
      final headers = await JwtHeaders.getHeaders();

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);

          if (responseData is Map<String, dynamic>) {
            // Manejar respuesta paginada del backend Django Rest Framework
            if (responseData.containsKey('results')) {
              final List<dynamic> results = responseData['results'] ?? [];
              _entradas =
                  results.map((json) {
                    try {
                      return Entrada.fromJson(json);
                    } catch (e) {
                      rethrow;
                    }
                  }).toList();
            } else {
              // Si es un objeto individual
              _entradas = [Entrada.fromJson(responseData)];
            }
          } else if (responseData is List) {
            // Si la respuesta es una lista directa
            _entradas =
                responseData.map((json) {
                  try {
                    return Entrada.fromJson(json);
                  } catch (e) {
                    rethrow;
                  }
                }).toList();
          } else {
            _entradas = [];
          }

          _error = null;
        } catch (parseError) {
          _error = 'Error al procesar datos: $parseError';
          _entradas = [];
        }
      } else {
        _error = 'Error al cargar entradas: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntrada(Entrada entrada) async {
    try {
      final headers = await JwtHeaders.getHeaders();
      final response = await http.post(
        Uri.parse('${ApiServiceJWT.baseUrl}/entradas/'),
        headers: headers,
        body: json.encode(entrada.toJson()),
      );

      if (response.statusCode == 201) {
        final newEntrada = Entrada.fromJson(json.decode(response.body));
        _entradas.add(newEntrada);
        notifyListeners();
      } else {
        throw Exception('Error al crear entrada: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> updateEntrada(int id, Entrada entrada) async {
    try {
      final headers = await JwtHeaders.getHeaders();
      final response = await http.put(
        Uri.parse('${ApiServiceJWT.baseUrl}/entradas/$id/'),
        headers: headers,
        body: json.encode(entrada.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedEntrada = Entrada.fromJson(json.decode(response.body));
        final index = _entradas.indexWhere((e) => e.id == id);
        if (index != -1) {
          _entradas[index] = updatedEntrada;
          notifyListeners();
        }
      } else {
        throw Exception('Error al actualizar entrada: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteEntrada(int id) async {
    try {
      final headers = await JwtHeaders.getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiServiceJWT.baseUrl}/entradas/$id/'),
        headers: headers,
      );

      if (response.statusCode == 204) {
        _entradas.removeWhere((entrada) => entrada.id == id);
        notifyListeners();
      } else {
        throw Exception('Error al eliminar entrada: ${response.statusCode}');
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
