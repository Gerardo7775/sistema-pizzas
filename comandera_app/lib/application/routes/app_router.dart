import 'package:go_router/go_router.dart';
import '../../presentation/pages/menu_page.dart';
import '../../presentation/pages/carrito_page.dart';
import '../../presentation/pages/cola_page.dart';
import '../../presentation/widgets/shell_layout.dart';

final appRouter = GoRouter(
  initialLocation: '/menu',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return ShellLayout(child: child);
      },
      routes: [
        GoRoute(path: '/menu', builder: (context, state) => const MenuPage()),
        GoRoute(
          path: '/carrito',
          builder: (context, state) => const CarritoPage(),
        ),
        GoRoute(path: '/cola', builder: (context, state) => const ColaPage()),
      ],
    ),
  ],
);
