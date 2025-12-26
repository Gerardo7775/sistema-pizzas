"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GestionarInventario = void 0;
const insumo_1 = require("../../domain/entities/insumo");
class GestionarInventario {
    constructor(inventoryRepo) {
        this.inventoryRepo = inventoryRepo;
    }
    async crearInsumo(data) {
        const id = data.nombre.toLowerCase().replace(/\s+/g, '_'); // Simple ID generation
        const insumo = insumo_1.Insumo.create(Object.assign(Object.assign({}, data), { id }));
        await this.inventoryRepo.crear(insumo);
        return id;
    }
    async actualizarInsumo(id, data) {
        const insumo = await this.inventoryRepo.obtenerPorId(id);
        if (!insumo)
            throw new Error("Insumo no encontrado");
        // Update fields if provided
        if (data.nombre)
            insumo.nombre = data.nombre;
        if (data.stockActual !== undefined)
            insumo.actualizarStock(data.stockActual - insumo.stockActual); // Adjust stock
        if (data.costoUnitario !== undefined)
            insumo.costoUnitario = data.costoUnitario;
        if (data.stockMinimo !== undefined)
            insumo.stockMinimo = data.stockMinimo;
        if (data.activo !== undefined)
            insumo.activo = data.activo;
        await this.inventoryRepo.actualizar(insumo);
    }
    async listarInsumos() {
        return this.inventoryRepo.listar();
    }
}
exports.GestionarInventario = GestionarInventario;
//# sourceMappingURL=gestionar_inventario.js.map