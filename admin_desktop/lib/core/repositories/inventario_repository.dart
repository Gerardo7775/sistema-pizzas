import '../entities/insumo.dart';
import '../entities/movimiento_inventario.dart';

abstract class InventarioRepository {
  Future<List<Insumo>> getInsumos();
  Future<Insumo?> getInsumo(String id);
  Future<void> saveInsumo(Insumo insumo);
  Future<void> registrarMovimiento(MovimientoInventario movimiento);
}
