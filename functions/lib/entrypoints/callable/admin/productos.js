"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listarProductos = exports.crearProducto = void 0;
const https_1 = require("firebase-functions/v2/https");
const zod_1 = require("zod");
const firestore_product_repository_1 = require("../../../infrastructure/repositories/firestore/firestore_product_repository");
const gestionar_productos_1 = require("../../../application/usecases/gestionar_productos");
const productRepo = new firestore_product_repository_1.FirestoreProductRepository();
const gestionarProductos = new gestionar_productos_1.GestionarProductos(productRepo);
const recetaItemSchema = zod_1.z.object({
    insumoId: zod_1.z.string(),
    cantidad: zod_1.z.number().min(0)
});
const createProductoSchema = zod_1.z.object({
    nombre: zod_1.z.string().min(1),
    descripcion: zod_1.z.string(),
    precio: zod_1.z.number().min(0),
    receta: zod_1.z.array(recetaItemSchema)
});
exports.crearProducto = (0, https_1.onCall)(async (request) => {
    try {
        const parsed = createProductoSchema.parse(request.data);
        const id = await gestionarProductos.crearProducto(parsed);
        return { success: true, id };
    }
    catch (e) {
        throw new https_1.HttpsError('invalid-argument', e.message);
    }
});
exports.listarProductos = (0, https_1.onCall)(async (request) => {
    try {
        const productos = await gestionarProductos.listarProductos();
        return { productos };
    }
    catch (e) {
        throw new https_1.HttpsError('internal', e.message);
    }
});
//# sourceMappingURL=productos.js.map