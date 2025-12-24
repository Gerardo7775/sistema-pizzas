import { Producto, RecetaItem } from "../../domain/entities/producto";
import { ProductRepository } from "../../domain/ports/product_repository";

export class GestionarProductos {
    constructor(private productRepo: ProductRepository) { }

    async crearProducto(data: {
        nombre: string;
        descripcion: string;
        precio: number;
        receta: RecetaItem[];
    }): Promise<string> {
        const id = data.nombre.toLowerCase().replace(/\s+/g, '_');
        const producto = Producto.create({ ...data, id });
        await this.productRepo.crear(producto);
        return id;
    }

    async actualizarProducto(id: string, data: Partial<Producto>): Promise<void> {
        const producto = await this.productRepo.obtenerPorId(id);
        if (!producto) throw new Error("Producto no encontrado");

        if (data.nombre) producto.nombre = data.nombre;
        if (data.descripcion) producto.descripcion = data.descripcion;
        if (data.precio !== undefined) producto.precio = data.precio;
        if (data.receta) producto.receta = data.receta;
        if (data.activo !== undefined) producto.activo = data.activo;

        await this.productRepo.actualizar(producto);
    }

    async listarProductos(): Promise<Producto[]> {
        return this.productRepo.listar();
    }
}
