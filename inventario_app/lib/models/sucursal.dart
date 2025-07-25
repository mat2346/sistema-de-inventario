class Sucursal {
  final int? id;
  final String nombre;
  final String? descripcion;

  Sucursal({
    this.id,
    required this.nombre,
    this.descripcion,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  @override
  String toString() {
    return 'Sucursal{id: $id, nombre: $nombre}';
  }
}
