import * as admin from 'firebase-admin';
import { ProductRepository } from '../../../domain/ports/product_repository';
import { Producto } from '../../../domain/entities/producto';

export class FirestoreProductRepository implements ProductRepository {
    private collection = admin.firestore().collection('productos');

    async crear(producto: Producto): Promise<void> {
        const data = {
            nombre: producto.nombre,
            descripcion: producto.descripcion,
            precio: producto.precio,
            receta: producto.receta,
            activo: producto.activo
        };
        await this.collection.doc(producto.id).set(data);
    }

    async actualizar(producto: Producto): Promise<void> {
        const data = {
            nombre: producto.nombre,
            descripcion: producto.descripcion,
            precio: producto.precio,
            receta: producto.receta,
            activo: producto.activo
        };
        await this.collection.doc(producto.id).update(data);
    }

    async obtenerPorId(id: string): Promise<Producto | null> {
        const doc = await this.collection.doc(id).get();
        if (!doc.exists) return null;
        const data = doc.data()!;
        return new Producto(
            doc.id,
            data.nombre,
            data.descripcion,
            data.precio,
            data.receta || [],
            data.activo
        );
    }

    async listar(): Promise<Producto[]> {
        const snapshot = await this.collection.get();
        return snapshot.docs.map(doc => {
            const data = doc.data();
            return new Producto(
                doc.id,
                data.nombre,
                data.descripcion,
                data.precio,
                data.receta || [],
                data.activo
            );
        });
    }
}
