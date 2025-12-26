import '../../core/entities/entrega.dart';
import '../../core/repositories/entregas_repository.dart';
import '../datasources/remote_datasource.dart';

class EntregasRepositoryImpl implements EntregasRepository {
  final RemoteDatasource _datasource;

  EntregasRepositoryImpl(this._datasource);

  @override
  Future<List<Entrega>> getMisEntregas() async {
    try {
      // Assuming 'listarEntregas' or 'misEntregas' function exists
      final result = await _datasource.callFunction('listarEntregas');
      final List<dynamic> list = result is List
          ? result
          : (result['entregas'] ?? []);

      return list
          .map((item) => Entrega.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener entregas: $e');
    }
  }

  @override
  Future<Entrega?> getEntrega(String id) async {
    try {
      final result = await _datasource.callFunction('obtenerEntrega', {
        'id': id,
      });
      if (result == null) return null;
      return Entrega.fromJson(Map<String, dynamic>.from(result));
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
    try {
      await _datasource.callFunction('actualizarEstadoEntrega', {
        'id': id,
        'nuevoEstado': nuevoEstado.name,
        'evidenciaUrl': evidenciaUrl,
      });
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }
}
