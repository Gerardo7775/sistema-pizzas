import 'package:equatable/equatable.dart';

class Usuario extends Equatable {
  final String id;
  final String nombre;
  final String email;
  final String rol; // 'admin', 'operador', 'repartidor'
  final bool emailVerified;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.emailVerified = false,
  });

  @override
  List<Object?> get props => [id, nombre, email, rol, emailVerified];
}
