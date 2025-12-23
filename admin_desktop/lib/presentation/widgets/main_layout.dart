import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String location;

  const MainLayout({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;
    if (location.startsWith('/inventario')) {
      selectedIndex = 1;
    } else if (location.startsWith('/recetas')) {
      selectedIndex = 2; // Placeholder
    } else if (location.startsWith('/contabilidad')) {
      selectedIndex = 3; // Placeholder
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
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
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                label: Text('Inventario'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_menu),
                label: Text('Recetas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.attach_money),
                label: Text('Contabilidad'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
