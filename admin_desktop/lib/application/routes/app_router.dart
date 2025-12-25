import 'package:go_router/go_router.dart';
import '../../presentation/pages/dashboard_page.dart';
import '../../presentation/pages/inventario_page.dart';
import '../../presentation/pages/recetas_page.dart';
import '../../presentation/pages/contabilidad_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/configuracion_page.dart';
import '../../presentation/pages/onboarding_page.dart';
import '../../presentation/pages/verify_email_page.dart';
import '../../presentation/widgets/main_layout.dart';
import '../providers/auth_provider.dart';
import '../providers/system_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) => notifyListeners());
    _ref.listen(systemProvider, (previous, next) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final auth = _ref.read(authProvider);
    final system = _ref.read(systemProvider);
    final isLoggingIn = state.uri.toString() == '/login';
    final isRegistering = state.uri.toString() == '/register';

    // 1. If NOT logged in
    if (auth.user == null) {
      if (isLoggingIn || isRegistering) return null;
      return '/login';
    }

    // 2. If logged in but NOT verified
    // Note: We might need a way to check if current user is verified without a full refresh
    // but typically Firebase user object is updated.
    if (!auth.user!.emailVerified) {
      if (state.uri.toString() == '/verify-email') return null;
      return '/verify-email';
    }

    // 3. If logged in, verified, but NOT initialized
    if (!system.isInitialized) {
      if (state.uri.toString() == '/onboarding') return null;
      return '/onboarding';
    }

    // 4. If logged in and verified, but on login/register/verify-email/onboarding
    if (isLoggingIn ||
        isRegistering ||
        state.uri.toString() == '/verify-email' ||
        state.uri.toString() == '/onboarding') {
      return '/';
    }

    return null;
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final appRouter = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const VerifyEmailPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(location: state.uri.toString(), child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/inventario',
            builder: (context, state) => const InventarioPage(),
          ),
          GoRoute(
            path: '/recetas',
            builder: (context, state) => const RecetasPage(),
          ),
          GoRoute(
            path: '/contabilidad',
            builder: (context, state) => const ContabilidadPage(),
          ),
          GoRoute(
            path: '/configuracion',
            builder: (context, state) => const ConfiguracionPage(),
          ),
        ],
      ),
    ],
    redirect: notifier.redirect,
  );
});
