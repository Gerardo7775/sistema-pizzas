"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Producto = void 0;
class Producto {
    constructor(id, nombre, descripcion, precio, receta, activo = true) {
        this.id = id;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.precio = precio;
        this.receta = receta;
        this.activo = activo;
    }
    static create(props) {
        if (props.precio < 0)
            throw new Error("Price cannot be negative");
        return new Producto(props.id, props.nombre, props.descripcion, props.precio, props.receta);
    }
    // Validar si hay stock suficiente dado un map de stock actual
    validarStock(stockMap) {
        for (const item of this.receta) {
            const stock = stockMap.get(item.insumoId) || 0;
            if (stock < item.cantidad)
                return false;
        }
        return true;
    }
}
exports.Producto = Producto;
//# sourceMappingURL=producto.js.map