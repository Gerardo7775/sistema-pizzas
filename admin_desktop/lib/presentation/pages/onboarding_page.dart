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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          margin: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
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
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final titles = [
      'Bienvenido a tu Pizzería',
      'Configura tu Inventario',
      'Crea tu Menú',
      'Alertas de Sistema',
      '¡Todo Listo!',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 40, 48, 0),
      child: Column(
        children: [
          Row(
            children: List.generate(
              5,
              (index) => Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            titles[_currentStep],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 28,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.local_pizza_rounded, size: 80, color: colorScheme.primary),
        const SizedBox(height: 40),
        TextField(
          controller: _systemNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del Negocio',
            hintText: 'Ej. Pizza Nostra',
            prefixIcon: Icon(Icons.store_rounded),
          ),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: _selectedCurrency,
          decoration: const InputDecoration(
            labelText: 'Moneda del Sistema',
            prefixIcon: Icon(Icons.payments_rounded),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comencemos agregando los insumos básicos.',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _insumoNameController,
                decoration: const InputDecoration(
                  labelText: 'Insumo',
                  prefixIcon: Icon(Icons.egg_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _insumoQtyController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _insumoUnitController,
                decoration: const InputDecoration(labelText: 'Unid.'),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
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
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: _tempInsumos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = _tempInsumos[index];
              return ListTile(
                tileColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  item.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '${item.stockActual} ${item.unidad}',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onLongPress: () => setState(() => _tempInsumos.removeAt(index)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agrega tus productos principales al catálogo.',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _prodNameController,
                decoration: const InputDecoration(
                  labelText: 'Producto',
                  prefixIcon: Icon(Icons.restaurant_menu_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _prodPriceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
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
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: _tempProductos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final prod = _tempProductos[index];
              return ListTile(
                tileColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  prod.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '¿A qué nivel de stock debemos avisarte?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 48),
        Text(
          _globalThreshold.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Slider(
          value: _globalThreshold,
          min: 1,
          max: 50,
          divisions: 49,
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.primary.withValues(alpha: 0.1),
          onChanged: (val) => setState(() => _globalThreshold = val),
        ),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.auto_awesome_rounded,
          size: 100,
          color: Color(0xFFC87941),
        ),
        const SizedBox(height: 40),
        const Text(
          '¡Configuración completada!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Text(
          'Tu nueva pizzería está lista para abrir sus puertas virtuales.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _prevPage,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              child: const Text('Anterior'),
            )
          else
            const SizedBox.shrink(),
          FilledButton(
            onPressed: _currentStep < 4 ? _nextPage : _finish,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: Text(_currentStep < 4 ? 'Siguiente' : '¡Empezar!'),
          ),
        ],
      ),
    );
  }
}
