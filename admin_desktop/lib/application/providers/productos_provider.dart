import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/producto.dart';
import '../../core/repositories/admin_repository.dart';
import 'repository_providers.dart';

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
  late final AdminRepository _repository;

  @override
  ProductosState build() {
    _repository = ref.watch(adminRepositoryProvider);
    Future.microtask(() => cargarProductos());
    return ProductosState(isLoading: true);
  }

  Future<void> cargarProductos() async {
    state = ProductosState(isLoading: true, productos: state.productos);
    final result = await _repository.listarProductos();
    if (result.isSuccess) {
      state = ProductosState(isLoading: false, productos: result.value!);
    } else {
      state = ProductosState(
        isLoading: false,
        error: result.error,
        productos: state.productos,
      );
    }
  }

  Future<void> guardarProducto(Producto producto) async {
    state = ProductosState(isLoading: true, productos: state.productos);
    final result = await _repository.crearProducto(producto);
    if (result.isSuccess) {
      await cargarProductos();
    } else {
      state = ProductosState(
        isLoading: false,
        error: result.error,
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
