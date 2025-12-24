import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/configuracion_provider.dart';
import '../../core/entities/configuracion.dart';

class ConfiguracionPage extends ConsumerStatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  ConsumerState<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends ConsumerState<ConfiguracionPage> {
  final _umbralController = TextEditingController();
  bool _stockBajoGlobal = true;
  String _moneda = 'MXN';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final config = ref.read(configuracionProvider).config;
      if (config != null) {
        _umbralController.text = config.umbralStockBajo.toString();
        _stockBajoGlobal = config.stockBajoGlobal;
        _moneda = config.moneda;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(configuracionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración del Sistema')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alertas de Inventario',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Habilitar alertas de stock bajo'),
                      subtitle: const Text(
                        'Notificar cuando un insumo esté por debajo del umbral',
                      ),
                      value: _stockBajoGlobal,
                      onChanged: (val) =>
                          setState(() => _stockBajoGlobal = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _umbralController,
                      decoration: const InputDecoration(
                        labelText: 'Umbral de Stock Bajo (Global)',
                        helperText:
                            'Se usa si el insumo no tiene un umbral específico',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Localización',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _moneda,
                      decoration: const InputDecoration(labelText: 'Moneda'),
                      items: const [
                        DropdownMenuItem(
                          value: 'MXN',
                          child: Text('Peso Mexicano (MXN)'),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text('Dólar Americano (USD)'),
                        ),
                      ],
                      onChanged: (val) => setState(() => _moneda = val!),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final config = Configuracion(
                            stockBajoGlobal: _stockBajoGlobal,
                            umbralStockBajo:
                                double.tryParse(_umbralController.text) ?? 0,
                            moneda: _moneda,
                          );
                          ref
                              .read(configuracionProvider.notifier)
                              .guardarConfiguracion(config);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Configuración guardada'),
                            ),
                          );
                        },
                        child: const Text('Guardar Cambios'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
