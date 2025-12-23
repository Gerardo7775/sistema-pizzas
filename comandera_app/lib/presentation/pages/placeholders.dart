import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder for Menu Page
class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú de Productos')),
      body: const Center(child: Text('Grid de Productos')),
    );
  }
}

// Placeholder for Cart Page
class CarritoPage extends ConsumerWidget {
  const CarritoPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Pedido')),
      body: const Center(child: Text('Resumen del Pedido')),
    );
  }
}

// Placeholder for Queue Page
class ColaPage extends ConsumerWidget {
  const ColaPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cola de Pedidos')),
      body: const Center(child: Text('Lista de Pedidos Activos')),
    );
  }
}
