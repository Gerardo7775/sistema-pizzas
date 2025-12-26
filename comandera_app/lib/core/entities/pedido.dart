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

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      id: json['id'],
      productoId: json['productoId'],
      nombreProducto: json['nombreProducto'],
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      cantidad: json['cantidad'],
      especialidad: json['especialidad'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'precioUnitario': precioUnitario,
      'cantidad': cantidad,
      'especialidad': especialidad,
    };
  }

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
  final String canal;
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

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      canal: json['canal'],
      estado: PedidoEstado.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => PedidoEstado.capturado,
      ),
      cliente: Cliente.fromJson(Map<String, dynamic>.from(json['cliente'])),
      detalles: (json['detalles'] as List)
          .map((e) => DetallePedido.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: (json['total'] as num).toDouble(),
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
      horaEstimadaEntrega: json['horaEstimadaEntrega'] != null
          ? DateTime.parse(json['horaEstimadaEntrega'])
          : null,
      repartidorId: json['repartidorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'canal': canal,
      'estado': estado.name,
      'cliente': cliente.toJson(),
      'detalles': detalles.map((e) => e.toJson()).toList(),
      'total': total,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'horaEstimadaEntrega': horaEstimadaEntrega?.toIso8601String(),
      'repartidorId': repartidorId,
    };
  }

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
