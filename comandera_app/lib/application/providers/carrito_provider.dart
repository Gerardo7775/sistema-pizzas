import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/entities/cliente.dart';
import '../../core/entities/pedido.dart';
import '../../core/entities/producto.dart';
import '../../core/repositories/pedidos_repository.dart';
import '../../data/datasources/remote_datasource.dart';
import '../../data/repositories/pedidos_repository_impl.dart';

final pedidosRepositoryProvider = Provider<PedidosRepository>((ref) {
  return PedidosRepositoryImpl(FirebaseFunctionsDatasource());
});

class CarritoState {
  final List<DetallePedido> items;
  final Cliente? cliente;
  final String canal;
  final bool isSaving;

  CarritoState({
    this.items = const [],
    this.cliente,
    this.canal = ' WhatsApp',
    this.isSaving = false,
  });

  double get total => items.fold(0, (sum, item) => sum + item.subtotal);
}

class CarritoController extends Notifier<CarritoState> {
  @override
  CarritoState build() {
    return CarritoState();
  }

  void agregarProducto(
    Producto producto, {
    int cantidad = 1,
    String? especialidad,
  }) {
    final nuevoItem = DetallePedido(
      id: const Uuid().v4(),
      productoId: producto.id,
      nombreProducto: producto.nombre,
      precioUnitario:
          producto.precioBase, // Logic for specialty price could go here
      cantidad: cantidad,
      especialidad: especialidad,
    );
    state = CarritoState(
      items: [...state.items, nuevoItem],
      cliente: state.cliente,
      canal: state.canal,
    );
  }

  void removerItem(String id) {
    state = CarritoState(
      items: state.items.where((i) => i.id != id).toList(),
      cliente: state.cliente,
      canal: state.canal,
    );
  }

  void setCliente(Cliente cliente) {
    state = CarritoState(
      items: state.items,
      cliente: cliente,
      canal: state.canal,
    );
  }

  void setCanal(String canal) {
    state = CarritoState(
      items: state.items,
      cliente: state.cliente,
      canal: canal,
    );
  }

  Future<void> confirmarPedido() async {
    if (state.items.isEmpty || state.cliente == null) return;

    state = CarritoState(
      items: state.items,
      cliente: state.cliente,
      canal: state.canal,
      isSaving: true,
    );

    final pedido = Pedido(
      id: const Uuid().v4(),
      canal: state.canal,
      cliente: state.cliente!,
      detalles: state.items,
      total: state.total,
      fechaRegistro: DateTime.now(),
    );

    try {
      await ref.read(pedidosRepositoryProvider).savePedido(pedido);
      // Reset cart
      state = CarritoState();
    } catch (e) {
      state = CarritoState(
        items: state.items,
        cliente: state.cliente,
        canal: state.canal,
        isSaving: false,
      );
      rethrow;
    }
  }
}

final carritoProvider = NotifierProvider<CarritoController, CarritoState>(() {
  return CarritoController();
});
