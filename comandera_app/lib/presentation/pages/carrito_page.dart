import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/carrito_provider.dart';
import '../../core/entities/cliente.dart';

class CarritoPage extends ConsumerWidget {
  const CarritoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carrito = ref.watch(carritoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del Pedido')),
      body: carrito.items.isEmpty
          ? const Center(child: Text('No hay productos en el pedido'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: carrito.items.length,
                    itemBuilder: (context, index) {
                      final item = carrito.items[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${item.cantidad}')),
                        title: Text(item.nombreProducto),
                        subtitle: Text(item.especialidad ?? 'Personalizada'),
                        trailing: Text('\$${item.subtotal.toStringAsFixed(2)}'),
                        onLongPress: () => ref
                            .read(carritoProvider.notifier)
                            .removerItem(item.id),
                      );
                    },
                  ),
                ),
                const Divider(),
                _ClientSelector(
                  currentClient: carrito.cliente,
                  onSelected: (c) =>
                      ref.read(carritoProvider.notifier).setCliente(c),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${carrito.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed:
                          (carrito.cliente == null || carrito.items.isEmpty)
                          ? null
                          : () async {
                              await ref
                                  .read(carritoProvider.notifier)
                                  .confirmarPedido();
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pedido confirmado con éxito'),
                                ),
                              );
                            },
                      child: carrito.isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Confirmar Pedido'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ClientSelector extends StatelessWidget {
  final Cliente? currentClient;
  final ValueChanged<Cliente> onSelected;

  const _ClientSelector({this.currentClient, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(currentClient?.nombre ?? 'Seleccionar Cliente'),
      subtitle: Text(currentClient?.ubicacion ?? 'Obligatorio para confirmar'),
      trailing: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          // Simplificación: usaremos un cliente mock fijo para este demo
          onSelected(
            const Cliente(
              id: 'mock-1',
              nombre: 'Cliente de Prueba',
              ubicacion: 'Calle Falsa 123',
            ),
          );
        },
      ),
    );
  }
}
