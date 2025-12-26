import { onCall, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
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

export const guardarConfiguracion = onCall(async (request: CallableRequest) => {
    try {
        const parsed = saveConfigSchema.parse(request.data);
        await configuracionSistema.guardarConfiguracion(parsed);
        return { success: true };
    } catch (e: any) {
        throw new HttpsError('internal', e.message);
    }
});

export const obtenerConfiguracion = onCall(async (request: CallableRequest) => {
    try {
        const config = await configuracionSistema.obtenerConfiguracion();
        return { config };
    } catch (e: any) {
        throw new HttpsError('internal', e.message);
    }
});
