import { Insumo } from "../../domain/entities/insumo";
import { InventoryRepository } from "../../domain/ports/inventory_repository";

export class GestionarInventario {
    constructor(private inventoryRepo: InventoryRepository) { }

    async crearInsumo(data: {
        nombre: string;
        unidad: string;
        stockActual: number;
        stockMinimo: number;
        costoUnitario: number;
    }): Promise<string> {
        const id = data.nombre.toLowerCase().replace(/\s+/g, '_'); // Simple ID generation
        const insumo = Insumo.create({ ...data, id });
        await this.inventoryRepo.crear(insumo);
        return id;
    }

    async actualizarInsumo(id: string, data: Partial<Insumo>): Promise<void> {
        const insumo = await this.inventoryRepo.obtenerPorId(id);
        if (!insumo) throw new Error("Insumo no encontrado");

        // Update fields if provided
        if (data.nombre) insumo.nombre = data.nombre;
        if (data.stockActual !== undefined) insumo.actualizarStock(data.stockActual - insumo.stockActual); // Adjust stock
        if (data.costoUnitario !== undefined) insumo.costoUnitario = data.costoUnitario;
        if (data.stockMinimo !== undefined) insumo.stockMinimo = data.stockMinimo;
        if (data.activo !== undefined) insumo.activo = data.activo;

        await this.inventoryRepo.actualizar(insumo);
    }

    async listarInsumos(): Promise<Insumo[]> {
        return this.inventoryRepo.listar();
    }
}
