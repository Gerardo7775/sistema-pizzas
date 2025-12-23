
# Especificación de Back-End (Arquitectura Limpia) – Ecosistema Pizzería (Firebase)

> **Alcance:** Documento técnico del **back-end** para el ecosistema de pizzería basado en **Firebase** (Cloud Functions, Firestore, Storage, FCM, Remote Config). Se adopta un enfoque de **Arquitectura Limpia** para separar dominio, aplicación y detalles de infraestructura, manteniendo testabilidad y coherencia con el front.

---

## 1. Objetivos y Alcance
- Garantizar **consistencia transaccional** en pedidos e inventario.
- Automatizar **cierre diario** y **corte dominical** (22:00) con funciones programadas.
- Orquestar **notificaciones** (FCM) a repartidores y operadores.
- Exponer **entrypoints** (HTTPS/Callable/Triggers) claramente definidos.
- Asegurar **seguridad**, **observabilidad** y **rendimiento** en entorno serverless.

---

## 2. Principios de Arquitectura Limpia (Back-End)
- **Dominio independiente**: no conoce Firebase ni frameworks; modela entidades, VO y reglas.
- **Aplicación (use cases)**: coordina reglas del dominio y define puertos (repositorios) que la infraestructura implementa.
- **Infraestructura**: adapters concretos (Firestore/Storage/FCM/Remote Config) implementan repos.
- **Entrypoints**: capa de interfaz (HTTP/Callable/Triggers/Scheduler) traduce eventos/requests a use cases.
- **Dependencia hacia adentro**: entrypoints/infra dependen de aplicación/dominio; nunca al revés.

---

## 3. Capas y Responsabilidades

### 3.1 Dominio
- **Entidades**: `Pedido`, `Entrega`, `Insumo`, `Producto`, `Cliente`, `MovimientoInventario`, `Usuario`, `Configuracion`.
- **Value Objects**: `Precio`, `Cantidad`, `Telefono`, `Ubicacion`, `Hora`, `ID`.
- **Reglas de negocio** (ejemplos):
  - Un pedido solo pasa a **Preparación** si la receta puede cubrirse con stock.
  - Bloqueo de productos si insumo crítico agotado.
  - Medición de tiempos de **preparación** y **entrega** con umbrales.

### 3.2 Aplicación (Use Cases)
- `CapturarPedido`
- `ConfirmarPedido`
- `ActualizarEstadoPedido`
- `RegistrarConsumoInventario`
- `AsignarRepartidor`
- `MarcarEntregando` / `MarcarEntregado`
- `CierreDiario` / `CorteDominical`
- `NotificarRepartidor` / `NotificarEntrega`

### 3.3 Infraestructura
- **Repositorios (adapters)**:
  - `FirestorePedidosRepository`
  - `FirestoreInventarioRepository`
  - `FirestoreEntregasRepository`
  - `FirestoreClientesRepository`
  - `RemoteConfigRepository`
  - `MessagingRepository` (FCM)
  - `StorageRepository`
- **Servicios transversales**: `Logger`, `Clock`, `IdGenerator`, `Validator`.

### 3.4 Entrypoints
- **HTTPS**: Endpoints REST mínimos (para integraciones externas o paneles).
- **Callable**: funciones invocables desde el front (seguras y tipadas).
- **Triggers**: `onCreate/onUpdate` en `pedidos` y `entregas` para automatización.
- **Scheduler**: funciones programadas (cierre diario, corte dominical 22:00).

---

## 4. Estructura del Proyecto (Cloud Functions con TypeScript)
```text
functions/
  src/
    domain/
      entities/
      value-objects/
      errors/
      rules/
    application/
      usecases/
      ports/                 # interfaces de repositorios
    infrastructure/
      repositories/
        firestore/
        storage/
        messaging/
        remote-config/
      services/
        logger.ts
        clock.ts
        validator.ts
      mappers/
    entrypoints/
      http/
      callable/
      triggers/
      scheduler/
    config/
    utils/
    index.ts
  package.json
  tsconfig.json
  firebase.json
  .firebaserc
```

