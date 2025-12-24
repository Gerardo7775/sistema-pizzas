import '../entities/insumo.dart';
import '../entities/producto.dart';
import '../entities/configuracion.dart';
import '../result.dart';

abstract class AdminRepository {
  Future<Result<String>> crearInsumo(Insumo insumo);
  Future<Result<void>> actualizarInsumo(String id, Map<String, dynamic> data);
  Future<Result<List<Insumo>>> listarInsumos();

  Future<Result<String>> crearProducto(Producto producto);
  Future<Result<List<Producto>>> listarProductos();

  Future<Result<void>> guardarConfiguracion(Configuracion config);
  Future<Result<Configuracion>> obtenerConfiguracion();
}
