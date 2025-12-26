import { onCall, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
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

export const crearProducto = onCall(async (request: CallableRequest) => {
    try {
        const parsed = createProductoSchema.parse(request.data);
        const id = await gestionarProductos.crearProducto(parsed);
        return { success: true, id };
    } catch (e: any) {
        throw new HttpsError('invalid-argument', e.message);
    }
});

export const listarProductos = onCall(async (request: CallableRequest) => {
    try {
        const productos = await gestionarProductos.listarProductos();
        return { productos };
    } catch (e: any) {
        throw new HttpsError('internal', e.message);
    }
});