---

## 5. Dependencias (Node.js/TypeScript)
```json
{
  "dependencies": {
    "firebase-admin": "^12.5.0",
    "firebase-functions": "^5.0.0",
    "zod": "^3.23.8",                // validaciones de entrada
    "dayjs": "^1.11.11",             // fechas/horarios
    "pino": "^9.3.0"                 // logging estructurado
  },
  "devDependencies": {
    "typescript": "^5.6.3",
    "ts-node": "^10.9.2",
    "jest": "^29.7.0",
    "ts-jest": "^29.2.4",
    "@types/jest": "^29.5.12"
  },
  "engines": { "node": "^20" }
}
```
> **Nota:** Versiones indicativas. Ajustar y bloquear en CI/CD.

---

## 6. Entrypoints y Contratos

### 6.1 Callable – `confirmarPedido`
- **Input**: datos del pedido y receta.
- **Proceso**: validación con `zod` → use case `ConfirmarPedido` → transacción Firestore → envío FCM.
- **Output**: `Result` con ID de pedido y estado.

```ts
// entrypoints/callable/confirmarPedido.ts
import * as functions from 'firebase-functions';
import { z } from 'zod';
import { ConfirmarPedido } from '../../application/usecases/confirmar-pedido';

const schema = z.object({ /* campos del pedido */ });
export const confirmarPedido = functions.https.onCall(async (data, context) => {
  // Autenticación
  if (!context.auth) throw new functions.https.HttpsError('unauthenticated', 'Login requerido');
  const parsed = schema.parse(data);
  const uc = new ConfirmarPedido(/* inyectar repos */);
  return uc.execute(parsed);
});
```

### 6.2 HTTPS – Endpoints REST mínimos
- `POST /api/pedidos` → `CapturarPedido`
- `PATCH /api/pedidos/:id/estado` → `ActualizarEstadoPedido`

```ts
// entrypoints/http/pedidos.ts
import * as functions from 'firebase-functions';
import express from 'express';
const app = express();
app.post('/api/pedidos', /* handler */);
app.patch('/api/pedidos/:id/estado', /* handler */);
export const api = functions.https.onRequest(app);
```

### 6.3 Triggers – Automatización
- `onCreate(pedidos/*)` → validar consistencia y notificar.
- `onUpdate(entregas/*)` → calcular `tiempo_transito` y notificar **entregado**.

```ts
// entrypoints/triggers/pedidos.onCreate.ts
import * as functions from 'firebase-functions';
export const onPedidoCreate = functions.firestore
  .document('pedidos/{pedidoId}')
  .onCreate(async (snap, context) => {
    // Recalcular métricas, emitir notificaciones si aplica
  });
```

### 6.4 Scheduler – Cierre Diario y Corte Dominical (22:00)
```ts
// entrypoints/scheduler/cortes.ts
import * as functions from 'firebase-functions';
export const cierreDiario = functions.pubsub.schedule('every day 23:00').timeZone('America/Mexico_City').onRun(async () => {
  // consolidar ventas e inventario
});

export const corteDominical = functions.pubsub.schedule('every sunday 22:00').timeZone('America/Mexico_City').onRun(async () => {
  // consolidar inventario y dinero; generar reportes
});
```

---

## 7. Transacciones y Consistencia (Firestore)
- **Transacción** para confirmar pedido:
  1. Leer receta (`productos.receta`) y stock (`insumos.stock_actual`).
  2. Validar umbrales y bloqueos.
  3. Descontar insumos y crear `movimientos_inventario`.
  4. Persistir `pedido` con estado **Preparación**.
- **Batch** en operaciones múltiples (evitar documentos calientes; particionar por insumo).

```ts
// infrastructure/repositories/firestore/pedidos.ts
await db.runTransaction(async (tx) => {
  // reads de insumos + writes de pedido y movimientos
});
```

---

