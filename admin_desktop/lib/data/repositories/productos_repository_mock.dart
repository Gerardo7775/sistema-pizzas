import '../../core/entities/producto.dart';
import '../../core/repositories/productos_repository.dart';

class ProductosRepositoryMock implements ProductosRepository {
  final List<Producto> _productos = [
    const Producto(
      id: '1',
      nombre: 'Pizza Pepperoni',
      categoria: 'pizza',
      precioBase: 120.0,
      especialidades: ['Chica', 'Mediana', 'Grande'],
      receta: [
        RecetaItem(insumoId: '1', cantidad: 0.2, unidad: 'kg'), // Queso
        RecetaItem(insumoId: '3', cantidad: 0.3, unidad: 'kg'), // Harina
        RecetaItem(insumoId: '2', cantidad: 15, unidad: 'pieza'), // Pepperoni
      ],
    ),
    const Producto(
      id: '2',
      nombre: 'Refresco Cola 600ml',
      categoria: 'bebida',
      precioBase: 25.0,
      receta: [], // Producto terminado/reventa
    ),
  ];

  @override
  Future<List<Producto>> getProductos() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.of(_productos);
  }

  @override
  Future<Producto?> getProducto(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _productos.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveProducto(Producto producto) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _productos.indexWhere((p) => p.id == producto.id);
    if (index >= 0) {
      _productos[index] = producto;
    } else {
      _productos.add(producto);
    }
  }

  @override
  Future<void> deleteProducto(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _productos.removeWhere((p) => p.id == id);
  }
}
