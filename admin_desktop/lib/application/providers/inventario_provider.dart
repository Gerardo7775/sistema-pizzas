import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/insumo.dart';
import '../../core/repositories/inventario_repository.dart';
import '../../data/repositories/inventario_repository_mock.dart';

// Provider del Repositorio (Inyección de Dependencia)
final inventarioRepositoryProvider = Provider<InventarioRepository>((ref) {
  return InventarioRepositoryMock();
});

// Estado de la lista de insumos
class InventarioState {
  final bool isLoading;
  final List<Insumo> insumos;
  final String? error;

  InventarioState({
    this.isLoading = false,
    this.insumos = const [],
    this.error,
  });
}

// Controller (Notifier)
class InventarioController extends Notifier<InventarioState> {
  late final InventarioRepository _repository;

  @override
  InventarioState build() {
    _repository = ref.watch(inventarioRepositoryProvider);
    // Iniciar carga asíncrona pero retornar estado inicial sincrono
    Future.microtask(() => cargarInsumos());
    return InventarioState(isLoading: true);
  }

  Future<void> cargarInsumos() async {
    state = InventarioState(isLoading: true, insumos: state.insumos);
    try {
      final insumos = await _repository.getInsumos();
      state = InventarioState(isLoading: false, insumos: insumos);
    } catch (e) {
      state = InventarioState(isLoading: false, error: e.toString());
    }
  }

  Future<void> agregarOActualizarInsumo(Insumo insumo) async {
    try {
      await _repository.saveInsumo(insumo);
      await cargarInsumos();
    } catch (e) {
      state = InventarioState(
        isLoading: false,
        error: e.toString(),
        insumos: state.insumos,
      );
    }
  }
}

// Provider del Controller
final inventarioProvider =
    NotifierProvider<InventarioController, InventarioState>(() {
      return InventarioController();
    });
