import 'package:cloud_functions/cloud_functions.dart';
import '../../core/entities/insumo.dart';
import '../../core/entities/producto.dart';
import '../../core/entities/configuracion.dart';
import '../../core/repositories/admin_repository.dart';
import '../../core/result.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  @override
  Future<Result<String>> crearInsumo(Insumo insumo) async {
    try {
      final callable = _functions.httpsCallable('crearInsumo');
      final result = await callable.call({
        'nombre': insumo.nombre,
        'unidad': insumo.unidad,
        'stockActual': insumo.stockActual,
        'stockMinimo': insumo.stockMinimo,
        'costoUnitario': insumo.costoUnitario,
      });
      return Result.success(result.data['id']);
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
      final callable = _functions.httpsCallable('actualizarInsumo');
      await callable.call({'id': id, ...data});
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<Insumo>>> listarInsumos() async {
    try {
      final callable = _functions.httpsCallable('listarInsumos');
      final result = await callable.call();
      final List<dynamic> list = result.data['insumos'];
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
      final callable = _functions.httpsCallable('crearProducto');
      final result = await callable.call({
        'nombre': producto.nombre,
        'descripcion': producto.descripcion,
        'precio': producto.precio,
        'receta': producto.receta.map((e) => e.toJson()).toList(),
      });
      return Result.success(result.data['id']);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<Producto>>> listarProductos() async {
    try {
      final callable = _functions.httpsCallable('listarProductos');
      final result = await callable.call();
      final List<dynamic> list = result.data['productos'];
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
      final callable = _functions.httpsCallable('guardarConfiguracion');
      await callable.call(config.toJson());
      return Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Configuracion>> obtenerConfiguracion() async {
    try {
      final callable = _functions.httpsCallable('obtenerConfiguracion');
      final result = await callable.call();
      final config = Configuracion.fromJson(
        Map<String, dynamic>.from(result.data['config']),
      );
      return Result.success(config);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
