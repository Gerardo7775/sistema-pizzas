"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.obtenerConfiguracion = exports.guardarConfiguracion = void 0;
const https_1 = require("firebase-functions/v2/https");
const zod_1 = require("zod");
const firestore_config_repository_1 = require("../../../infrastructure/repositories/firestore/firestore_config_repository");
const configuracion_sistema_1 = require("../../../application/usecases/configuracion_sistema");
const configRepo = new firestore_config_repository_1.FirestoreConfigRepository();
const configuracionSistema = new configuracion_sistema_1.ConfiguracionSistema(configRepo);
const saveConfigSchema = zod_1.z.object({
    stockBajoGlobal: zod_1.z.boolean(),
    umbralStockBajo: zod_1.z.number(),
    moneda: zod_1.z.string().default('MXN')
});
exports.guardarConfiguracion = (0, https_1.onCall)(async (request) => {
    try {
        const parsed = saveConfigSchema.parse(request.data);
        await configuracionSistema.guardarConfiguracion(parsed);
        return { success: true };
    }
    catch (e) {
        throw new https_1.HttpsError('internal', e.message);
    }
});
exports.obtenerConfiguracion = (0, https_1.onCall)(async (request) => {
    try {
        const config = await configuracionSistema.obtenerConfiguracion();
        return { config };
    }
    catch (e) {
        throw new https_1.HttpsError('internal', e.message);
    }
});
//# sourceMappingURL=config.js.map