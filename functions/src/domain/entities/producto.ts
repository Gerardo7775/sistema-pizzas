export interface RecetaItem {
    insumoId: string;
    cantidad: number; // Cantidad requerida por insumo
}

export class Producto {
    constructor(
        public readonly id: string,
        public nombre: string,
        public descripcion: string,
        public precio: number,
        public receta: RecetaItem[],
        public activo: boolean = true
    ) { }

    static create(props: {
        id: string;
        nombre: string;
        descripcion: string;
        precio: number;
        receta: RecetaItem[];
    }): Producto {
        if (props.precio < 0) throw new Error("Price cannot be negative");
        return new Producto(
            props.id,
            props.nombre,
            props.descripcion,
            props.precio,
            props.receta
        );
    }

    // Validar si hay stock suficiente dado un map de stock actual
    validarStock(stockMap: Map<string, number>): boolean {
        for (const item of this.receta) {
            const stock = stockMap.get(item.insumoId) || 0;
            if (stock < item.cantidad) return false;
        }
        return true;
    }
}
