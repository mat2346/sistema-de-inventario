import '../models/inventario.dart';
import 'api_service.dart';

class InventarioService {
  static const String endpoint = '/inventario';

  static Future<List<Inventario>> getInventarios() async {
    return ApiService.handleListRequest<Inventario>(
      ApiService.get('$endpoint/'),
      (json) => Inventario.fromJson(json),
    );
  }

  static Future<Inventario> getInventario(int id) async {
    return ApiService.handleRequest<Inventario>(
      ApiService.get('$endpoint/$id/'),
      (json) => Inventario.fromJson(json),
    );
  }

  static Future<Inventario> createInventario(Inventario inventario) async {
    return ApiService.handleRequest<Inventario>(
      ApiService.post('$endpoint/', inventario.toJson()),
      (json) => Inventario.fromJson(json),
    );
  }

  static Future<Inventario> updateInventario(int id, Inventario inventario) async {
    return ApiService.handleRequest<Inventario>(
      ApiService.put('$endpoint/$id/', inventario.toJson()),
      (json) => Inventario.fromJson(json),
    );
  }

  static Future<bool> deleteInventario(int id) async {
    try {
      final response = await ApiService.delete('$endpoint/$id/');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  // Métodos específicos para el manejo de stock
  static Future<List<Inventario>> getInventarioByProducto(int productoId) async {
    return ApiService.handleListRequest<Inventario>(
      ApiService.get('$endpoint/?producto=$productoId'),
      (json) => Inventario.fromJson(json),
    );
  }

  static Future<List<Inventario>> getInventarioBySucursal(int sucursalId) async {
    return ApiService.handleListRequest<Inventario>(
      ApiService.get('$endpoint/?sucursal=$sucursalId'),
      (json) => Inventario.fromJson(json),
    );
  }

  static Future<Inventario> updateStock(int inventarioId, int nuevaCantidad) async {
    return ApiService.handleRequest<Inventario>(
      ApiService.patch('$endpoint/$inventarioId/', {'cantidad_actual': nuevaCantidad}),
      (json) => Inventario.fromJson(json),
    );
  }
}
