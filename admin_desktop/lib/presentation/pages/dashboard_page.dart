import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Operativo')),
      body: const Center(
        child: Text('Bienvenido al Sistema de Administración'),
      ),
    );
  }
}
