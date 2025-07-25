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

  Salida({
    this.id,
    required this.producto,
    required this.sucursal,
    required this.empleado,
    required this.cantidad,
    this.motivo,
    required this.fecha,
  });

  factory Salida.fromJson(Map<String, dynamic> json) {
    print('🔍 Creating Salida from JSON: $json');

    // Procesar producto
    Producto producto;
    if (json['producto_detalle'] != null) {
      producto = Producto.fromJson(json['producto_detalle']);
      print('✅ Producto from detalle: ${producto.nombre}');
    } else {
      // Si no hay detalle, crear un producto básico
      producto = Producto(
        id: json['producto'] ?? 0,
        nombre: 'Producto desconocido (ID: ${json['producto'] ?? 'N/A'})',
      );
      print('⚠️ Producto sin detalle, ID: ${json['producto']}');
    }

    // Procesar sucursal
    Sucursal sucursal;
    if (json['sucursal_detalle'] != null) {
      sucursal = Sucursal.fromJson(json['sucursal_detalle']);
      print('✅ Sucursal from detalle: ${sucursal.nombre}');
    } else {
      sucursal = Sucursal(
        id: json['sucursal'] ?? 0,
        nombre: 'Sucursal desconocida (ID: ${json['sucursal'] ?? 'N/A'})',
      );
      print('⚠️ Sucursal sin detalle, ID: ${json['sucursal']}');
    }

    // Procesar empleado
    Empleado empleado;
    if (json['empleado_detalle'] != null) {
      empleado = Empleado.fromJson(json['empleado_detalle']);
      print('✅ Empleado from detalle: ${empleado.nombreCompleto}');
    } else {
      empleado = Empleado(
        id: json['empleado'] ?? 0,
        nombre: 'Empleado',
        apellido: 'Desconocido',
        nombreCompleto:
            'Empleado Desconocido (ID: ${json['empleado'] ?? 'N/A'})',
        cargo: 'Sin cargo',
      );
      print('⚠️ Empleado sin detalle, ID: ${json['empleado']}');
    }

    return Salida(
      id: json['id'],
      producto: producto,
      sucursal: sucursal,
      empleado: empleado,
      cantidad: json['cantidad'] ?? 0,
      motivo: json['motivo'],
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'producto': producto.id,
      'sucursal': sucursal.id,
      'empleado': empleado.id,
      'cantidad': cantidad,
      if (motivo != null) 'motivo': motivo,
      'fecha': fecha.toIso8601String(),
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
  }) {
    return Salida(
      id: id ?? this.id,
      producto: producto ?? this.producto,
      sucursal: sucursal ?? this.sucursal,
      empleado: empleado ?? this.empleado,
      cantidad: cantidad ?? this.cantidad,
      motivo: motivo ?? this.motivo,
      fecha: fecha ?? this.fecha,
    );
  }
}
