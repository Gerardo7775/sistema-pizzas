import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/insumo.dart';
import '../../core/repositories/admin_repository.dart';
import 'repository_providers.dart';

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
  late final AdminRepository _repository;

  @override
  InventarioState build() {
    _repository = ref.watch(adminRepositoryProvider);
    // Iniciar carga asíncrona pero retornar estado inicial sincrono
    Future.microtask(() => cargarInsumos());
    return InventarioState(isLoading: true);
  }

  Future<void> cargarInsumos() async {
    state = InventarioState(isLoading: true, insumos: state.insumos);
    final result = await _repository.listarInsumos();
    if (result.isSuccess) {
      state = InventarioState(isLoading: false, insumos: result.value!);
    } else {
      state = InventarioState(
        isLoading: false,
        error: result.error,
        insumos: state.insumos,
      );
    }
  }

  Future<void> agregarInsumo(Insumo insumo) async {
    state = InventarioState(isLoading: true, insumos: state.insumos);
    final result = await _repository.crearInsumo(insumo);
    if (result.isSuccess) {
      await cargarInsumos();
    } else {
      state = InventarioState(
        isLoading: false,
        error: result.error,
        insumos: state.insumos,
      );
    }
  }

  Future<void> actualizarInsumo(String id, Map<String, dynamic> data) async {
    state = InventarioState(isLoading: true, insumos: state.insumos);
    final result = await _repository.actualizarInsumo(id, data);
    if (result.isSuccess) {
      await cargarInsumos();
    } else {
      state = InventarioState(
        isLoading: false,
        error: result.error,
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
