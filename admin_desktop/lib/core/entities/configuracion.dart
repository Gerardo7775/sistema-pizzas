class Configuracion {
  final bool stockBajoGlobal;
  final double umbralStockBajo;
  final String moneda;

  Configuracion({
    required this.stockBajoGlobal,
    required this.umbralStockBajo,
    required this.moneda,
  });

  factory Configuracion.fromJson(Map<String, dynamic> json) {
    return Configuracion(
      stockBajoGlobal: json['stockBajoGlobal'] ?? true,
      umbralStockBajo: (json['umbralStockBajo'] as num?)?.toDouble() ?? 0.0,
      moneda: json['moneda'] ?? 'mxn',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stockBajoGlobal': stockBajoGlobal,
      'umbralStockBajo': umbralStockBajo,
      'moneda': moneda,
    };
  }
}
