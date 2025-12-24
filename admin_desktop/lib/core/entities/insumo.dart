class Insumo {
  final String id;
  final String nombre;
  final String unidad;
  final double stockActual;
  final double stockMinimo;
  final double costoUnitario;
  final bool activo;

  const Insumo({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.stockActual,
    required this.stockMinimo,
    required this.costoUnitario,
    this.activo = true,
  });

  factory Insumo.fromJson(Map<String, dynamic> json) {
    return Insumo(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      unidad: json['unidad'] ?? '',
      stockActual: (json['stockActual'] as num).toDouble(),
      stockMinimo: (json['stockMinimo'] as num).toDouble(),
      costoUnitario: (json['costoUnitario'] as num).toDouble(),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'unidad': unidad,
      'stockActual': stockActual,
      'stockMinimo': stockMinimo,
      'costoUnitario': costoUnitario,
      'activo': activo,
    };
  }
}
