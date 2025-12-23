import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/corte.dart';
import '../../core/repositories/contabilidad_repository.dart';
import '../../data/repositories/contabilidad_repository_mock.dart';

final contabilidadRepositoryProvider = Provider<ContabilidadRepository>((ref) {
  return ContabilidadRepositoryMock();
});

class ContabilidadState {
  final bool isLoading;
  final List<Corte> cortes;
  final String? error;

  ContabilidadState({
    this.isLoading = false,
    this.cortes = const [],
    this.error,
  });
}

class ContabilidadController extends Notifier<ContabilidadState> {
  late final ContabilidadRepository _repository;

  @override
  ContabilidadState build() {
    _repository = ref.watch(contabilidadRepositoryProvider);
    Future.microtask(() => cargarCortes());
    return ContabilidadState(isLoading: true);
  }

  Future<void> cargarCortes() async {
    state = ContabilidadState(isLoading: true, cortes: state.cortes);
    try {
      final cortes = await _repository.getCortes();
      state = ContabilidadState(isLoading: false, cortes: cortes);
    } catch (e) {
      state = ContabilidadState(isLoading: false, error: e.toString());
    }
  }
}

final contabilidadProvider =
    NotifierProvider<ContabilidadController, ContabilidadState>(() {
      return ContabilidadController();
    });
