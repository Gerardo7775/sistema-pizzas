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
    ),
    const Producto(
      id: '2',
      nombre: 'Pizza Hawaiana',
      categoria: 'pizza',
      precioBase: 110.0,
      especialidades: ['Chica', 'Mediana', 'Grande'],
    ),
    const Producto(
      id: '3',
      nombre: 'Refresco Cola 600ml',
      categoria: 'bebida',
      precioBase: 25.0,
    ),
    const Producto(
      id: '4',
      nombre: 'Agua Emboteallada 500ml',
      categoria: 'bebida',
      precioBase: 15.0,
    ),
  ];

  @override
  Future<List<Producto>> getProductos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.of(_productos);
  }

  @override
  Future<List<Producto>> getProductosByCategoria(String categoria) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _productos.where((p) => p.categoria == categoria).toList();
  }
}
