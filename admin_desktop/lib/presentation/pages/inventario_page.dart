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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Inventario',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(inventarioProvider.notifier).cargarInsumos();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: () => _showInsumoDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo Insumo'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: inventarioState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : inventarioState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading inventory',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    inventarioState.error!,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 24,
                  minWidth: 800, // Increased for better desktop view
                  headingRowColor: WidgetStateProperty.all(
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ),
                  columns: [
                    DataColumn2(
                      label: Text(
                        'Nombre',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      size: ColumnSize.L,
                    ),
                    const DataColumn(label: Text('Unidad')),
                    const DataColumn(
                      label: Text('Stock Actual'),
                      numeric: true,
                    ),
                    const DataColumn(
                      label: Text('Stock Mínimo'),
                      numeric: true,
                    ),
                    const DataColumn(label: Text('Estado')),
                    const DataColumn(label: Text('Acciones'), numeric: true),
                  ],
                  rows: List<DataRow>.generate(inventarioState.insumos.length, (
                    index,
                  ) {
                    final insumo = inventarioState.insumos[index];
                    final bajoStock = insumo.stockActual <= insumo.stockMinimo;

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            insumo.nombre,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        DataCell(Text(insumo.unidad)),
                        DataCell(
                          Text(
                            insumo.stockActual.toStringAsFixed(2),
                            style: TextStyle(
                              fontWeight: bajoStock
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: bajoStock ? colorScheme.error : null,
                            ),
                          ),
                        ),
                        DataCell(Text(insumo.stockMinimo.toStringAsFixed(2))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: bajoStock
                                  ? colorScheme.errorContainer
                                  : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: bajoStock
                                    ? colorScheme.error
                                    : Colors.green,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              bajoStock ? 'BAJO STOCK' : 'OK',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: bajoStock
                                    ? colorScheme.onErrorContainer
                                    : Colors.green[800],
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit_rounded,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                tooltip: 'Editar',
                                onPressed: () => _showInsumoDialog(
                                  context,
                                  ref,
                                  insumo: insumo,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.history_rounded,
                                  size: 20,
                                  color: colorScheme.outline,
                                ),
                                tooltip: 'Historial',
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInsumoDialog(context, ref),
        child: const Icon(Icons.add_rounded),
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

    final isEditing = insumo != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Insumo' : 'Nuevo Insumo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: unidadController,
                decoration: const InputDecoration(
                  labelText: 'Unidad',
                  hintText: 'kg, litro, pieza',
                  prefixIcon: Icon(Icons.scale_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Actual',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: minimoController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Mínimo',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: costoController,
                decoration: const InputDecoration(
                  labelText: 'Costo Unitario',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
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
              // Basic validation
              if (nombreController.text.isEmpty) return;

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
