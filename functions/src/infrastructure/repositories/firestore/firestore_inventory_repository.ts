import * as admin from 'firebase-admin';
import { InventoryRepository } from '../../../domain/ports/inventory_repository';
import { Insumo } from '../../../domain/entities/insumo';

export class FirestoreInventoryRepository implements InventoryRepository {
    private collection = admin.firestore().collection('insumos');

    async crear(insumo: Insumo): Promise<void> {
        const data = {
            nombre: insumo.nombre,
            unidad: insumo.unidad,
            stockActual: insumo.stockActual,
            stockMinimo: insumo.stockMinimo,
            costoUnitario: insumo.costoUnitario,
            activo: insumo.activo
        };
        await this.collection.doc(insumo.id).set(data);
    }

    async actualizar(insumo: Insumo): Promise<void> {
        const data = {
            nombre: insumo.nombre,
            unidad: insumo.unidad,
            stockActual: insumo.stockActual,
            stockMinimo: insumo.stockMinimo,
            costoUnitario: insumo.costoUnitario,
            activo: insumo.activo
        };
        await this.collection.doc(insumo.id).update(data);
    }

    async obtenerPorId(id: string): Promise<Insumo | null> {
        const doc = await this.collection.doc(id).get();
        if (!doc.exists) return null;
        const data = doc.data()!;
        return new Insumo(
            doc.id,
            data.nombre,
            data.unidad,
            data.stockActual,
            data.stockMinimo,
            data.costoUnitario,
            data.activo
        );
    }

    async listar(): Promise<Insumo[]> {
        const snapshot = await this.collection.get();
        return snapshot.docs.map(doc => {
            const data = doc.data();
            return new Insumo(
                doc.id,
                data.nombre,
                data.unidad,
                data.stockActual,
                data.stockMinimo,
                data.costoUnitario,
                data.activo
            );
        });
    }
}
