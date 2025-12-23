import 'package:equatable/equatable.dart';

class RecetaItem extends Equatable {
  final String insumoId;
  final double cantidad; // Cantidad por unidad de producto
  final String unidad; // Unidad del insumo (cacheada para UI)

  const RecetaItem({
    required this.insumoId,
    required this.cantidad,
    required this.unidad,
  });

  @override
  List<Object?> get props => [insumoId, cantidad, unidad];
}

class Producto extends Equatable {
  final String id;
  final String nombre;
  final String categoria; // 'pizza', 'bebida', 'postre'
  final double precioBase;
  final List<String> especialidades; // 'Chica', 'Mediana', 'Grande' (si aplica)
  final List<RecetaItem> receta; // Insumos requeridos
  final bool activo;

  const Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precioBase,
    this.especialidades = const [],
    this.receta = const [],
    this.activo = true,
  });

  Producto copyWith({
    String? id,
    String? nombre,
    String? categoria,
    double? precioBase,
    List<String>? especialidades,
    List<RecetaItem>? receta,
    bool? activo,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      precioBase: precioBase ?? this.precioBase,
      especialidades: especialidades ?? this.especialidades,
      receta: receta ?? this.receta,
      activo: activo ?? this.activo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    categoria,
    precioBase,
    especialidades,
    receta,
    activo,
  ];
}
