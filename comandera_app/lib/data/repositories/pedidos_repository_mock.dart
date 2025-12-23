import '../../core/entities/pedido.dart';
import '../../core/repositories/pedidos_repository.dart';

class PedidosRepositoryMock implements PedidosRepository {
  final List<Pedido> _pedidos = [];

  @override
  Future<List<Pedido>> getPedidos({PedidoEstado? estado}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (estado != null) {
      return _pedidos.where((p) => p.estado == estado).toList();
    }
    return List.of(_pedidos);
  }

  @override
  Future<Pedido?> getPedido(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _pedidos.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> savePedido(Pedido pedido) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _pedidos.indexWhere((p) => p.id == pedido.id);
    if (index >= 0) {
      _pedidos[index] = pedido;
    } else {
      _pedidos.add(pedido);
    }
  }

  @override
  Future<void> updatePedidoEstado(String id, PedidoEstado nuevoEstado) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _pedidos.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _pedidos[index] = _pedidos[index].copyWith(estado: nuevoEstado);
    }
  }
}
