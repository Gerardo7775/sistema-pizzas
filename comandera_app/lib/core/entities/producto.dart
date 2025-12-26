import 'package:equatable/equatable.dart';

class Producto extends Equatable {
  final String id;
  final String nombre;
  final String categoria;
  final double precioBase;
  final List<String> especialidades;
  final bool activo;

  const Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precioBase,
    this.especialidades = const [],
    this.activo = true,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      precioBase: (json['precioBase'] as num).toDouble(),
      especialidades: List<String>.from(json['especialidades'] ?? []),
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'precioBase': precioBase,
      'especialidades': especialidades,
      'activo': activo,
    };
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    categoria,
    precioBase,
    especialidades,
    activo,
  ];
}
