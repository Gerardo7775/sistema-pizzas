import 'package:go_router/go_router.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/lista_entregas_page.dart';
import '../../presentation/pages/entrega_detalle_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/entregas',
      builder: (context, state) => const ListaEntregasPage(),
    ),
    GoRoute(
      path: '/entrega/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EntregaDetallePage(entregaId: id);
      },
    ),
  ],
);
