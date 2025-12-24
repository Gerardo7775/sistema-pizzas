import { Configuracion } from "../../domain/entities/configuracion";
import { ConfigRepository } from "../../domain/ports/config_repository";

export class ConfiguracionSistema {
    constructor(private configRepo: ConfigRepository) { }

    async guardarConfiguracion(data: {
        stockBajoGlobal: boolean;
        umbralStockBajo: number;
        moneda: string;
    }): Promise<void> {
        const config = new Configuracion('global', data.stockBajoGlobal, data.umbralStockBajo, data.moneda);
        await this.configRepo.guardar(config);
    }

    async obtenerConfiguracion(): Promise<Configuracion | null> {
        return this.configRepo.obtener();
    }
}
