import '../entities/cliente.dart';

abstract class ClientesRepository {
  Future<List<Cliente>> searchClientes(String query);
  Future<Cliente?> getClienteByTelefono(String telefono);
  Future<void> saveCliente(Cliente cliente);
}
