import 'package:flutter/foundation.dart';
import '../models/categoria.dart';
import '../services/categoria_service.dart';

class CategoriaProvider with ChangeNotifier {
  List<Categoria> _categorias = [];
  bool _isLoading = false;
  String? _error;

  List<Categoria> get categorias => _categorias;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategorias() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categorias = await CategoriaService.getCategorias();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> addCategoria(Categoria categoria) async {
    try {
      final newCategoria = await CategoriaService.createCategoria(categoria);
      _categorias.add(newCategoria);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategoria(int id, Categoria categoria) async {
    try {
      final updatedCategoria = await CategoriaService.updateCategoria(id, categoria);
      final index = _categorias.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        _categorias[index] = updatedCategoria;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategoria(int id) async {
    try {
      final success = await CategoriaService.deleteCategoria(id);
      if (success) {
        _categorias.removeWhere((cat) => cat.id == id);
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
}
