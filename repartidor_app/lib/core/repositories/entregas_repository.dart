import '../entities/entrega.dart';

abstract class EntregasRepository {
  Future<List<Entrega>> getMisEntregas();
  Future<void> updateEstado(
    String id,
    EntregaEstado nuevoEstado, {
    String? evidenciaUrl,
  });
  Future<Entrega?> getEntrega(String id);
}
