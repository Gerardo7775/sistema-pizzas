"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.FirestoreInventoryRepository = void 0;
const admin = __importStar(require("firebase-admin"));
const insumo_1 = require("../../../domain/entities/insumo");
class FirestoreInventoryRepository {
    constructor() {
        this.collection = admin.firestore().collection('insumos');
    }
    async crear(insumo) {
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
    async actualizar(insumo) {
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
    async obtenerPorId(id) {
        const doc = await this.collection.doc(id).get();
        if (!doc.exists)
            return null;
        const data = doc.data();
        return new insumo_1.Insumo(doc.id, data.nombre, data.unidad, data.stockActual, data.stockMinimo, data.costoUnitario, data.activo);
    }
    async listar() {
        const snapshot = await this.collection.get();
        return snapshot.docs.map(doc => {
            const data = doc.data();
            return new insumo_1.Insumo(doc.id, data.nombre, data.unidad, data.stockActual, data.stockMinimo, data.costoUnitario, data.activo);
        });
    }
}
exports.FirestoreInventoryRepository = FirestoreInventoryRepository;
//# sourceMappingURL=firestore_inventory_repository.js.map