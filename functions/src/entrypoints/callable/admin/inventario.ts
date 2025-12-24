import * as functions from 'firebase-functions';
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

export const crearInsumo = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
    // if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
    // TODO: Add role check for admin

    try {
        const parsed = createInsumoSchema.parse(data);
        const id = await gestionarInventario.crearInsumo(parsed);
        return { success: true, id };
    } catch (e: any) {
        console.error(e);
        throw new functions.https.HttpsError('invalid-argument', e.message);
    }
});

export const actualizarInsumo = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
    try {
        const parsed = updateInsumoSchema.parse(data);
        await gestionarInventario.actualizarInsumo(parsed.id, parsed);
        return { success: true };
    } catch (e: any) {
        throw new functions.https.HttpsError('internal', e.message);
    }
});

export const listarInsumos = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
    try {
        const insumos = await gestionarInventario.listarInsumos();
        return { insumos };
    } catch (e: any) {
        throw new functions.https.HttpsError('internal', e.message);
    }
});
