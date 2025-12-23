import '../../core/entities/insumo.dart';
import '../../core/entities/movimiento_inventario.dart';
import '../../core/repositories/inventario_repository.dart';

class InventarioRepositoryMock implements InventarioRepository {
  final List<Insumo> _insumos = [
    Insumo(
      id: '1',
      nombre: 'Queso Mozzarella',
      unidad: 'kg',
      stockActual: 10.5,
      stockMinimo: 5.0,
      fechaUltimaCompra: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Insumo(
      id: '2',
      nombre: 'Pepperoni',
      unidad: 'pieza',
      stockActual: 50,
      stockMinimo: 100,
      fechaUltimaCompra: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Insumo(
      id: '3',
      nombre: 'Harina',
      unidad: 'kg',
      stockActual: 20,
      stockMinimo: 10,
      fechaUltimaCompra: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<MovimientoInventario> _movimientos = [];

  @override
  Future<List<Insumo>> getInsumos() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular latencia
    return List.of(_insumos);
  }

  @override
  Future<Insumo?> getInsumo(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _insumos.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveInsumo(Insumo insumo) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _insumos.indexWhere((i) => i.id == insumo.id);
    if (index >= 0) {
      _insumos[index] = insumo;
    } else {
      _insumos.add(insumo);
    }
  }

  @override
  Future<void> registrarMovimiento(MovimientoInventario movimiento) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _movimientos.add(movimiento);

    // Actualizar stock del insumo
    final index = _insumos.indexWhere((i) => i.id == movimiento.insumoId);
    if (index >= 0) {
      final insumo = _insumos[index];
      double nuevoStock = insumo.stockActual;

      // Calcular nuevo stock según tipo
      switch (movimiento.tipo) {
        case TipoMovimiento.alta:
        case TipoMovimiento
            .ajuste: // Ajuste positivo si es > 0, asumimos logica externa para signo o tipo
          // Para simplificar: Alta SUMA, Merma RESTA, Consumo RESTA.
          // Ajuste puede ser + o -. Asumiremos que Ajuste reemplaza o suma?
          // En este mock simplificado: Alta suma.
          nuevoStock += movimiento.cantidad;
          break;
        case TipoMovimiento.merma:
        case TipoMovimiento.consumo:
          nuevoStock -= movimiento.cantidad;
          break;
      }
      // Ajuste "hard" (set stock) requiere otro handling, aqui asumimos delta.

      _insumos[index] = insumo.copyWith(stockActual: nuevoStock);
    }
  }
}
