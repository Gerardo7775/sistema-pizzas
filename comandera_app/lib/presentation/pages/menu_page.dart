import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/menu_provider.dart';
import '../../application/providers/carrito_provider.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(productosMenuProvider);
    final carritoState = ref.watch(carritoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menú Operativo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Selecciona productos para el pedido',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Badge(
              label: Text(carritoState.items.length.toString()),
              child: const Icon(Icons.shopping_basket),
            ),
          ),
        ],
      ),
      body: menuState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : menuState.error != null
          ? Center(child: Text('Error: ${menuState.error}'))
          : Column(
              children: [
                // Categorías (Pizzas, Bebidas, etc.)
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text('Pizzas'),
                        onSelected: null,
                        selected: true,
                      ),
                      SizedBox(width: 8),
                      FilterChip(label: Text('Bebidas'), onSelected: null),
                      SizedBox(width: 8),
                      FilterChip(label: Text('Postres'), onSelected: null),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: menuState.productos.length,
                    itemBuilder: (context, index) {
                      final producto = menuState.productos[index];
                      return _ProductCard(
                        producto: producto,
                        onAdd: () {
                          ref
                              .read(carritoProvider.notifier)
                              .agregarProducto(producto);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${producto.nombre} agregado'),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic producto;
  final VoidCallback onAdd;

  const _ProductCard({required this.producto, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onAdd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withAlpha(50),
                child: const Icon(Icons.restaurant, size: 48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${producto.precioBase.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                shape: const RoundedRectangleBorder(),
                visualDensity: VisualDensity.compact,
              ),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
