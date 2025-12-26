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

      return Result.success(
        Usuario(
          id: user.uid,
          nombre: user.displayName ?? 'Usuario',
          email: user.email!,
          rol: 'admin',
          emailVerified: user.emailVerified,
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return Result.failure('Error inesperado: ${e.toString()}');
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
        Usuario(
          id: user.uid,
          nombre: name,
          email: email,
          rol: 'admin',
          emailVerified: user.emailVerified,
        ),
      );
    } on FirebaseAuthException catch (e) {
      return Result.failure(_mapFirebaseError(e.code));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        return Result.success(null);
      }
      return Result.failure('No hay un usuario autenticado');
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.reload();
      return _firebaseAuth.currentUser!.emailVerified;
    }
    return false;
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No se ha encontrado cuenta con este correo. Debes registrarte.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado.';
      case 'weak-password':
        return 'La contraseña es muy débil. Debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El correo electrónico no existe o es inválido. Por favor, revísalo.';
      case 'too-many-requests':
        return 'Demasiados intentos. Por favor, intenta de nuevo más tarde.';
      case 'network-request-failed':
        return 'Error de conexión. Revisa tu internet.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'operation-not-allowed':
        return 'La operación no está permitida.';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos. Si no tienes cuenta, regístrate.';
      default:
        return 'Ocurrió un error en el servidor ($code). Por favor, intenta de nuevo.';
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
      emailVerified: user.emailVerified,
    );
  }

  @override
  Stream<Usuario?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return Usuario(
        id: user.uid,
        nombre: user.displayName ?? 'Usuario',
        email: user.email!,
        rol: 'admin',
        emailVerified: user.emailVerified,
      );
    });
  }
}
