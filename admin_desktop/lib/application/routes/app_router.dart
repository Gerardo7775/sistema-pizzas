import 'package:go_router/go_router.dart';
import '../../presentation/pages/dashboard_page.dart';
import '../../presentation/pages/inventario_page.dart';
import '../../presentation/pages/recetas_page.dart';
import '../../presentation/pages/contabilidad_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/configuracion_page.dart';
import '../../presentation/widgets/main_layout.dart';

final appRouter = GoRouter(
  initialLocation: '/login', // Start at login
  // Re-evaluate routes when auth state changes (needs a Listenable, see logic below)
  // Riverpod integration with GoRouter usually requires a separate class or specific setup.
  // For simplicity, we'll use a redirect that checks the provider state,
  // but to make it reactive we'd need a stream.
  // Let's rely on simple checks for now or implement a wrapper if necessary.
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(location: state.uri.toString(), child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
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
);
