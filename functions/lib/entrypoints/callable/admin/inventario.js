"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listarInsumos = exports.actualizarInsumo = exports.crearInsumo = void 0;
const https_1 = require("firebase-functions/v2/https");
const zod_1 = require("zod");
const firestore_inventory_repository_1 = require("../../../infrastructure/repositories/firestore/firestore_inventory_repository");
const gestionar_inventario_1 = require("../../../application/usecases/gestionar_inventario");
const inventoryRepo = new firestore_inventory_repository_1.FirestoreInventoryRepository();
const gestionarInventario = new gestionar_inventario_1.GestionarInventario(inventoryRepo);
const createInsumoSchema = zod_1.z.object({
    nombre: zod_1.z.string().min(1),
    unidad: zod_1.z.string(),
    stockActual: zod_1.z.number().min(0),
    stockMinimo: zod_1.z.number().min(0),
    costoUnitario: zod_1.z.number().min(0)
});
const updateInsumoSchema = zod_1.z.object({
    id: zod_1.z.string(),
    nombre: zod_1.z.string().optional(),
    stockActual: zod_1.z.number().optional(),
    stockMinimo: zod_1.z.number().optional(),
    costoUnitario: zod_1.z.number().optional(),
    activo: zod_1.z.boolean().optional()
});
exports.crearInsumo = (0, https_1.onCall)(async (request) => {
    // if (!request.auth) throw new HttpsError('unauthenticated', 'User must be logged in.');
    // TODO: Add role check for admin
    try {
        const parsed = createInsumoSchema.parse(request.data);
        const id = await gestionarInventario.crearInsumo(parsed);
        return { success: true, id };
    }
    catch (e) {
        console.error(e);
        throw new https_1.HttpsError('invalid-argument', e.message);
    }
});
exports.actualizarInsumo = (0, https_1.onCall)(async (request) => {
    try {
        const parsed = updateInsumoSchema.parse(request.data);
        await gestionarInventario.actualizarInsumo(parsed.id, parsed);
        return { success: true };
    }
    catch (e) {
        throw new https_1.HttpsError('internal', e.message);
    }
});
exports.listarInsumos = (0, https_1.onCall)(async (request) => {
    try {
        const insumos = await gestionarInventario.listarInsumos();
        return { insumos };
    }
    catch (e) {
        throw new https_1.HttpsError('internal', e.message);
    }
});
//# sourceMappingURL=inventario.js.map