class Proveedor {
  final int? id;
  final String nombre;
  final String? descripcion;
  final String? contacto;
  final String? telefono;
  final String? correo;
  final String? direccion;

  Proveedor({
    this.id,
    required this.nombre,
    this.descripcion,
    this.contacto,
    this.telefono,
    this.correo,
    this.direccion,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'],
      nombre: json['nombre'] ?? 'Proveedor sin nombre',
      descripcion: json['descripcion'],
      contacto: json['contacto'],
      telefono: json['telefono'],
      correo: json['correo'],
      direccion: json['direccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (contacto != null) 'contacto': contacto,
      if (telefono != null) 'telefono': telefono,
      if (correo != null) 'correo': correo,
      if (direccion != null) 'direccion': direccion,
    };
  }

  Proveedor copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? contacto,
    String? telefono,
    String? correo,
    String? direccion,
  }) {
    return Proveedor(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      contacto: contacto ?? this.contacto,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      direccion: direccion ?? this.direccion,
    );
  }
}
