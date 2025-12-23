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
