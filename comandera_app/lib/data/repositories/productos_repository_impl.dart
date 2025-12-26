import '../../core/entities/producto.dart';
import '../../core/repositories/productos_repository.dart';
import '../datasources/remote_datasource.dart';

class ProductosRepositoryImpl implements ProductosRepository {
  final RemoteDatasource _datasource;

  ProductosRepositoryImpl(this._datasource);

  @override
  Future<List<Producto>> getProductos() async {
    try {
      final result = await _datasource.callFunction('listarProductos');
      final List<dynamic> list = result is List
          ? result
          : (result['data'] ?? []);

      return list
          .map((item) => Producto.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  @override
  Future<List<Producto>> getProductosByCategoria(String categoria) async {
    try {
      // Assuming 'listarProductos' supports filtering or we filter locally.
      // Optimally, backend supports it. For now, filter locally to be safe.
      final productos = await getProductos();
      return productos.where((p) => p.categoria == categoria).toList();
    } catch (e) {
      throw Exception('Error al filtrar productos: $e');
    }
  }
}
