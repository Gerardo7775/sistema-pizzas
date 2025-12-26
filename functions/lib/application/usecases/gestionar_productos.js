"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GestionarProductos = void 0;
const producto_1 = require("../../domain/entities/producto");
class GestionarProductos {
    constructor(productRepo) {
        this.productRepo = productRepo;
    }
    async crearProducto(data) {
        const id = data.nombre.toLowerCase().replace(/\s+/g, '_');
        const producto = producto_1.Producto.create(Object.assign(Object.assign({}, data), { id }));
        await this.productRepo.crear(producto);
        return id;
    }
    async actualizarProducto(id, data) {
        const producto = await this.productRepo.obtenerPorId(id);
        if (!producto)
            throw new Error("Producto no encontrado");
        if (data.nombre)
            producto.nombre = data.nombre;
        if (data.descripcion)
            producto.descripcion = data.descripcion;
        if (data.precio !== undefined)
            producto.precio = data.precio;
        if (data.receta)
            producto.receta = data.receta;
        if (data.activo !== undefined)
            producto.activo = data.activo;
        await this.productRepo.actualizar(producto);
    }
    async listarProductos() {
        return this.productRepo.listar();
    }
}
exports.GestionarProductos = GestionarProductos;
//# sourceMappingURL=gestionar_productos.js.map