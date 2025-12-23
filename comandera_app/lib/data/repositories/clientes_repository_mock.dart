import '../../core/entities/cliente.dart';
import '../../core/repositories/clientes_repository.dart';

class ClientesRepositoryMock implements ClientesRepository {
  final List<Cliente> _clientes = [
    const Cliente(
      id: '1',
      nombre: 'Juan Pérez',
      telefono: '5551234567',
      ubicacion: 'Calle Principal 123, Col. Centro',
      preferenciaPago: 'Efectivo',
    ),
    const Cliente(
      id: '2',
      nombre: 'María García',
      telefono: '5559876543',
      ubicacion: 'Av. Reforma 456, Int. 5',
      preferenciaPago: 'Tarjeta',
    ),
  ];

  @override
  Future<List<Cliente>> searchClientes(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return _clientes
        .where(
          (c) =>
              c.nombre.toLowerCase().contains(q) ||
              (c.telefono?.contains(q) ?? false),
        )
        .toList();
  }

  @override
  Future<Cliente?> getClienteByTelefono(String telefono) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _clientes.firstWhere((c) => c.telefono == telefono);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveCliente(Cliente cliente) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _clientes.indexWhere((c) => c.id == cliente.id);
    if (index >= 0) {
      _clientes[index] = cliente;
    } else {
      _clientes.add(cliente);
    }
  }
}
