import '../entities/producto.dart';

abstract class ProductosRepository {
  Future<List<Producto>> getProductos();
  Future<List<Producto>> getProductosByCategoria(String categoria);
}
