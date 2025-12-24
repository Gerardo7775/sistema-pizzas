import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/entities/usuario.dart';
import '../../core/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

class AuthState {
  final bool isLoading;
  final Usuario? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  bool get isAuthenticated => user != null;
}

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    return AuthState();
  }

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    final result = await _repository.login(email, password);
    if (result.isSuccess) {
      state = AuthState(isLoading: false, user: result.value);
    } else {
      state = AuthState(isLoading: false, error: result.error);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = AuthState(isLoading: true);
    final result = await _repository.register(name, email, password);
    if (result.isSuccess) {
      state = AuthState(isLoading: false, user: result.value);
    } else {
      state = AuthState(isLoading: false, error: result.error);
    }
  }

  Future<void> logout() async {
    state = AuthState(isLoading: true);
    await _repository.logout();
    state = AuthState(isLoading: false, user: null);
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
