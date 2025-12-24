import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/inventario_provider.dart';
import '../../core/entities/insumo.dart';

class InventarioPage extends ConsumerWidget {
  const InventarioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventarioState = ref.watch(inventarioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(inventarioProvider.notifier).cargarInsumos();
            },
          ),
          FilledButton.icon(
            onPressed: () => _showInsumoDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Insumo'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: inventarioState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : inventarioState.error != null
          ? Center(child: Text('Error: ${inventarioState.error}'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                columns: const [
                  DataColumn2(label: Text('Nombre'), size: ColumnSize.L),
                  DataColumn(label: Text('Unidad')),
                  DataColumn(label: Text('Stock Actual'), numeric: true),
                  DataColumn(label: Text('Stock Mínimo'), numeric: true),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: List<DataRow>.generate(inventarioState.insumos.length, (
                  index,
                ) {
                  final insumo = inventarioState.insumos[index];
                  final bajoStock = insumo.stockActual <= insumo.stockMinimo;
                  return DataRow(
                    cells: [
                      DataCell(Text(insumo.nombre)),
                      DataCell(Text(insumo.unidad)),
                      DataCell(
                        Text(
                          insumo.stockActual.toStringAsFixed(2),
                          style: TextStyle(
                            fontWeight: bajoStock
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: bajoStock ? Colors.red : null,
                          ),
                        ),
                      ),
                      DataCell(Text(insumo.stockMinimo.toStringAsFixed(2))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: bajoStock
                                ? Colors.red.withAlpha(25)
                                : Colors.green.withAlpha(25),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: bajoStock ? Colors.red : Colors.green,
                            ),
                          ),
                          child: Text(
                            bajoStock ? 'BAJO STOCK' : 'OK',
                            style: TextStyle(
                              fontSize: 12,
                              color: bajoStock ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _showInsumoDialog(
                                context,
                                ref,
                                insumo: insumo,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.history, size: 20),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInsumoDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showInsumoDialog(
    BuildContext context,
    WidgetRef ref, {
    Insumo? insumo,
  }) {
    final nombreController = TextEditingController(text: insumo?.nombre);
    final unidadController = TextEditingController(
      text: insumo?.unidad ?? 'kg',
    );
    final stockController = TextEditingController(
      text: insumo?.stockActual.toString() ?? '0',
    );
    final minimoController = TextEditingController(
      text: insumo?.stockMinimo.toString() ?? '0',
    );
    final costoController = TextEditingController(
      text: insumo?.costoUnitario.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(insumo == null ? 'Nuevo Insumo' : 'Editar Insumo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: unidadController,
                decoration: const InputDecoration(
                  labelText: 'Unidad (kg, litro, pieza)',
                ),
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock Actual'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: minimoController,
                decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: costoController,
                decoration: const InputDecoration(labelText: 'Costo Unitario'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final newInsumo = Insumo(
                id: insumo?.id ?? '',
                nombre: nombreController.text,
                unidad: unidadController.text,
                stockActual: double.tryParse(stockController.text) ?? 0,
                stockMinimo: double.tryParse(minimoController.text) ?? 0,
                costoUnitario: double.tryParse(costoController.text) ?? 0,
              );

              if (insumo == null) {
                ref.read(inventarioProvider.notifier).agregarInsumo(newInsumo);
              } else {
                ref
                    .read(inventarioProvider.notifier)
                    .actualizarInsumo(insumo.id, newInsumo.toJson());
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
