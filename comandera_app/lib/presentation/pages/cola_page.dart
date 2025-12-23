import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/cola_pedidos_provider.dart';
import '../../core/entities/pedido.dart';

class ColaPage extends ConsumerWidget {
  const ColaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colaState = ref.watch(colaPedidosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cola de Pedidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(colaPedidosProvider.notifier).cargarPedidos(),
          ),
        ],
      ),
      body: colaState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : colaState.pedidos.isEmpty
          ? const Center(child: Text('No hay pedidos activos'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: colaState.pedidos.length,
              itemBuilder: (context, index) {
                final pedido = colaState.pedidos[index];
                return _PedidoCard(pedido: pedido);
              },
            ),
    );
  }
}

class _PedidoCard extends ConsumerWidget {
  final Pedido pedido;

  const _PedidoCard({required this.pedido});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getStatusColor(pedido.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.receipt_long, color: Colors.white),
        ),
        title: Text(
          pedido.cliente.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Estado: ${pedido.estado.name.toUpperCase()}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...pedido.detalles
                    .map((d) => Text('• ${d.cantidad}x ${d.nombreProducto}'))
                    ,
                const Divider(),
                Text(
                  'Total: \$${pedido.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (pedido.estado == PedidoEstado.capturado)
                      ElevatedButton(
                        onPressed: () => ref
                            .read(colaPedidosProvider.notifier)
                            .actualizarEstado(
                              pedido.id,
                              PedidoEstado.preparacion,
                            ),
                        child: const Text('Iniciar Preparación'),
                      ),
                    if (pedido.estado == PedidoEstado.preparacion)
                      ElevatedButton(
                        onPressed: () => ref
                            .read(colaPedidosProvider.notifier)
                            .actualizarEstado(
                              pedido.id,
                              PedidoEstado.entregando,
                            ),
                        child: const Text('Asignar Repartidor'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PedidoEstado estado) {
    switch (estado) {
      case PedidoEstado.capturado:
        return Colors.blue;
      case PedidoEstado.preparacion:
        return Colors.orange;
      case PedidoEstado.entregando:
        return Colors.purple;
      case PedidoEstado.entregado:
        return Colors.green;
      case PedidoEstado.cancelado:
        return Colors.red;
    }
  }
}
