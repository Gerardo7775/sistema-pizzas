import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/producto.dart';
import '../../core/repositories/productos_repository.dart';
import '../../data/repositories/productos_repository_mock.dart';

// Provider del Repositorio
final productosRepositoryProvider = Provider<ProductosRepository>((ref) {
  return ProductosRepositoryMock();
});

// Estado
class ProductosState {
  final bool isLoading;
  final List<Producto> productos;
  final String? error;

  ProductosState({
    this.isLoading = false,
    this.productos = const [],
    this.error,
  });
}

// Controller
class ProductosController extends Notifier<ProductosState> {
  late final ProductosRepository _repository;

  @override
  ProductosState build() {
    _repository = ref.watch(productosRepositoryProvider);
    Future.microtask(() => cargarProductos());
    return ProductosState(isLoading: true);
  }

  Future<void> cargarProductos() async {
    state = ProductosState(isLoading: true, productos: state.productos);
    try {
      final productos = await _repository.getProductos();
      state = ProductosState(isLoading: false, productos: productos);
    } catch (e) {
      state = ProductosState(isLoading: false, error: e.toString());
    }
  }

  Future<void> guardarProducto(Producto producto) async {
    try {
      await _repository.saveProducto(producto);
      await cargarProductos();
    } catch (e) {
      state = ProductosState(
        isLoading: false,
        error: e.toString(),
        productos: state.productos,
      );
    }
  }
}

// Provider
final productosProvider = NotifierProvider<ProductosController, ProductosState>(
  () {
    return ProductosController();
  },
);
