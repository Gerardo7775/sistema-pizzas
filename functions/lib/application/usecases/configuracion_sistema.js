"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ConfiguracionSistema = void 0;
const configuracion_1 = require("../../domain/entities/configuracion");
class ConfiguracionSistema {
    constructor(configRepo) {
        this.configRepo = configRepo;
    }
    async guardarConfiguracion(data) {
        const config = new configuracion_1.Configuracion('global', data.stockBajoGlobal, data.umbralStockBajo, data.moneda);
        await this.configRepo.guardar(config);
    }
    async obtenerConfiguracion() {
        return this.configRepo.obtener();
    }
}
exports.ConfiguracionSistema = ConfiguracionSistema;
//# sourceMappingURL=configuracion_sistema.js.map