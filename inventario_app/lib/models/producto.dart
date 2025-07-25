import 'categoria.dart';

class Producto {
  final int? id;
  final String nombre;
  final String? descripcion;
  final Categoria? categoria;
  final double? precioCompra;
  final double? precioVenta;
  final String? imagen;
  final String? imagenUrl;
  final String? imagenThumbnailUrl;

  Producto({
    this.id,
    required this.nombre,
    this.descripcion,
    this.categoria,
    this.precioCompra,
    this.precioVenta,
    this.imagen,
    this.imagenUrl,
    this.imagenThumbnailUrl,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      categoria:
          json['categoria_detalle'] != null
              ? Categoria.fromJson(json['categoria_detalle'])
              : (json['categoria'] != null && json['categoria'] is Map
                  ? Categoria.fromJson(json['categoria'])
                  : null),
      precioCompra: _parseDouble(json['precio_compra']),
      precioVenta: _parseDouble(json['precio_venta']),
      imagen: json['imagen'],
      imagenUrl: json['imagen_url'],
      imagenThumbnailUrl: json['imagen_thumbnail_url'],
    );
  }

  // Método helper para conversión segura
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria?.id,
      'precio_compra': precioCompra,
      'precio_venta': precioVenta,
      'imagen': imagen,
    };
  }

  @override
  String toString() {
    return 'Producto{id: $id, nombre: $nombre, categoria: ${categoria?.nombre}, precioVenta: $precioVenta, imagen: $imagen}';
  }
}
