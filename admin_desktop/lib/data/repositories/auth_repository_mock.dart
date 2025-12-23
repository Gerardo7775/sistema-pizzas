import 'package:uuid/uuid.dart';
import '../../core/entities/usuario.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/result.dart';

class AuthRepositoryMock implements AuthRepository {
  final List<Usuario> _users = [
    const Usuario(
      id: '1',
      nombre: 'Admin',
      email: 'admin@pizza.com',
      rol: 'admin',
    ),
  ];

  Usuario? _currentUser;

  @override
  Future<Result<Usuario>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = _users.firstWhere(
      (u) => u.email == email,
      orElse: () => const Usuario(id: '', nombre: '', email: '', rol: ''),
    );

    if (user.id.isEmpty) {
      if (email == 'admin@test.com' && password == 'admin') {
        // Backdoor for testing if needed, or just rely on the list
      }
      // For mock purposes, simplistic check
      if (password == '123456') {
        // Allow any user with this pass if not in list? No, stick to list or allow registration.
      }
    }

    // Simple Mock Logic:
    // If user exists in list, check password (mock check: password must be '123456')
    if (user.id.isNotEmpty) {
      if (password == '123456') {
        _currentUser = user;
        return Result.success(user);
      } else {
        return Result.failure('Contraseña incorrecta');
      }
    }

    // Allow dynamic "admin/admin"
    if (email == 'admin' && password == 'admin') {
      final admin = const Usuario(
        id: 'admin',
        nombre: 'Super Admin',
        email: 'admin',
        rol: 'admin',
      );
      _currentUser = admin;
      return Result.success(admin);
    }

    return Result.failure('Usuario no encontrado');
  }

  @override
  Future<Result<Usuario>> register(
    String name,
    String email,
    String password,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_users.any((u) => u.email == email)) {
      return Result.failure('El correo ya está registrado');
    }
    final newUser = Usuario(
      id: const Uuid().v4(),
      nombre: name,
      email: email,
      rol: 'admin', // Default to admin for this app
    );
    _users.add(newUser);
    _currentUser = newUser;
    return Result.success(newUser);
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  @override
  Future<Usuario?> getCurrentUser() async {
    return _currentUser;
  }
}
