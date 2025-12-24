class RecetaItem {
  final String insumoId;
  final double cantidad;

  RecetaItem({required this.insumoId, required this.cantidad});

  factory RecetaItem.fromJson(Map<String, dynamic> json) {
    return RecetaItem(
      insumoId: json['insumoId'],
      cantidad: (json['cantidad'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'insumoId': insumoId, 'cantidad': cantidad};
}

class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final double precio;
  final List<RecetaItem> receta;
  final bool activo;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.precio,
    required this.receta,
    this.activo = true,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] ?? '',
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      categoria: json['categoria'] ?? '',
      precio: (json['precio'] as num).toDouble(),
      receta: (json['receta'] as List)
          .map((e) => RecetaItem.fromJson(e))
          .toList(),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'precio': precio,
      'receta': receta.map((e) => e.toJson()).toList(),
      'activo': activo,
    };
  }
}
