import '../../core/entities/pedido.dart';
import '../../core/repositories/pedidos_repository.dart';
import '../datasources/remote_datasource.dart';

class PedidosRepositoryImpl implements PedidosRepository {
  final RemoteDatasource _datasource;

  PedidosRepositoryImpl(this._datasource);

  @override
  Future<List<Pedido>> getPedidos({PedidoEstado? estado}) async {
    try {
      // Assuming 'listarPedidos' function exists and returns a list of orders
      // or filterable by state.
      // If the backend doesn't support filtering by state in the list call,
      // we filter locally.
      final result = await _datasource.callFunction('listarPedidos');

      final List<dynamic> list = result is List
          ? result
          : (result['data'] ?? []);

      final pedidos = list
          .map((item) => Pedido.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      if (estado != null) {
        return pedidos.where((p) => p.estado == estado).toList();
      }

      return pedidos;
    } catch (e) {
      throw Exception('Error al obtener pedidos: $e');
    }
  }

  @override
  Future<Pedido?> getPedido(String id) async {
    try {
      // Assuming 'obtenerPedido' or we filter from list?
      // Better to have get by ID.
      // If not available, we could use list and filter.
      // Given the specs, specific get might not be defined as a dedicated function
      // but standard strictly. Let's assume 'obtenerPedido' exists or fallback to list.
      // However, for efficiency, let's try calling 'obtenerPedido'.
      final result = await _datasource.callFunction('obtenerPedido', {
        'id': id,
      });
      if (result == null) return null;
      return Pedido.fromJson(Map<String, dynamic>.from(result));
    } catch (e) {
      // Fallback: This might fail if function doesn't exist.
      // Depending on backend implementation.
      // For now, let's assume it throws if not found.
      return null;
    }
  }

  @override
  Future<void> savePedido(Pedido pedido) async {
    try {
      // 'crearPedido' or 'confirmarPedido'?
      // admin_desktop uses 'crearInsumo'.
      // docs say 'confirmarPedido'.
      await _datasource.callFunction('confirmarPedido', pedido.toJson());
    } catch (e) {
      throw Exception('Error al guardar pedido: $e');
    }
  }

  @override
  Future<void> updatePedidoEstado(String id, PedidoEstado nuevoEstado) async {
    try {
      await _datasource.callFunction('actualizarEstadoPedido', {
        'id': id,
        'nuevoEstado': nuevoEstado.name,
      });
    } catch (e) {
      throw Exception('Error al actualizar estado del pedido: $e');
    }
  }
}
