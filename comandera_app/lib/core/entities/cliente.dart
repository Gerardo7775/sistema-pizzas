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

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      ubicacion: json['ubicacion'],
      preferenciaPago: json['preferenciaPago'],
      notas: json['notas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'ubicacion': ubicacion,
      'preferenciaPago': preferenciaPago,
      'notas': notas,
    };
  }

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
