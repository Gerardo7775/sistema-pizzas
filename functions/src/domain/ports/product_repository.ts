import { Producto } from "../entities/producto";

export interface ProductRepository {
    crear(producto: Producto): Promise<void>;
    actualizar(producto: Producto): Promise<void>;
    obtenerPorId(id: string): Promise<Producto | null>;
    listar(): Promise<Producto[]>;
}
