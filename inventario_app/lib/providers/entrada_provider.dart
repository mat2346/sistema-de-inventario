import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/entrada.dart';
import '../services/api_service_jwt.dart';

class EntradaProvider with ChangeNotifier {
  List<Entrada> _entradas = [];
  bool _isLoading = false;
  String? _error;

  List<Entrada> get entradas => _entradas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadEntradas() async {
    print('🔄 EntradaProvider: Iniciando carga de entradas...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = '${ApiServiceJWT.baseUrl}/entradas/';
      print('🔄 EntradaProvider: URL a llamar: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔄 EntradaProvider: Status code: ${response.statusCode}');
      print('🔄 EntradaProvider: Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final dynamic responseData = json.decode(response.body);
          print('📊 Datos de entradas recibidos: $responseData');

          if (responseData is Map<String, dynamic>) {
            // Manejar respuesta paginada del backend Django Rest Framework
            if (responseData.containsKey('results')) {
              final List<dynamic> results = responseData['results'] ?? [];
              _entradas =
                  results.map((json) {
                    try {
                      return Entrada.fromJson(json);
                    } catch (e) {
                      print('❌ Error procesando entrada individual: $e');
                      print('📋 Datos problemáticos: $json');
                      rethrow;
                    }
                  }).toList();
              print(
                '📊 Entradas procesadas desde respuesta paginada: ${_entradas.length}',
              );
            } else {
              // Si es un objeto individual
              _entradas = [Entrada.fromJson(responseData)];
              print('📊 Entrada individual procesada');
            }
          } else if (responseData is List) {
            // Si la respuesta es una lista directa
            _entradas =
                responseData.map((json) {
                  try {
                    return Entrada.fromJson(json);
                  } catch (e) {
                    print('❌ Error procesando entrada individual: $e');
                    print('📋 Datos problemáticos: $json');
                    rethrow;
                  }
                }).toList();
            print(
              '📊 Entradas procesadas desde lista directa: ${_entradas.length}',
            );
          } else {
            print('❌ Formato de respuesta no reconocido para entradas');
            _entradas = [];
          }

          print('📋 Entradas finalmente cargadas: ${_entradas.length}');
          _error = null;
        } catch (parseError) {
          print('❌ Error detallado al procesar datos: $parseError');
          _error = 'Error al procesar datos: $parseError';
          _entradas = [];
        }
      } else {
        print('❌ Error HTTP: ${response.statusCode} - ${response.body}');
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
      final response = await http.post(
        Uri.parse('${ApiServiceJWT.baseUrl}/entradas/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
      final response = await http.put(
        Uri.parse('${ApiServiceJWT.baseUrl}/entradas/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
      final response = await http.delete(
        Uri.parse('${ApiServiceJWT.baseUrl}/entradas/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
