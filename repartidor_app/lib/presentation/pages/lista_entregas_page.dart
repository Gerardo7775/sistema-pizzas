import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/entregas_provider.dart';
import '../../core/entities/entrega.dart';

class ListaEntregasPage extends ConsumerWidget {
  const ListaEntregasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(misEntregasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Entregas Activas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(misEntregasProvider.notifier).cargarEntregas(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.entregas.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.entregas.length,
              itemBuilder: (context, index) {
                final entrega = state.entregas[index];
                return _EntregaCard(entrega: entrega);
              },
            ),
    );
  }
}

class _EntregaCard extends StatelessWidget {
  final Entrega entrega;

  const _EntregaCard({required this.entrega});

  @override
  Widget build(BuildContext context) {
    final bool isEnCamino = entrega.estado == EntregaEstado.entregando;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          isEnCamino ? Icons.directions_bike : Icons.assignment_turned_in,
          color: isEnCamino ? Colors.orange : Colors.blue,
          size: 40,
        ),
        title: Text(
          entrega.nombreCliente,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entrega.direccionCliente),
            const SizedBox(height: 4),
            Text(
              'Monto: \$${entrega.totalAPagar}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/entrega/${entrega.id}'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            '¡Todo bajo control! No tienes entregas pendientes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
