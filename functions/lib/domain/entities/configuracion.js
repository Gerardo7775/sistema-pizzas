"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Configuracion = void 0;
class Configuracion {
    constructor(id, // e.g., 'global' or 'alerts'
    stockBajoGlobal, umbralStockBajo, // Default threshold if not specified per insumo
    moneda = 'MXN') {
        this.id = id;
        this.stockBajoGlobal = stockBajoGlobal;
        this.umbralStockBajo = umbralStockBajo;
        this.moneda = moneda;
    }
}
exports.Configuracion = Configuracion;
//# sourceMappingURL=configuracion.js.map