import 'package:equatable/equatable.dart';

enum EntregaEstado { asignado, entregando, entregado, cancelado }

class Entrega extends Equatable {
  final String id;
  final String pedidoId;
  final String nombreCliente;
  final String direccionCliente;
  final String? telefonoCliente;
  final double totalAPagar;
  final EntregaEstado estado;
  final DateTime? horaSalida;
  final DateTime? horaLlegada;
  final String? evidenciaUrl;

  const Entrega({
    required this.id,
    required this.pedidoId,
    required this.nombreCliente,
    required this.direccionCliente,
    this.telefonoCliente,
    required this.totalAPagar,
    this.estado = EntregaEstado.asignado,
    this.horaSalida,
    this.horaLlegada,
    this.evidenciaUrl,
  });

  Entrega copyWith({
    EntregaEstado? estado,
    DateTime? horaSalida,
    DateTime? horaLlegada,
    String? evidenciaUrl,
  }) {
    return Entrega(
      id: id,
      pedidoId: pedidoId,
      nombreCliente: nombreCliente,
      direccionCliente: direccionCliente,
      telefonoCliente: telefonoCliente,
      totalAPagar: totalAPagar,
      estado: estado ?? this.estado,
      horaSalida: horaSalida ?? this.horaSalida,
      horaLlegada: horaLlegada ?? this.horaLlegada,
      evidenciaUrl: evidenciaUrl ?? this.evidenciaUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    pedidoId,
    nombreCliente,
    direccionCliente,
    telefonoCliente,
    totalAPagar,
    estado,
    horaSalida,
    horaLlegada,
    evidenciaUrl,
  ];
}
