import '../entities/corte.dart';

abstract class ContabilidadRepository {
  Future<List<Corte>> getCortes();
}
