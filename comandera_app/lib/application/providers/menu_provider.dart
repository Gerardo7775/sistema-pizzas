import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/producto.dart';
import '../../core/repositories/productos_repository.dart';
import '../../data/repositories/productos_repository_mock.dart';

final productosRepositoryProvider = Provider<ProductosRepository>((ref) {
  return ProductosRepositoryMock();
});

class ProductosMenuState {
  final bool isLoading;
  final List<Producto> productos;
  final String? error;

  ProductosMenuState({
    this.isLoading = false,
    this.productos = const [],
    this.error,
  });
}

class ProductosMenuController extends Notifier<ProductosMenuState> {
  late final ProductosRepository _repository;

  @override
  ProductosMenuState build() {
    _repository = ref.watch(productosRepositoryProvider);
    Future.microtask(() => cargarProductos());
    return ProductosMenuState(isLoading: true);
  }

  Future<void> cargarProductos() async {
    state = ProductosMenuState(isLoading: true, productos: state.productos);
    try {
      final items = await _repository.getProductos();
      state = ProductosMenuState(isLoading: false, productos: items);
    } catch (e) {
      state = ProductosMenuState(isLoading: false, error: e.toString());
    }
  }
}

final productosMenuProvider =
    NotifierProvider<ProductosMenuController, ProductosMenuState>(() {
      return ProductosMenuController();
    });
