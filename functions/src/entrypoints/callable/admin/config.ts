import * as functions from 'firebase-functions';
import { z } from 'zod';
import { FirestoreConfigRepository } from '../../../infrastructure/repositories/firestore/firestore_config_repository';
import { ConfiguracionSistema } from '../../../application/usecases/configuracion_sistema';

const configRepo = new FirestoreConfigRepository();
const configuracionSistema = new ConfiguracionSistema(configRepo);

const saveConfigSchema = z.object({
    stockBajoGlobal: z.boolean(),
    umbralStockBajo: z.number(),
    moneda: z.string().default('MXN')
});

export const guardarConfiguracion = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
    try {
        const parsed = saveConfigSchema.parse(data);
        await configuracionSistema.guardarConfiguracion(parsed);
        return { success: true };
    } catch (e: any) {
        throw new functions.https.HttpsError('internal', e.message);
    }
});

export const obtenerConfiguracion = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
    try {
        const config = await configuracionSistema.obtenerConfiguracion();
        return { config };
    } catch (e: any) {
        throw new functions.https.HttpsError('internal', e.message);
    }
});
