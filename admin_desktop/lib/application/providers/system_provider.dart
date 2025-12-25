import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/admin_repository.dart';
import 'repository_providers.dart';

class SystemState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;

  SystemState({this.isInitialized = false, this.isLoading = true, this.error});
}

class SystemController extends Notifier<SystemState> {
  late final AdminRepository _repository;

  @override
  SystemState build() {
    _repository = ref.watch(adminRepositoryProvider);
    Future.microtask(() => checkInitialization());
    return SystemState(isLoading: true);
  }

  Future<void> checkInitialization() async {
    state = SystemState(isLoading: true, isInitialized: state.isInitialized);
    final result = await _repository.obtenerConfiguracion();
    if (result.isSuccess) {
      // If config exists, assume initialized.
      // In a real app, we might check an 'initialized' flag.
      state = SystemState(isInitialized: true, isLoading: false);
    } else {
      // If error (like not found), assume not initialized
      state = SystemState(isInitialized: false, isLoading: false);
    }
  }

  void setInitialized(bool value) {
    state = SystemState(isInitialized: value, isLoading: false);
  }
}

final systemProvider = NotifierProvider<SystemController, SystemState>(() {
  return SystemController();
});
