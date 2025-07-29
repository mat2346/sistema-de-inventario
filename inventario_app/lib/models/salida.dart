import 'producto.dart';
import 'sucursal.dart';
import 'empleado.dart';

class Salida {
  final int? id;
  final Producto producto;
  final Sucursal sucursal;
  final Empleado empleado;
  final int cantidad;
  final String? motivo;
  final DateTime fecha;
  final bool esVenta;
  final double? monto;

  Salida({
    this.id,
    required this.producto,
    required this.sucursal,
    required this.empleado,
    required this.cantidad,
    this.motivo,
    required this.fecha,
    this.esVenta = false,
    this.monto,
  });

  factory Salida.fromJson(Map<String, dynamic> json) {
    // Procesar producto
    Producto producto;
    if (json['producto_detalle'] != null) {
      producto = Producto.fromJson(json['producto_detalle']);
    } else {
      // Si no hay detalle, crear un producto básico
      producto = Producto(
        id: json['producto'] ?? 0,
        nombre: 'Producto desconocido (ID: ${json['producto'] ?? 'N/A'})',
      );
    }

    // Procesar sucursal
    Sucursal sucursal;
    if (json['sucursal_detalle'] != null) {
      sucursal = Sucursal.fromJson(json['sucursal_detalle']);
    } else {
      sucursal = Sucursal(
        id: json['sucursal'] ?? 0,
        nombre: 'Sucursal desconocida (ID: ${json['sucursal'] ?? 'N/A'})',
      );
    }

    // Procesar empleado
    Empleado empleado;
    if (json['empleado_detalle'] != null) {
      empleado = Empleado.fromJson(json['empleado_detalle']);
    } else {
      empleado = Empleado(
        id: json['empleado'] ?? 0,
        nombre: 'Empleado',
        apellido: 'Desconocido',
        nombreCompleto:
            'Empleado Desconocido (ID: ${json['empleado'] ?? 'N/A'})',
        cargo: 'Sin cargo',
      );
    }

    return Salida(
      id: json['id'],
      producto: producto,
      sucursal: sucursal,
      empleado: empleado,
      cantidad: json['cantidad'] ?? 0,
      motivo: json['motivo'],
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      esVenta: json['es_venta'] ?? false,
      monto: _parseDouble(json['monto']),
    );
  }

  // Método helper para manejar conversión segura a double desde Decimal
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Manejar string que puede venir del DecimalField de Django
      if (value.isEmpty) return null;
      return double.tryParse(value);
    }
    // Si es un número pero no double/int, intentar convertir
    try {
      return double.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'producto': producto.id,
      'sucursal': sucursal.id,
      'empleado': empleado.id,
      'cantidad': cantidad,
      if (motivo != null) 'motivo': motivo,
      'fecha': fecha.toIso8601String().split('.')[0], // Remover microsegundos
      'es_venta': esVenta,
      // Enviar monto como string para compatibilidad con DecimalField de Django
      'monto': esVenta && monto != null ? monto!.toStringAsFixed(2) : null,
    };
  }

  Salida copyWith({
    int? id,
    Producto? producto,
    Sucursal? sucursal,
    Empleado? empleado,
    int? cantidad,
    String? motivo,
    DateTime? fecha,
    bool? esVenta,
    double? monto,
  }) {
    return Salida(
      id: id ?? this.id,
      producto: producto ?? this.producto,
      sucursal: sucursal ?? this.sucursal,
      empleado: empleado ?? this.empleado,
      cantidad: cantidad ?? this.cantidad,
      motivo: motivo ?? this.motivo,
      fecha: fecha ?? this.fecha,
      esVenta: esVenta ?? this.esVenta,
      monto: monto ?? this.monto,
    );
  }
}
