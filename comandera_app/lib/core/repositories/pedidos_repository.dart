import '../entities/pedido.dart';

abstract class PedidosRepository {
  Future<List<Pedido>> getPedidos({PedidoEstado? estado});
  Future<Pedido?> getPedido(String id);
  Future<void> savePedido(Pedido pedido);
  Future<void> updatePedidoEstado(String id, PedidoEstado nuevoEstado);
}
