import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/pedido.dart';
import '../../core/repositories/pedidos_repository.dart';
import 'carrito_provider.dart'; // To use the same repository provider

class ColaPedidosState {
  final bool isLoading;
  final List<Pedido> pedidos;
  final String? error;

  ColaPedidosState({
    this.isLoading = false,
    this.pedidos = const [],
    this.error,
  });
}

class ColaPedidosController extends Notifier<ColaPedidosState> {
  late final PedidosRepository _repository;

  @override
  ColaPedidosState build() {
    _repository = ref.watch(pedidosRepositoryProvider);
    Future.microtask(() => cargarPedidos());
    return ColaPedidosState(isLoading: true);
  }

  Future<void> cargarPedidos() async {
    state = ColaPedidosState(isLoading: true, pedidos: state.pedidos);
    try {
      final items = await _repository.getPedidos();
      state = ColaPedidosState(isLoading: false, pedidos: items);
    } catch (e) {
      state = ColaPedidosState(isLoading: false, error: e.toString());
    }
  }

  Future<void> actualizarEstado(String id, PedidoEstado nuevoEstado) async {
    try {
      await _repository.updatePedidoEstado(id, nuevoEstado);
      await cargarPedidos();
    } catch (e) {
      // Logic for error in update
    }
  }
}

final colaPedidosProvider =
    NotifierProvider<ColaPedidosController, ColaPedidosState>(() {
      return ColaPedidosController();
    });
