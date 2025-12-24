export class Insumo {
    constructor(
        public readonly id: string,
        public nombre: string,
        public unidad: string, // 'kg', 'litro', 'pieza'
        public stockActual: number,
        public stockMinimo: number,
        public costoUnitario: number,
        public activo: boolean = true
    ) { }

    static create(props: {
        id: string;
        nombre: string;
        unidad: string;
        stockActual: number;
        stockMinimo: number;
        costoUnitario: number;
    }): Insumo {
        if (props.stockActual < 0) throw new Error("Stock cannot be negative");
        return new Insumo(
            props.id,
            props.nombre,
            props.unidad,
            props.stockActual,
            props.stockMinimo,
            props.costoUnitario
        );
    }

    actualizarStock(cantidad: number): void {
        const nuevoStock = this.stockActual + cantidad;
        if (nuevoStock < 0) throw new Error("Resulting stock cannot be negative");
        this.stockActual = nuevoStock;
    }
}
