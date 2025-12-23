import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/providers/contabilidad_provider.dart';

class ContabilidadPage extends ConsumerWidget {
  const ContabilidadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contabilidadState = ref.watch(contabilidadProvider);
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'es_MX');
    final dateFormat = DateFormat('dd MMM yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contabilidad y Cortes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(contabilidadProvider.notifier).cargarCortes();
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: contabilidadState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : contabilidadState.error != null
          ? Center(child: Text('Error: ${contabilidadState.error}'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // KPI Cards
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text(
                                  'Ultimo Corte Diario',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currencyFormat.format(15400.00),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text(
                                  'Acumulado Semanal',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currencyFormat.format(98500.00),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tabla de Cortes
                  Expanded(
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 800,
                      columns: const [
                        DataColumn2(
                          label: Text('Fecha Inicio'),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: Text('Fecha Fin'),
                          size: ColumnSize.L,
                        ),
                        DataColumn(label: Text('Tipo')),
                        DataColumn(label: Text('Ventas'), numeric: true),
                        DataColumn(label: Text('Saldo Final'), numeric: true),
                        DataColumn(label: Text('Acciones')),
                      ],
                      rows: List<DataRow>.generate(
                        contabilidadState.cortes.length,
                        (index) {
                          final corte = contabilidadState.cortes[index];
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(dateFormat.format(corte.fechaInicio)),
                              ),
                              DataCell(Text(dateFormat.format(corte.fechaFin))),
                              DataCell(
                                Chip(
                                  label: Text(corte.tipo),
                                  backgroundColor: corte.tipo == 'Dominical'
                                      ? Colors.orange.withValues(alpha: 0.2)
                                      : Colors.blue.withValues(alpha: 0.2),
                                ),
                              ),
                              DataCell(
                                Text(currencyFormat.format(corte.totalVentas)),
                              ),
                              DataCell(
                                Text(currencyFormat.format(corte.saldoFinal)),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.print),
                                  onPressed: () {},
                                  tooltip: 'Imprimir Reporte',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
