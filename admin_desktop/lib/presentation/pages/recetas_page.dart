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
            onPressed: () => _showProductoDialog(context, ref),
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
                  DataColumn(label: Text('Precio'), numeric: true),
                  DataColumn(label: Text('Receta')),
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
                      DataCell(Text('\$${producto.precio.toStringAsFixed(2)}')),
                      DataCell(Text('$numIngredientes insumos')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showProductoDialog(
                                context,
                                ref,
                                producto: producto,
                              ),
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

  void _showProductoDialog(
    BuildContext context,
    WidgetRef ref, {
    Producto? producto,
  }) {
    final nombreController = TextEditingController(text: producto?.nombre);
    final descController = TextEditingController(text: producto?.descripcion);
    final precioController = TextEditingController(
      text: producto?.precio.toString() ?? '0',
    );
    final catController = TextEditingController(
      text: producto?.categoria ?? 'pizza',
    );

    // Initial receta copy
    final List<RecetaItem> receta = List.from(producto?.receta ?? []);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final inventario = ref.watch(inventarioProvider).insumos;

            return AlertDialog(
              title: Text(
                producto == null ? 'Nuevo Producto' : 'Editar Producto',
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                      ),
                      TextField(
                        controller: catController,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                        ),
                      ),
                      TextField(
                        controller: precioController,
                        decoration: const InputDecoration(labelText: 'Precio'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                        ),
                        maxLines: 2,
                      ),
                      const Divider(),
                      const Text(
                        'Receta (Insumos)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...receta.map((item) {
                        final insumo = inventario.firstWhere(
                          (i) => i.id == item.insumoId,
                          orElse: () => Insumo(
                            id: item.insumoId,
                            nombre: '?',
                            unidad: '',
                            stockActual: 0,
                            stockMinimo: 0,
                            costoUnitario: 0,
                          ),
                        );
                        return ListTile(
                          title: Text(insumo.nombre),
                          subtitle: Text(
                            'Cantidad: ${item.cantidad} ${insumo.unidad}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                setState(() => receta.remove(item)),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Agregar Insumo',
                        ),
                        items: inventario
                            .where(
                              (i) => !receta.any((r) => r.insumoId == i.id),
                            )
                            .map((i) {
                              return DropdownMenuItem(
                                value: i.id,
                                child: Text(i.nombre),
                              );
                            })
                            .toList(),
                        onChanged: (id) {
                          if (id != null) {
                            _showAddInsumoToRecipeDialog(context, id, (
                              cantidad,
                            ) {
                              setState(
                                () => receta.add(
                                  RecetaItem(insumoId: id, cantidad: cantidad),
                                ),
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final p = Producto(
                      id: producto?.id ?? '',
                      nombre: nombreController.text,
                      descripcion: descController.text,
                      categoria: catController.text,
                      precio: double.tryParse(precioController.text) ?? 0,
                      receta: receta,
                    );
                    ref.read(productosProvider.notifier).guardarProducto(p);
                    Navigator.pop(context);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddInsumoToRecipeDialog(
    BuildContext context,
    String insumoId,
    Function(double) onAdd,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cantidad para la Receta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Cantidad'),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text) ?? 0;
              if (val > 0) onAdd(val);
              Navigator.pop(context);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }
}
