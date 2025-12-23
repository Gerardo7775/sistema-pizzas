import 'package:equatable/equatable.dart';

enum TipoMovimiento { alta, ajuste, merma, consumo }

class MovimientoInventario extends Equatable {
  final String id;
  final String insumoId;
  final TipoMovimiento tipo;
  final double cantidad; // Siempre positiva, el tipo define si suma o resta
  final DateTime fecha;
  final String? nota;
  final String? usuarioId;

  const MovimientoInventario({
    required this.id,
    required this.insumoId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
    this.nota,
    this.usuarioId,
  });

  @override
  List<Object?> get props => [
    id,
    insumoId,
    tipo,
    cantidad,
    fecha,
    nota,
    usuarioId,
  ];
}
