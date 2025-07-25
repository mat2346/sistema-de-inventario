import 'producto.dart';
import 'sucursal.dart';
import 'proveedor.dart';
import 'empleado.dart';

class Entrada {
  final int? id;
  final Producto producto;
  final Sucursal sucursal;
  final Proveedor proveedor;
  final Empleado empleado;
  final int cantidad;
  final DateTime fecha;

  Entrada({
    this.id,
    required this.producto,
    required this.sucursal,
    required this.proveedor,
    required this.empleado,
    required this.cantidad,
    required this.fecha,
  });

  factory Entrada.fromJson(Map<String, dynamic> json) {
    return Entrada(
      id: json['id'],
      producto:
          json['producto_detalle'] != null
              ? Producto.fromJson(json['producto_detalle'])
              : Producto(
                id: json['producto'] ?? 0,
                nombre: 'Producto desconocido',
              ),
      sucursal:
          json['sucursal_detalle'] != null
              ? Sucursal.fromJson(json['sucursal_detalle'])
              : Sucursal(
                id: json['sucursal'] ?? 0,
                nombre: 'Sucursal desconocida',
              ),
      proveedor:
          json['proveedor_detalle'] != null
              ? Proveedor.fromJson(json['proveedor_detalle'])
              : Proveedor(
                id: json['proveedor'] ?? 0,
                nombre: 'Proveedor desconocido',
              ),
      empleado:
          json['empleado_detalle'] != null
              ? Empleado.fromJson(json['empleado_detalle'])
              : Empleado(
                id: json['empleado'] ?? 0,
                nombre: 'Empleado',
                apellido: 'Desconocido',
                nombreCompleto: 'Empleado Desconocido',
                cargo: 'Sin cargo',
              ),
      cantidad: json['cantidad'] ?? 0,
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'producto': producto.id,
      'sucursal': sucursal.id,
      'proveedor': proveedor.id,
      'empleado': empleado.id,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
    };
  }

  Entrada copyWith({
    int? id,
    Producto? producto,
    Sucursal? sucursal,
    Proveedor? proveedor,
    Empleado? empleado,
    int? cantidad,
    DateTime? fecha,
  }) {
    return Entrada(
      id: id ?? this.id,
      producto: producto ?? this.producto,
      sucursal: sucursal ?? this.sucursal,
      proveedor: proveedor ?? this.proveedor,
      empleado: empleado ?? this.empleado,
      cantidad: cantidad ?? this.cantidad,
      fecha: fecha ?? this.fecha,
    );
  }
}
