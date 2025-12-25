import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';
import '../../core/utils/alert_utils.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  int _secondsRemaining = 0;
  Timer? _timer;

  void _startTimer() {
    setState(() => _secondsRemaining = 15);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    if (_secondsRemaining > 0) return;

    await ref.read(authProvider.notifier).resendEmailVerification();
    final authState = ref.read(authProvider);

    if (authState.error != null) {
      if (mounted) AlertUtils.showError(context, authState.error!);
      ref.read(authProvider.notifier).clearError();
    } else {
      if (mounted) {
        AlertUtils.showSuccess(
          context,
          'Se ha enviado un nuevo enlace de verificación a tu correo.',
        );
        _startTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: _secondsRemaining > 0
                            ? _secondsRemaining / 15
                            : 1,
                        strokeWidth: 8,
                        backgroundColor: colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _secondsRemaining > 0
                              ? colorScheme.primary
                              : colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.mark_email_read_rounded,
                      size: 60,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  'Verifica tu correo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hemos enviado un enlace de confirmación a tu correo. Por favor, revísalo para continuar configurando tu pizzería.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                FilledButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: const Text('Ya lo verifiqué, ir al Login'),
                ),
                const SizedBox(height: 24),
                if (_secondsRemaining > 0)
                  Text(
                    'Podrás reenviar en ${_secondsRemaining}s',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  TextButton(
                    onPressed: _resendEmail,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                    child: const Text('¿No recibiste el correo? Reenviar'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
