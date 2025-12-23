import 'package:equatable/equatable.dart';

class Cliente extends Equatable {
  final String id;
  final String nombre;
  final String? telefono;
  final String ubicacion;
  final String? preferenciaPago;
  final String? notas;

  const Cliente({
    required this.id,
    required this.nombre,
    this.telefono,
    required this.ubicacion,
    this.preferenciaPago,
    this.notas,
  });

  @override
  List<Object?> get props => [
    id,
    nombre,
    telefono,
    ubicacion,
    preferenciaPago,
    notas,
  ];
}
