import 'package:equatable/equatable.dart';

class Insumo extends Equatable {
  final String id;
  final String nombre;
  final String unidad; // 'kg', 'pieza', 'litro'
  final double stockActual;
  final double stockMinimo;
  final DateTime? fechaUltimaCompra;
  final int? vidaUtilDias;
  final bool activo;

  const Insumo({
    required this.id,
    required this.nombre,
    required this.unidad,
    required this.stockActual,
    required this.stockMinimo,
    this.fechaUltimaCompra,
    this.vidaUtilDias,
    this.activo = true,
  });

  Insumo copyWith({
    String? id,
    String? nombre,
    String? unidad,
    double? stockActual,
    double? stockMinimo,
    DateTime? fechaUltimaCompra,
    int? vidaUtilDias,
    bool? activo,
  }) {
    return Insumo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      unidad: unidad ?? this.unidad,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      fechaUltimaCompra: fechaUltimaCompra ?? this.fechaUltimaCompra,
      vidaUtilDias: vidaUtilDias ?? this.vidaUtilDias,
      activo: activo ?? this.activo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    unidad,
    stockActual,
    stockMinimo,
    fechaUltimaCompra,
    vidaUtilDias,
    activo,
  ];
}
