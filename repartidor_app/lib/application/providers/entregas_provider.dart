import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/entrega.dart';
import '../../core/repositories/entregas_repository.dart';
import '../../data/repositories/entregas_repository_mock.dart';

final entregasRepositoryProvider = Provider<EntregasRepository>((ref) {
  return EntregasRepositoryMock();
});

class MisEntregasState {
  final bool isLoading;
  final List<Entrega> entregas;
  final String? error;

  MisEntregasState({
    this.isLoading = false,
    this.entregas = const [],
    this.error,
  });
}

class MisEntregasController extends Notifier<MisEntregasState> {
  late final EntregasRepository _repository;

  @override
  MisEntregasState build() {
    _repository = ref.watch(entregasRepositoryProvider);
    Future.microtask(() => cargarEntregas());
    return MisEntregasState(isLoading: true);
  }

  Future<void> cargarEntregas() async {
    state = MisEntregasState(isLoading: true, entregas: state.entregas);
    try {
      final items = await _repository.getMisEntregas();
      state = MisEntregasState(isLoading: false, entregas: items);
    } catch (e) {
      state = MisEntregasState(isLoading: false, error: e.toString());
    }
  }

  Future<void> actualizarEstado(
    String id,
    EntregaEstado nuevoEstado, {
    String? evidenciaUrl,
  }) async {
    try {
      await _repository.updateEstado(
        id,
        nuevoEstado,
        evidenciaUrl: evidenciaUrl,
      );
      await cargarEntregas();
    } catch (e) {
      // Handle error
    }
  }
}

final misEntregasProvider =
    NotifierProvider<MisEntregasController, MisEntregasState>(() {
      return MisEntregasController();
    });
