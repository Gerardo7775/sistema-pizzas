import '../entities/usuario.dart';
import '../result.dart';

abstract class AuthRepository {
  Future<Result<Usuario>> login(String email, String password);
  Future<Result<Usuario>> register(String name, String email, String password);
  Future<void> logout();
  Future<Usuario?> getCurrentUser();
  Future<Result<void>> sendEmailVerification();
  Future<bool> isEmailVerified();
  Stream<Usuario?> get authStateChanges;
}
