import 'package:flutter/foundation.dart';
import '../models/inventario.dart';
import '../services/inventario_service.dart';

class InventarioProvider with ChangeNotifier {
  List<Inventario> _inventarios = [];
  bool _isLoading = false;
  String? _error;

  List<Inventario> get inventarios => _inventarios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadInventarios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _inventarios = await InventarioService.getInventarios();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addInventario(Inventario inventario) async {
    try {
      final newInventario = await InventarioService.createInventario(inventario);
      _inventarios.add(newInventario);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateInventario(int id, Inventario inventario) async {
    try {
      final updatedInventario = await InventarioService.updateInventario(id, inventario);
      final index = _inventarios.indexWhere((inv) => inv.id == id);
      if (index != -1) {
        _inventarios[index] = updatedInventario;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteInventario(int id) async {
    try {
      final success = await InventarioService.deleteInventario(id);
      if (success) {
        _inventarios.removeWhere((inv) => inv.id == id);
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
