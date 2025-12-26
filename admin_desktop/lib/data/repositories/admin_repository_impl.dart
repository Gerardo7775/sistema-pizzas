import '../../core/entities/insumo.dart';
import '../../core/entities/producto.dart';
import '../../core/entities/configuracion.dart';
import '../../core/repositories/admin_repository.dart';
import '../../core/result.dart';
import '../datasources/remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final RemoteDatasource _datasource = FirebaseFunctionsDatasource();

  @override
  Future<Result<String>> crearInsumo(Insumo insumo) async {
    try {
      final data = await _datasource.callFunction('crearInsumo', {
        'nombre': insumo.nombre,
        'unidad': insumo.unidad,
        'stockActual': insumo.stockActual,
        'stockMinimo': insumo.stockMinimo,
        'costoUnitario': insumo.costoUnitario,
      });
      return Result.success(data['id']);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> actualizarInsumo(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _datasource.callFunction('actualizarInsumo', {'id': id, ...data});
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<Insumo>>> listarInsumos() async {
    try {
      final data = await _datasource.callFunction('listarInsumos');
      final List<dynamic> list = data['insumos'];
      final insumos = list
          .map((e) => Insumo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Result.success(insumos);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<String>> crearProducto(Producto producto) async {
    try {
      final data = await _datasource.callFunction('crearProducto', {
        'nombre': producto.nombre,
        'descripcion': producto.descripcion,
        'precio': producto.precio,
        'receta': producto.receta.map((e) => e.toJson()).toList(),
      });
      return Result.success(data['id']);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<Producto>>> listarProductos() async {
    try {
      final data = await _datasource.callFunction('listarProductos');
      final List<dynamic> list = data['productos'];
      final productos = list
          .map((e) => Producto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Result.success(productos);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> guardarConfiguracion(Configuracion config) async {
    try {
      await _datasource.callFunction('guardarConfiguracion', config.toJson());
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Configuracion>> obtenerConfiguracion() async {
    try {
      final data = await _datasource.callFunction('obtenerConfiguracion');
      final config = Configuracion.fromJson(
        Map<String, dynamic>.from(data['config']),
      );
      return Result.success(config);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
