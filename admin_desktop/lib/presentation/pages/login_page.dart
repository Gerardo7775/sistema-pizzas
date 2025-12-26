import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';
import '../../core/utils/alert_utils.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AlertUtils.showError(context, 'Por favor, completa todos los campos.');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      AlertUtils.showError(
        context,
        'El formato del correo electrónico es inválido.',
      );
      return;
    }

    await ref.read(authProvider.notifier).login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(authProvider, (previous, next) {
      if (next.error != null && !next.isLoading) {
        AlertUtils.showError(context, next.error!);
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Minimalist Logo/Header Area
                Icon(
                  Icons.local_pizza_rounded,
                  size: 64,
                  color: colorScheme.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenido de nuevo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestiona tu pizzería con facilidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                // Credentials Fields
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    hintText: 'ejemplo@correo.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Tu contraseña secreta',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 32),

                // Action Area
                if (authState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Entrar al Sistema'),
                  ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go('/register'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  child: const Text('¿Eres nuevo? Crea una cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
