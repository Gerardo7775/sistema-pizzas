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

    // Listen to repository auth state changes for persistent sessions
    _repository.authStateChanges.listen((user) {
      if (state.isLoading ||
          state.user?.id != user?.id ||
          state.user?.emailVerified != user?.emailVerified) {
        state = AuthState(isLoading: false, user: user);
      }
    });

    return AuthState(isLoading: true);
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
      // Send verification email immediately
      await _repository.sendEmailVerification();
      // Set the user in state so the router redirects to /verify-email
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

  Future<void> checkEmailVerification() async {
    final verified = await _repository.isEmailVerified();
    if (verified && state.user != null) {
      // If now verified, keep current user but we can trigger a state refresh
      state = AuthState(user: state.user);
    }
  }

  Future<void> resendEmailVerification() async {
    state = AuthState(isLoading: true, user: state.user);
    final result = await _repository.sendEmailVerification();
    if (result.isSuccess) {
      state = AuthState(isLoading: false, user: state.user);
    } else {
      state = AuthState(
        isLoading: false,
        user: state.user,
        error: result.error,
      );
    }
  }

  void clearError() {
    state = AuthState(isLoading: false, user: state.user, error: null);
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
