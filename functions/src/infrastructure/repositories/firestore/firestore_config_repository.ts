import * as admin from 'firebase-admin';
import { ConfigRepository } from '../../../domain/ports/config_repository';
import { Configuracion } from '../../../domain/entities/configuracion';

export class FirestoreConfigRepository implements ConfigRepository {
    private collection = admin.firestore().collection('config');

    async guardar(config: Configuracion): Promise<void> {
        const data = {
            stockBajoGlobal: config.stockBajoGlobal,
            umbralStockBajo: config.umbralStockBajo,
            moneda: config.moneda
        };
        await this.collection.doc(config.id).set(data);
    }

    async obtener(): Promise<Configuracion | null> {
        const doc = await this.collection.doc('global').get(); // Assuming 'global' ID
        if (!doc.exists) return null;
        const data = doc.data()!;
        return new Configuracion(
            doc.id,
            data.stockBajoGlobal,
            data.umbralStockBajo,
            data.moneda
        );
    }
}
