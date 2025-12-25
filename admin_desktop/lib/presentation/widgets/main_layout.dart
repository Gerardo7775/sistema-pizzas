import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;
  final String location;

  const MainLayout({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = 0;
    if (location.startsWith('/inventario')) {
      selectedIndex = 1;
    } else if (location.startsWith('/recetas')) {
      selectedIndex = 2;
    } else if (location.startsWith('/contabilidad')) {
      selectedIndex = 3;
    } else if (location.startsWith('/configuracion')) {
      selectedIndex = 4;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(5, 0),
                ),
              ],
            ),
            child: NavigationRail(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/inventario');
                    break;
                  case 2:
                    context.go('/recetas');
                    break;
                  case 3:
                    context.go('/contabilidad');
                    break;
                  case 4:
                    context.go('/configuracion');
                    break;
                }
              },
              labelType: NavigationRailLabelType.selected,
              indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
              selectedIconTheme: IconThemeData(
                color: colorScheme.primary,
                size: 28,
              ),
              unselectedIconTheme: IconThemeData(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                size: 24,
              ),
              selectedLabelTextStyle: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2_rounded),
                  label: Text('Inventario'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: Text('Recetas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.payments_outlined),
                  selectedIcon: Icon(Icons.payments_rounded),
                  label: Text('Finanzas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Ajustes'),
                ),
              ],
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Icon(
                  Icons.local_pizza_rounded,
                  color: colorScheme.primary,
                  size: 32,
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: IconButton(
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                      icon: Icon(
                        Icons.logout_rounded,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      tooltip: 'Cerrar Sesión',
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: colorScheme.surface,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  bottomLeft: Radius.circular(32),
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
