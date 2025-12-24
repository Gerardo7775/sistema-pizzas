import * as functions from 'firebase-functions';
import { z } from 'zod';
import { FirestoreProductRepository } from '../../../infrastructure/repositories/firestore/firestore_product_repository';
import { GestionarProductos } from '../../../application/usecases/gestionar_productos';

const productRepo = new FirestoreProductRepository();
const gestionarProductos = new GestionarProductos(productRepo);

const recetaItemSchema = z.object({
    insumoId: z.string(),
    cantidad: z.number().min(0)
});

const createProductoSchema = z.object({
    nombre: z.string().min(1),
    descripcion: z.string(),
    precio: z.number().min(0),
    receta: z.array(recetaItemSchema)
});

export const crearProducto = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
    try {
        const parsed = createProductoSchema.parse(data);
        const id = await gestionarProductos.crearProducto(parsed);
        return { success: true, id };
    } catch (e: any) {
        throw new functions.https.HttpsError('invalid-argument', e.message);
    }
});

export const listarProductos = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
    try {
        const productos = await gestionarProductos.listarProductos();
        return { productos };
    } catch (e: any) {
        throw new functions.https.HttpsError('internal', e.message);
    }
});
