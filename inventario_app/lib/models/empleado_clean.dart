class Empleado {
  final int id;
  final String nombre;
  final String apellido;
  final String nombreCompleto;
  final String cargo;
  final String? correo;
  final String? telefono;
  final int? sucursal;
  final String? sucursalNombre;
  final DateTime? fechaIngreso;
  final bool? isActive;

  Empleado({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.nombreCompleto,
    required this.cargo,
    this.correo,
    this.telefono,
    this.sucursal,
    this.sucursalNombre,
    this.fechaIngreso,
    this.isActive,
  });

  factory Empleado.fromJson(Map<String, dynamic> json) {
    return Empleado(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      nombreCompleto:
          json['nombre_completo'] ??
          '${json['nombre'] ?? ''} ${json['apellido'] ?? ''}'.trim(),
      cargo: json['cargo'] ?? '',
      correo: json['correo'],
      telefono: json['telefono'],
      sucursal: json['sucursal'],
      sucursalNombre: json['sucursal_nombre'],
      fechaIngreso:
          json['fecha_ingreso'] != null
              ? DateTime.tryParse(json['fecha_ingreso'].toString())
              : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'nombre_completo': nombreCompleto,
      'cargo': cargo,
      'correo': correo,
      'telefono': telefono,
      'sucursal': sucursal,
      'sucursal_nombre': sucursalNombre,
      'fecha_ingreso': fechaIngreso?.toIso8601String(),
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'Empleado(id: $id, nombre: $nombre $apellido, cargo: $cargo)';
  }
}
