import '../models/categoria.dart';
import 'api_service.dart';

class CategoriaService {
  static const String endpoint = '/categorias';

  static Future<List<Categoria>> getCategorias() async {
    return ApiService.handleListRequest<Categoria>(
      ApiService.get('$endpoint/'),
      (json) => Categoria.fromJson(json),
    );
  }

  static Future<Categoria> getCategoria(int id) async {
    return ApiService.handleRequest<Categoria>(
      ApiService.get('$endpoint/$id/'),
      (json) => Categoria.fromJson(json),
    );
  }

  static Future<Categoria> createCategoria(Categoria categoria) async {
    return ApiService.handleRequest<Categoria>(
      ApiService.post('$endpoint/', categoria.toJson()),
      (json) => Categoria.fromJson(json),
    );
  }

  static Future<Categoria> updateCategoria(int id, Categoria categoria) async {
    return ApiService.handleRequest<Categoria>(
      ApiService.put('$endpoint/$id/', categoria.toJson()),
      (json) => Categoria.fromJson(json),
    );
  }

  static Future<bool> deleteCategoria(int id) async {
    try {
      final response = await ApiService.delete('$endpoint/$id/');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }
}
