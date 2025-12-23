import '../../core/entities/entrega.dart';
import '../../core/repositories/entregas_repository.dart';

class EntregasRepositoryMock implements EntregasRepository {
  final List<Entrega> _entregas = [
    Entrega(
      id: 'e1',
      pedidoId: 'p101',
      nombreCliente: 'Carlos Slim',
      direccionCliente: 'Paseo de la Reforma 245, Int 10',
      telefonoCliente: '5512345678',
      totalAPagar: 350.0,
      estado: EntregaEstado.asignado,
    ),
    Entrega(
      id: 'e2',
      pedidoId: 'p102',
      nombreCliente: 'Salma Hayek',
      direccionCliente: 'Colonia Polanco, Calle Newton 12',
      telefonoCliente: '5587654321',
      totalAPagar: 180.0,
      estado: EntregaEstado.asignado,
    ),
  ];

  @override
  Future<List<Entrega>> getMisEntregas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _entregas.where((e) => e.estado != EntregaEstado.entregado).toList();
  }

  @override
  Future<Entrega?> getEntrega(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _entregas.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateEstado(
    String id,
    EntregaEstado nuevoEstado, {
    String? evidenciaUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _entregas.indexWhere((e) => e.id == id);
    if (index >= 0) {
      DateTime? horaSalida = _entregas[index].horaSalida;
      DateTime? horaLlegada = _entregas[index].horaLlegada;

      if (nuevoEstado == EntregaEstado.entregando) {
        horaSalida = DateTime.now();
      } else if (nuevoEstado == EntregaEstado.entregado) {
        horaLlegada = DateTime.now();
      }

      _entregas[index] = _entregas[index].copyWith(
        estado: nuevoEstado,
        horaSalida: horaSalida,
        horaLlegada: horaLlegada,
        evidenciaUrl: evidenciaUrl,
      );
    }
  }
}
