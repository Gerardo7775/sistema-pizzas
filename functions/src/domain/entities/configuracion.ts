export class Configuracion {
    constructor(
        public readonly id: string, // e.g., 'global' or 'alerts'
        public stockBajoGlobal: boolean,
        public umbralStockBajo: number, // Default threshold if not specified per insumo
        public moneda: string = 'MXN'
    ) { }
}
