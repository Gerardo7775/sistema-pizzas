import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';
import '../../core/utils/alert_utils.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
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

    if (password.length < 6) {
      AlertUtils.showError(
        context,
        'La contraseña debe tener al menos 6 caracteres.',
      );
      return;
    }

    if (password != confirmPassword) {
      AlertUtils.showError(context, 'Las contraseñas no coinciden.');
      return;
    }

    await ref.read(authProvider.notifier).register(name, email, password);
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
                Icon(
                  Icons.app_registration_rounded,
                  size: 64,
                  color: colorScheme.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 24),
                Text(
                  'Crea tu cuenta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Únete a la gestión inteligente de tu pizzería.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo',
                    hintText: 'Ej: Juan Pérez',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_emailFocusNode),
                ),
                const SizedBox(height: 20),
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
                    hintText: 'Mínimo 6 caracteres',
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
                    counterText: '${_passwordController.text.length}/6 mín',
                    counterStyle: TextStyle(
                      color: _passwordController.text.length >= 6
                          ? Colors.green
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 10,
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) => setState(() {}),
                  onFieldSubmitted: (_) => FocusScope.of(
                    context,
                  ).requestFocus(_confirmPasswordFocusNode),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    hintText: 'Repite tu contraseña',
                    prefixIcon: const Icon(Icons.lock_reset_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 32),

                if (authState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Comenzar Registro'),
                  ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go('/'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
