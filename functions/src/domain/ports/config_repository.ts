import { Configuracion } from "../entities/configuracion";

export interface ConfigRepository {
    guardar(config: Configuracion): Promise<void>;
    obtener(): Promise<Configuracion | null>;
}
