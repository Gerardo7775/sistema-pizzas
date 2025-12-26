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

  factory Entrega.fromJson(Map<String, dynamic> json) {
    return Entrega(
      id: json['id'],
      pedidoId: json['pedidoId'],
      nombreCliente: json['nombreCliente'],
      direccionCliente: json['direccionCliente'],
      telefonoCliente: json['telefonoCliente'],
      totalAPagar: (json['totalAPagar'] as num).toDouble(),
      estado: EntregaEstado.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EntregaEstado.asignado,
      ),
      horaSalida: json['horaSalida'] != null
          ? DateTime.parse(json['horaSalida'])
          : null,
      horaLlegada: json['horaLlegada'] != null
          ? DateTime.parse(json['horaLlegada'])
          : null,
      evidenciaUrl: json['evidenciaUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pedidoId': pedidoId,
      'nombreCliente': nombreCliente,
      'direccionCliente': direccionCliente,
      'telefonoCliente': telefonoCliente,
      'totalAPagar': totalAPagar,
      'estado': estado.name,
      'horaSalida': horaSalida?.toIso8601String(),
      'horaLlegada': horaLlegada?.toIso8601String(),
      'evidenciaUrl': evidenciaUrl,
    };
  }

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
