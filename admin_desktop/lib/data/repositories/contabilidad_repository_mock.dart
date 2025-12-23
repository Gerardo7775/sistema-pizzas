import '../../core/entities/corte.dart';
import '../../core/repositories/contabilidad_repository.dart';

class ContabilidadRepositoryMock implements ContabilidadRepository {
  final List<Corte> _cortes = [
    Corte(
      id: '1',
      fechaInicio: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
      fechaFin: DateTime.now().subtract(const Duration(days: 1)),
      totalVentas: 15400.00,
      saldoFinal: 15400.00,
      tipo: 'Diario',
    ),
    Corte(
      id: '2',
      fechaInicio: DateTime.now().subtract(const Duration(days: 7)),
      fechaFin: DateTime.now().subtract(const Duration(seconds: 1)),
      totalVentas: 98500.00,
      saldoFinal: 98500.00,
      tipo: 'Dominical',
    ),
  ];

  @override
  Future<List<Corte>> getCortes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.of(_cortes);
  }
}
