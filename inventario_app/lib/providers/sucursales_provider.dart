import 'package:flutter/foundation.dart';
import '../models/sucursal.dart';
import '../services/sucursal_service.dart';

class SucursalesProvider with ChangeNotifier {
  List<Sucursal> _sucursales = [];
  bool _isLoading = false;
  String? _error;

  List<Sucursal> get sucursales => _sucursales;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSucursales() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sucursales = await SucursalService.getSucursales();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _sucursales = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSucursal(Sucursal sucursal) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final nuevaSucursal = await SucursalService.createSucursal(sucursal);
      _sucursales.add(nuevaSucursal);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSucursal(int id, Sucursal sucursal) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final sucursalActualizada = await SucursalService.updateSucursal(id, sucursal);
      final index = _sucursales.indexWhere((s) => s.id == id);
      if (index != -1) {
        _sucursales[index] = sucursalActualizada;
      }
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSucursal(int id) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final success = await SucursalService.deleteSucursal(id);
      if (success) {
        _sucursales.removeWhere((s) => s.id == id);
        _error = null;
        return true;
      } else {
        _error = 'No se pudo eliminar la sucursal';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
