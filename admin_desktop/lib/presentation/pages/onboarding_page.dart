import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/system_provider.dart';
import '../../application/providers/configuracion_provider.dart';
import '../../application/providers/inventario_provider.dart';
import '../../application/providers/productos_provider.dart';
import '../../core/entities/configuracion.dart';
import '../../core/entities/insumo.dart';
import '../../core/entities/producto.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Basics
  final _systemNameController = TextEditingController(text: 'Mi Pizzería');
  String _selectedCurrency = 'MXN';

  // Step 2: Inventory
  final List<Insumo> _tempInsumos = [];
  final _insumoNameController = TextEditingController();
  final _insumoQtyController = TextEditingController();
  final _insumoUnitController = TextEditingController(text: 'kg');

  // Step 3: Products
  final List<Producto> _tempProductos = [];
  final _prodNameController = TextEditingController();
  final _prodPriceController = TextEditingController();

  // Step 4: Alerts
  double _globalThreshold = 5.0;

  @override
  void dispose() {
    _pageController.dispose();
    _systemNameController.dispose();
    _insumoNameController.dispose();
    _insumoQtyController.dispose();
    _insumoUnitController.dispose();
    _prodNameController.dispose();
    _prodPriceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _finish() async {
    // 1. Save Config
    final config = Configuracion(
      stockBajoGlobal: true,
      umbralStockBajo: _globalThreshold,
      moneda: _selectedCurrency,
    );
    await ref.read(configuracionProvider.notifier).guardarConfiguracion(config);

    // 2. Save Insumos (Sequential or batch if implemented)
    for (var insumo in _tempInsumos) {
      await ref.read(inventarioProvider.notifier).agregarInsumo(insumo);
    }

    // 3. Save Productos
    for (var prod in _tempProductos) {
      await ref.read(productosProvider.notifier).guardarProducto(prod);
    }

    // 4. Mark as Initialized
    ref.read(systemProvider.notifier).setInitialized(true);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 800,
              height: 600,
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1(),
                        _buildStep2(),
                        _buildStep3(),
                        _buildStep4(),
                        _buildStep5(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'Bienvenido a tu Pizzería',
      'Configura tu Inventario',
      'Crea tu Menú',
      'Alertas de Sistema',
      '¡Todo Listo!',
    ];
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentStep + 1) / 5,
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
        const SizedBox(height: 24),
        Text(
          titles[_currentStep],
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.restaurant, size: 80, color: Colors.deepOrange),
        const SizedBox(height: 24),
        TextField(
          controller: _systemNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Negocio',
            hintText: 'Ej. Pizza Nostra',
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedCurrency,
          decoration: const InputDecoration(labelText: 'Moneda'),
          items: const [
            DropdownMenuItem(value: 'MXN', child: Text('Peso Mexicano (MXN)')),
            DropdownMenuItem(value: 'USD', child: Text('Dólar (USD)')),
          ],
          onChanged: (val) => setState(() => _selectedCurrency = val!),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        const Text(
          'Agrega los insumos básicos que utilizas (Harina, Queso, Tomate...)',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _insumoNameController,
                decoration: const InputDecoration(labelText: 'Insumo'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _insumoQtyController,
                decoration: const InputDecoration(labelText: 'Cant.'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _insumoUnitController,
                decoration: const InputDecoration(labelText: 'Unid.'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () {
                if (_insumoNameController.text.isNotEmpty) {
                  setState(() {
                    _tempInsumos.add(
                      Insumo(
                        id: UniqueKey().toString(),
                        nombre: _insumoNameController.text,
                        unidad: _insumoUnitController.text,
                        stockActual:
                            double.tryParse(_insumoQtyController.text) ?? 0,
                        stockMinimo: 0,
                        costoUnitario: 0,
                      ),
                    );
                    _insumoNameController.clear();
                    _insumoQtyController.clear();
                  });
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _tempInsumos.length,
            itemBuilder: (context, index) {
              final item = _tempInsumos[index];
              return ListTile(
                title: Text(item.nombre),
                trailing: Text('${item.stockActual} ${item.unidad}'),
                onLongPress: () => setState(() => _tempInsumos.removeAt(index)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        const Text('Configura tus productos estrella'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _prodNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _prodPriceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () {
                if (_prodNameController.text.isNotEmpty) {
                  setState(() {
                    _tempProductos.add(
                      Producto(
                        id: UniqueKey().toString(),
                        nombre: _prodNameController.text,
                        descripcion: '',
                        categoria: 'pizza',
                        precio: double.tryParse(_prodPriceController.text) ?? 0,
                        receta: [],
                      ),
                    );
                    _prodNameController.clear();
                    _prodPriceController.clear();
                  });
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _tempProductos.length,
            itemBuilder: (context, index) {
              final prod = _tempProductos[index];
              return ListTile(
                title: Text(prod.nombre),
                subtitle: Text('\$${prod.precio}'),
                onLongPress: () =>
                    setState(() => _tempProductos.removeAt(index)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '¿A qué nivel de stock debemos avisarte?',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 32),
        Text(
          _globalThreshold.toStringAsFixed(1),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _globalThreshold,
          min: 1,
          max: 50,
          divisions: 49,
          label: _globalThreshold.round().toString(),
          onChanged: (val) => setState(() => _globalThreshold = val),
        ),
      ],
    );
  }

  Widget _buildStep5() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, size: 100, color: Colors.green),
        SizedBox(height: 24),
        Text(
          'Configuración completada.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 8),
        Text(
          'Al hacer clic en Finalizar, guardaremos todos tus insumos y productos para empezar a operar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          TextButton(onPressed: _prevPage, child: const Text('Anterior'))
        else
          const SizedBox.shrink(),
        if (_currentStep < 4)
          FilledButton(onPressed: _nextPage, child: const Text('Siguiente'))
        else
          FilledButton(onPressed: _finish, child: const Text('Finalizar')),
      ],
    );
  }
}
