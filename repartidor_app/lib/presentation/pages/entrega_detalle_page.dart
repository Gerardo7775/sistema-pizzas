import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/entregas_provider.dart';
import '../../core/entities/entrega.dart';

class EntregaDetallePage extends ConsumerWidget {
  final String entregaId;

  const EntregaDetallePage({super.key, required this.entregaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(misEntregasProvider);
    final entrega = state.entregas.where((e) => e.id == entregaId).firstOrNull;

    if (entrega == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Entrega no encontrada')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Entrega')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoSection(
              icon: Icons.person,
              title: 'Cliente',
              content: entrega.nombreCliente,
            ),
            const SizedBox(height: 24),
            _InfoSection(
              icon: Icons.location_on,
              title: 'Dirección',
              content: entrega.direccionCliente,
            ),
            if (entrega.telefonoCliente != null) ...[
              const SizedBox(height: 24),
              _InfoSection(
                icon: Icons.phone,
                title: 'Teléfono',
                content: entrega.telefonoCliente!,
              ),
            ],
            const SizedBox(height: 24),
            _InfoSection(
              icon: Icons.attach_money,
              title: 'Total a Cobrar',
              content: '\$${entrega.totalAPagar.toStringAsFixed(2)}',
              contentColor: Colors.green,
            ),
            const SizedBox(height: 48),

            if (entrega.estado == EntregaEstado.asignado)
              ElevatedButton.icon(
                onPressed: () =>
                    _updateStatus(context, ref, EntregaEstado.entregando),
                icon: const Icon(Icons.delivery_dining),
                label: const Text('Marcar Salida a Reparto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),

            if (entrega.estado == EntregaEstado.entregando)
              ElevatedButton.icon(
                onPressed: () => _showEvidenceDialog(context, ref),
                icon: const Icon(Icons.check_circle),
                label: const Text('Confirmar Entrega'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(
    BuildContext context,
    WidgetRef ref,
    EntregaEstado estado,
  ) {
    ref.read(misEntregasProvider.notifier).actualizarEstado(entregaId, estado);
  }

  void _showEvidenceDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Entrega'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('Se requiere foto de evidencia para finalizar.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(misEntregasProvider.notifier)
                  .actualizarEstado(entregaId, EntregaEstado.entregado);
              Navigator.pop(context);
              context.pop(); // Return to list
            },
            child: const Text('Tomar Foto y Finalizar'),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color? contentColor;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
    this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.deepOrange),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: contentColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
