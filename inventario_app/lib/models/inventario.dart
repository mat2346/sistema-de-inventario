import 'producto.dart';
import 'sucursal.dart';

class Inventario {
  final int? id;
  final Producto producto;
  final Sucursal sucursal;
  final int cantidad;

  Inventario({
    this.id,
    required this.producto,
    required this.sucursal,
    required this.cantidad,
  });

  factory Inventario.fromJson(Map<String, dynamic> json) {
    return Inventario(
      id: json['id'],
      producto: json['producto_detalle'] != null 
          ? Producto.fromJson(json['producto_detalle'])
          : (json['producto'] != null && json['producto'] is Map
              ? Producto.fromJson(json['producto'])
              : throw Exception('Producto data is missing or invalid')),
      sucursal: json['sucursal_detalle'] != null 
          ? Sucursal.fromJson(json['sucursal_detalle'])
          : (json['sucursal'] != null && json['sucursal'] is Map
              ? Sucursal.fromJson(json['sucursal'])
              : throw Exception('Sucursal data is missing or invalid')),
      cantidad: _parseInt(json['cantidad']),
    );
  }

  // Método helper para conversión segura de enteros
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto': producto.id,
      'sucursal': sucursal.id,
      'cantidad': cantidad,
    };
  }

  @override
  String toString() {
    return 'Inventario{producto: ${producto.nombre}, sucursal: ${sucursal.nombre}, cantidad: $cantidad}';
  }
}