## 8. Notificaciones (FCM)
- **Tópicos**: `/topics/repartidores` para nuevas entregas.
- **Data payload**: `{ accion: 'abrir_entrega', entrega_id }`.
- **Confirmaciones**: notificar a operador al marcar **Entregado**.

```ts
// infrastructure/repositories/messaging/messaging.ts
await messaging.send({
  topic: 'repartidores',
  notification: { title: 'Nuevo pedido', body: `Pedido #${id} listo` },
  data: { accion: 'abrir_entrega', entrega_id: id }
});
```

---

## 9. Configuración y Parámetros
- **Región**: `functions.region('us-central1')` (o la más cercana a la operación real).
- **Memoria/Timeout**: asignar en entrypoints críticos (p.ej., 256MB, 60s).
- **Secrets**: `functions.params` / Secret Manager para claves externas (si aplica).
- **Remote Config**: umbrales de inventario y tiempos máximos.

---

## 10. Seguridad
- **Auth** obligatorio en Callable/REST; validar **Custom Claims** (`admin`, `operador`, `repartidor`).
- **Validación** con `zod` en todos los entrypoints.
- **Idempotencia**: claves por operación (p.ej., `pedidoIdempotencyKey`) en confirmación.
- **Rate limits** y protección de abuso en endpoints públicos (si existen).
- Cumplimiento de **Firestore/Storage Rules**; el back usa **admin SDK** con responsabilidad.

---

## 11. Observabilidad y Registro
- **Logging estructurado** (`pino`) con correlación por `pedidoId`/`entregaId`.
- **Alertas** en errores críticos (Cloud Logging Metrics → alertas Ops). 
- Métricas de uso: latencia por entrypoint, tasa de errores, cold starts.

---

## 12. Pruebas (Emulator Suite + Jest)
- **Unit**: use cases y mappers del dominio/aplicación.
- **Integration**: repos Firestore/FCM/Remote Config con **Emulators**.
- **End-to-end** (selectivo): flujo `ConfirmarPedido` → `MarcarEntregado`.

```bash
firebase emulators:start --only functions,firestore,auth,storage
npm run test
```

---

## 13. Despliegue y Versionado
- Entornos: `dev`, `staging`, `prod` con proyectos Firebase separados.
- CI/CD: lint + tests + deploy selectivo (`firebase deploy --only functions:api,functions:confirmarPedido,...`).
- **Versionado semántico** y `CHANGELOG.md`.

---

## 14. Anti-Patrones y Buenas Prácticas
- **No** mezclar lógica de negocio en triggers; delegar a **use cases**.
- **No** escribir directamente desde entrypoints a Firestore; usar **repositorios**.
- **Sí** centralizar validaciones y mapeos.
- **Sí** aislar dependencias; evitar acoplar dominio a Firebase.

---

## 15. Ejemplos de Código (TypeScript)

### 15.1 Use Case `ConfirmarPedido`
```ts
// application/usecases/confirmar-pedido.ts
export class ConfirmarPedido {
  constructor(
    private pedidos: PedidosPort,
    private inventario: InventarioPort,
    private messaging: MessagingPort,
    private clock: Clock
  ) {}

  async execute(input: ConfirmarPedidoInput): Promise<ConfirmarPedidoOutput> {
    // Validar receta vs stock
    // Transaccionar pedido + consumo
    // Notificar repartidores
    return { id: '...', estado: 'preparacion' };
  }
}
```

### 15.2 Scheduler `corteDominical`
```ts
// entrypoints/scheduler/corte-dominical.ts
export const corteDominical = functions.pubsub
  .schedule('every sunday 22:00')
  .timeZone('America/Mexico_City')
  .onRun(async () => {
    // Leer ventas/insumos, consolidar y guardar en colección de cortes
  });
```

---

**Este back-end, organizado por Arquitectura Limpia, provee consistencia, seguridad y escalabilidad para el ecosistema de pizzería sobre Firebase, manteniendo el dominio independiente y la infraestructura reemplazable.**
