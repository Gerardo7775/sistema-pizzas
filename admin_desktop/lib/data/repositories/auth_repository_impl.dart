import 'package:firebase_auth/firebase_auth.dart';
import '../../core/entities/usuario.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<Result<Usuario>> login(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      // For now, we assume simple mapping. You might fetch custom claims or FS doc here.
      return Result.success(
        Usuario(
          id: user.uid,
          nombre: user.displayName ?? 'Usuario',
          email: user.email!,
          rol:
              'admin', // Hardcoded for initial setup, should come from Claims/DB
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(e.message ?? 'Error de autenticación');
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Usuario>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);
      final user = credential.user!;
      return Result.success(
        Usuario(id: user.uid, nombre: name, email: email, rol: 'admin'),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(e.message ?? 'Error de registro');
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<Usuario?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return Usuario(
      id: user.uid,
      nombre: user.displayName ?? 'Usuario',
      email: user.email!,
      rol: 'admin',
    );
  }
}
