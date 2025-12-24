import { Insumo } from "../entities/insumo";

export interface InventoryRepository {
    crear(insumo: Insumo): Promise<void>;
    actualizar(insumo: Insumo): Promise<void>;
    obtenerPorId(id: string): Promise<Insumo | null>;
    listar(): Promise<Insumo[]>;
}
