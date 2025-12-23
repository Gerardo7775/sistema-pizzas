import 'package:equatable/equatable.dart';
import 'cliente.dart';
// We'll share/reuse the concept

enum PedidoEstado { capturado, preparacion, entregando, entregado, cancelado }

class DetallePedido extends Equatable {
  final String id;
  final String productoId;
  final String nombreProducto;
  final double precioUnitario;
  final int cantidad;
  final String? especialidad;

  const DetallePedido({
    required this.id,
    required this.productoId,
    required this.nombreProducto,
    required this.precioUnitario,
    required this.cantidad,
    this.especialidad,
  });

  double get subtotal => precioUnitario * cantidad;

  @override
  List<Object?> get props => [
    id,
    productoId,
    nombreProducto,
    precioUnitario,
    cantidad,
    especialidad,
  ];
}

class Pedido extends Equatable {
  final String id;
  final String canal; // 'WhatsApp', 'Llamada', 'Mostrador'
  final PedidoEstado estado;
  final Cliente cliente;
  final List<DetallePedido> detalles;
  final double total;
  final DateTime fechaRegistro;
  final DateTime? horaEstimadaEntrega;
  final String? repartidorId;

  const Pedido({
    required this.id,
    required this.canal,
    this.estado = PedidoEstado.capturado,
    required this.cliente,
    required this.detalles,
    required this.total,
    required this.fechaRegistro,
    this.horaEstimadaEntrega,
    this.repartidorId,
  });

  Pedido copyWith({
    PedidoEstado? estado,
    List<DetallePedido>? detalles,
    double? total,
    DateTime? horaEstimadaEntrega,
    String? repartidorId,
  }) {
    return Pedido(
      id: id,
      canal: canal,
      cliente: cliente,
      fechaRegistro: fechaRegistro,
      estado: estado ?? this.estado,
      detalles: detalles ?? this.detalles,
      total: total ?? this.total,
      horaEstimadaEntrega: horaEstimadaEntrega ?? this.horaEstimadaEntrega,
      repartidorId: repartidorId ?? this.repartidorId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    canal,
    estado,
    cliente,
    detalles,
    total,
    fechaRegistro,
    horaEstimadaEntrega,
    repartidorId,
  ];
}
