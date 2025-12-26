import { onCall, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
import { z } from 'zod';
import { FirestoreInventoryRepository } from '../../../infrastructure/repositories/firestore/firestore_inventory_repository';
import { GestionarInventario } from '../../../application/usecases/gestionar_inventario';

const inventoryRepo = new FirestoreInventoryRepository();
const gestionarInventario = new GestionarInventario(inventoryRepo);

const createInsumoSchema = z.object({
    nombre: z.string().min(1),
    unidad: z.string(),
    stockActual: z.number().min(0),
    stockMinimo: z.number().min(0),
    costoUnitario: z.number().min(0)
});

const updateInsumoSchema = z.object({
    id: z.string(),
    nombre: z.string().optional(),
    stockActual: z.number().optional(),
    stockMinimo: z.number().optional(),
    costoUnitario: z.number().optional(),
    activo: z.boolean().optional()
});

export const crearInsumo = onCall(async (request: CallableRequest) => {
    // if (!request.auth) throw new HttpsError('unauthenticated', 'User must be logged in.');
    // TODO: Add role check for admin

    try {
        const parsed = createInsumoSchema.parse(request.data);
        const id = await gestionarInventario.crearInsumo(parsed);
        return { success: true, id };
    } catch (e: any) {
        console.error(e);
        throw new HttpsError('invalid-argument', e.message);
    }
});

export const actualizarInsumo = onCall(async (request: CallableRequest) => {
    try {
        const parsed = updateInsumoSchema.parse(request.data);
        await gestionarInventario.actualizarInsumo(parsed.id, parsed);
        return { success: true };
    } catch (e: any) {
        throw new HttpsError('internal', e.message);
    }
});

export const listarInsumos = onCall(async (request: CallableRequest) => {
    try {
        const insumos = await gestionarInventario.listarInsumos();
        return { insumos };
    } catch (e: any) {
        throw new HttpsError('internal', e.message);
    }
});
