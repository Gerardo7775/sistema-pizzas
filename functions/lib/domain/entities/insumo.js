"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Insumo = void 0;
class Insumo {
    constructor(id, nombre, unidad, // 'kg', 'litro', 'pieza'
    stockActual, stockMinimo, costoUnitario, activo = true) {
        this.id = id;
        this.nombre = nombre;
        this.unidad = unidad;
        this.stockActual = stockActual;
        this.stockMinimo = stockMinimo;
        this.costoUnitario = costoUnitario;
        this.activo = activo;
    }
    static create(props) {
        if (props.stockActual < 0)
            throw new Error("Stock cannot be negative");
        return new Insumo(props.id, props.nombre, props.unidad, props.stockActual, props.stockMinimo, props.costoUnitario);
    }
    actualizarStock(cantidad) {
        const nuevoStock = this.stockActual + cantidad;
        if (nuevoStock < 0)
            throw new Error("Resulting stock cannot be negative");
        this.stockActual = nuevoStock;
    }
}
exports.Insumo = Insumo;
//# sourceMappingURL=insumo.js.map