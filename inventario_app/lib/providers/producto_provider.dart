import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductoProvider with ChangeNotifier {
  List<Producto> _productos = [];
  bool _isLoading = false;
  String? _error;

  List<Producto> get productos => _productos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProductos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _productos = await ProductoService.getProductos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProducto(Producto producto) async {
    try {
      final newProducto = await ProductoService.createProducto(producto);
      _productos.add(newProducto);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProducto(int id, Producto producto) async {
    try {
      final updatedProducto = await ProductoService.updateProducto(
        id,
        producto,
      );
      final index = _productos.indexWhere((prod) => prod.id == id);
      if (index != -1) {
        _productos[index] = updatedProducto;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProducto(int id) async {
    try {
      final success = await ProductoService.deleteProducto(id);
      if (success) {
        _productos.removeWhere((prod) => prod.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Actualizar un producto en la lista local sin llamar al backend
  void updateProductoInList(Producto updatedProducto) {
    final index = _productos.indexWhere(
      (prod) => prod.id == updatedProducto.id,
    );
    if (index != -1) {
      _productos[index] = updatedProducto;
      notifyListeners();
    }
  }
}
