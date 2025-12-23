import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/productos_provider.dart';

class RecetasPage extends ConsumerWidget {
  const RecetasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosState = ref.watch(productosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Recetas y Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(productosProvider.notifier).cargarProductos();
            },
          ),
          FilledButton.icon(
            onPressed: () {
              // TODO: Add Product Dialog
            },
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Producto'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: productosState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productosState.error != null
          ? Center(child: Text('Error: ${productosState.error}'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                columns: const [
                  DataColumn2(label: Text('Producto'), size: ColumnSize.L),
                  DataColumn(label: Text('Categoría')),
                  DataColumn(label: Text('Precio Base'), numeric: true),
                  DataColumn(label: Text('Ingredientes (Receta)')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: List<DataRow>.generate(productosState.productos.length, (
                  index,
                ) {
                  final producto = productosState.productos[index];
                  final numIngredientes = producto.receta.length;
                  return DataRow(
                    cells: [
                      DataCell(Text(producto.nombre)),
                      DataCell(
                        Chip(
                          label: Text(producto.categoria),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      DataCell(
                        Text('\$${producto.precioBase.toStringAsFixed(2)}'),
                      ),
                      DataCell(Text('$numIngredientes insumos')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_note, size: 20),
                              onPressed: () {
                                // TODO: Edit Recipe
                              },
                              tooltip: 'Editar Receta',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
    );
  }
}
