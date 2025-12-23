import '../entities/producto.dart';

abstract class ProductosRepository {
  Future<List<Producto>> getProductos();
  Future<Producto?> getProducto(String id);
  Future<void> saveProducto(Producto producto);
  Future<void> deleteProducto(String id);
}
