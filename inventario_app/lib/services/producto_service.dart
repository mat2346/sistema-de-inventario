import '../models/producto.dart';
import 'api_service.dart';
import 'image_picker_service.dart';
import 'package:image_picker/image_picker.dart';

class ProductoService {
  static const String endpoint = '/productos';

  static Future<List<Producto>> getProductos() async {
    return ApiService.handleListRequest<Producto>(
      ApiService.get('$endpoint/'),
      (json) => Producto.fromJson(json),
    );
  }

  static Future<Producto> getProducto(int id) async {
    return ApiService.handleRequest<Producto>(
      ApiService.get('$endpoint/$id/'),
      (json) => Producto.fromJson(json),
    );
  }

  static Future<Producto> createProducto(Producto producto) async {
    return ApiService.handleRequest<Producto>(
      ApiService.post('$endpoint/', producto.toJson()),
      (json) => Producto.fromJson(json),
    );
  }

  static Future<Producto> updateProducto(int id, Producto producto) async {
    return ApiService.handleRequest<Producto>(
      ApiService.put('$endpoint/$id/', producto.toJson()),
      (json) => Producto.fromJson(json),
    );
  }

  static Future<bool> deleteProducto(int id) async {
    try {
      final response = await ApiService.delete('$endpoint/$id/');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  /// Subir imagen a producto usando ImagePickerService
  static Future<Map<String, dynamic>> uploadProductImage(
    int productId,
    XFile imageFile,
  ) async {
    return ImagePickerService.uploadProductImage(productId, imageFile);
  }

  /// Eliminar imagen de producto usando ImagePickerService
  static Future<Map<String, dynamic>> deleteProductImage(int productId) async {
    return ImagePickerService.deleteProductImage(productId);
  }
}
