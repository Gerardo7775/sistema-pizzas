import 'package:equatable/equatable.dart';

class Corte extends Equatable {
  final String id;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double totalVentas;
  final double totalEgresos; // Si aplica
  final double saldoFinal;
  final String tipo; // 'Diario' o 'Dominical'

  const Corte({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.totalVentas,
    this.totalEgresos = 0.0,
    required this.saldoFinal,
    required this.tipo,
  });

  @override
  List<Object?> get props => [
    id,
    fechaInicio,
    fechaFin,
    totalVentas,
    totalEgresos,
    saldoFinal,
    tipo,
  ];
}
