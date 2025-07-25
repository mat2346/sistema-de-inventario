import '../models/sucursal.dart';
import 'api_service.dart';

class SucursalService {
  static const String endpoint = '/sucursales';

  static Future<List<Sucursal>> getSucursales() async {
    return ApiService.handleListRequest<Sucursal>(
      ApiService.get('$endpoint/'),
      (json) => Sucursal.fromJson(json),
    );
  }

  static Future<Sucursal> getSucursal(int id) async {
    return ApiService.handleRequest<Sucursal>(
      ApiService.get('$endpoint/$id/'),
      (json) => Sucursal.fromJson(json),
    );
  }

  static Future<Sucursal> createSucursal(Sucursal sucursal) async {
    return ApiService.handleRequest<Sucursal>(
      ApiService.post('$endpoint/', sucursal.toJson()),
      (json) => Sucursal.fromJson(json),
    );
  }

  static Future<Sucursal> updateSucursal(int id, Sucursal sucursal) async {
    return ApiService.handleRequest<Sucursal>(
      ApiService.put('$endpoint/$id/', sucursal.toJson()),
      (json) => Sucursal.fromJson(json),
    );
  }

  static Future<bool> deleteSucursal(int id) async {
    try {
      final response = await ApiService.delete('$endpoint/$id/');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }
}
