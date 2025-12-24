import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/configuracion.dart';
import '../../core/repositories/admin_repository.dart';
import 'repository_providers.dart';

class ConfiguracionState {
  final bool isLoading;
  final Configuracion? config;
  final String? error;

  ConfiguracionState({this.isLoading = false, this.config, this.error});
}

class ConfiguracionController extends Notifier<ConfiguracionState> {
  late final AdminRepository _repository;

  @override
  ConfiguracionState build() {
    _repository = ref.watch(adminRepositoryProvider);
    Future.microtask(() => cargarConfiguracion());
    return ConfiguracionState(isLoading: true);
  }

  Future<void> cargarConfiguracion() async {
    state = ConfiguracionState(isLoading: true, config: state.config);
    final result = await _repository.obtenerConfiguracion();
    if (result.isSuccess) {
      state = ConfiguracionState(isLoading: false, config: result.value);
    } else {
      state = ConfiguracionState(
        isLoading: false,
        error: result.error,
        config: state.config,
      );
    }
  }

  Future<void> guardarConfiguracion(Configuracion config) async {
    state = ConfiguracionState(isLoading: true, config: state.config);
    final result = await _repository.guardarConfiguracion(config);
    if (result.isSuccess) {
      state = ConfiguracionState(isLoading: false, config: config);
    } else {
      state = ConfiguracionState(
        isLoading: false,
        error: result.error,
        config: state.config,
      );
    }
  }
}

final configuracionProvider =
    NotifierProvider<ConfiguracionController, ConfiguracionState>(() {
      return ConfiguracionController();
    });
