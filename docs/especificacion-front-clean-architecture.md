
# Especificación de Front-End con Patrón de Arquitectura Limpia (Flutter)

> **Objetivo:** Definir una especificación técnica del **front-end** para el ecosistema de pizzería (Inventario/Contabilidad, Controladora de Pedidos y Repartidor) utilizando **Flutter**, siguiendo **Arquitectura Limpia**. Se describen capas, contratos, flujos, convenciones, pruebas, rendimiento y operación **sin entrar en arquitectura de back-end**.

---

## 1. Principios
- **Separación de responsabilidades**: UI desacoplada de lógica de negocio y acceso a datos.
- **Dependencia hacia adentro**: capas externas dependen de la capa de **Dominio**.
- **Testabilidad**: use cases y mapeos probados sin cargar UI ni servicios externos.
- **Independencia de frameworks**: Flutter se usa en **Presentación**; el **Dominio** no conoce Flutter ni Firebase.
- **Consistencia**: patrones repetibles entre las tres apps, con variaciones por objetivo.

## 2. Capas

### 2.1 Dominio (core)
**Propósito:** Modelar reglas del negocio.
- **Entidades** (inmutables donde aplique): `Insumo`, `Producto`, `Cliente`, `Pedido`, `Entrega`, `MovimientoInventario`, `Usuario`, `Configuracion`.
- **Value Objects**: `Telefono`, `Ubicacion`, `Precio`, `Cantidad`, `Hora`, `ID`.
- **Interfaces de Repositorio** (abstracciones):
  - `InventarioRepository`
  - `ProductosRepository`
  - `ClientesRepository`
  - `PedidosRepository`
  - `EntregasRepository`
  - `MovimientosInventarioRepository`
  - `UsuariosRepository`
  - `ConfigRepository`
- **Use Cases** (interactores):
  - Inventario: `RegistrarAltaInsumo`, `RegistrarConsumoPorPedido`, `AjustarInventario`, `DetectarInventarioBajo`.
  - Productos: `ListarProductos`, `ActivarDesactivarProducto`.
  - Clientes: `CrearActualizarCliente`, `BuscarClienteFrecuente`.
  - Pedidos: `CapturarPedido`, `ConfirmarPedido`, `ActualizarEstadoPedido` (→ Preparación/Entregando/Entregado), `CalcularTiempoEstimado`.
  - Entregas: `AsignarRepartidor`, `MarcarEntregando`, `MarcarEntregado`.
  - Configuración: `LeerConfig`, `ActualizarUmbrales`.
  - Usuarios: `Autenticar`, `LeerPerfil`, `ActualizarRol` (solo UI; la asignación de claims la maneja back-office fuera de scope).
- **Errores/Resultados**: patrón `Either<Failure, T>` o `Result<T, Failure>`.

### 2.2 Aplicación (orquestación y estado)
**Propósito:** Coordinar use cases, manejar estado y navegación.
- **State Notifiers/ViewModels/Controllers** por módulo (Provider/Riverpod/BLoC):
  - `InventarioController`, `PedidosController`, `EntregasController`, `ClientesController`, `AuthController`, `ConfigController`.
- **Estados** (sealed): `Loading`, `Loaded`, `Empty`, `Error`, `Updating`.
- **Navegación**: rutas declarativas y guardas por rol.
- **Validadores**: entrada de formularios (`Precio ≥ 0`, `Cantidad > 0`, formatos de teléfono, etc.).

### 2.3 Datos (infra del front)
**Propósito:** Implementar repositorios del Dominio, mapeos y acceso a Firebase desde el front.
- **Datasources** (front): `FirestoreDatasource`, `StorageDatasource`, `MessagingDatasource`, `RemoteConfigDatasource`, `LocationDatasource`.
- **DTOs y Mappers**: `InsumoDto ↔ Insumo`, `PedidoDto ↔ Pedido`, etc.
- **Cache/Offline-first**: habilitar caché de Firestore; caches en memoria por sesión.
- **Policies**: límites de lectura (paginación), reconexión, reintentos idempotentes en writes.

### 2.4 Presentación (Flutter UI)
**Propósito:** Widgets, pantallas, estilos y componentes.
- **Pantallas** por app:
  - **Escritorio (Inventario/Contabilidad)**: `InventarioPage`, `InsumoDetallePage`, `MovimientosPage`, `ReportesPage`, `ConfigPage`.
  - **Controladora de Pedidos**: `ColaPedidosPage`, `CapturaPedidoPage`, `ClientePage`, `DetallePedidoPage`, `ChatRepartidorPage`.
  - **Repartidor**: `EntregasAsignadasPage`, `EntregaDetallePage`, `MapaDestinoPage`, `ConfirmacionEntregaPage`.
- **Componentes UI**: `ProductoCard`, `ClienteTile`, `PedidoListItem`, `EstadoBadge`, `TimerChip`, `WhatsAppButton`, `UbicacionPicker`.
- **Temas y estilos**: `AppTheme`, paleta consistente por app, modo oscuro.
- **Accesibilidad**: labels descriptivos, contraste, navegación por teclado (escritorio), `Semantics` y `GestureDetector` con `hitTestBehavior` adecuado.

---

## 3. Estructura de Directorios (por aplicación)
```text
lib/
  core/                      # Dominio
    entities/
    value_objects/
    failures/
    usecases/
    repositories/            # abstract
  application/               # Orquestación
    controllers/             # Providers/BLoCs
    states/
    navigation/
    validators/
  data/                      # Implementaciones
    datasources/             # firestore, storage, messaging, remote_config, location
    dtos/
    mappers/
    repositories_impl/
  presentation/              # Flutter UI
    pages/
    widgets/
    themes/
    l10n/
  utils/
  di/                        # Inyección de dependencias
```

> Para el ecosistema con tres apps, replicar estructura en cada proyecto (o usar un **workspace** con paquetes compartidos para `core` y `data` comunes si se requiere reutilización, manteniendo separación).

---

## 4. Contratos (Interfaces del Dominio)
```dart
// core/repositories/pedidos_repository.dart
abstract class PedidosRepository {
  Future<Result<List<Pedido>, Failure>> listar({PedidoFiltro? filtro});
  Future<Result<Pedido, Failure>> capturar(Pedido pedido);
  Future<Result<void, Failure>> actualizarEstado(String pedidoId, PedidoEstado nuevoEstado);
}

// core/repositories/inventario_repository.dart
abstract class InventarioRepository {
  Future<Result<List<Insumo>, Failure>> listar();
  Future<Result<void, Failure>> registrarConsumo(String pedidoId, List<ConsumoInsumo> consumos);
  Future<Result<void, Failure>> ajustar(Insumo insumo, AjusteInventario ajuste);
}
```

## 5. Use Cases (Firma y propósito)
```dart
// core/usecases/confirmar_pedido.dart
class ConfirmarPedido {
  final PedidosRepository pedidos;
  final InventarioRepository inventario;

  ConfirmarPedido(this.pedidos, this.inventario);

  Future<Result<void, Failure>> call(Pedido pedido, List<ConsumoInsumo> receta) async {
    // 1) Validar stock
    // 2) Persistir pedido
    // 3) Registrar consumo
    // 4) Emitir eventos (estado, métricas) — solo a través de repositorios
    return Result.ok(null);
  }
}
```

## 6. Estado y Controladores (Aplicación)
```dart
// application/states/pedidos_state.dart
sealed class PedidosState {}
class PedidosLoading extends PedidosState {}
class PedidosLoaded extends PedidosState { final List<Pedido> pedidos; PedidosLoaded(this.pedidos); }
class PedidosError extends PedidosState { final String message; PedidosError(this.message); }

// application/controllers/pedidos_controller.dart
class PedidosController extends ChangeNotifier {
  final ListarPedidos listarPedidos;
  PedidosState state = PedidosLoading();
  Future<void> refresh() async { /* ... */ }
}
```

## 7. Datos: DTOs y Mappers
```dart
// data/dtos/pedido_dto.dart
class PedidoDto {
  final String id;
  final String canal;
  final String estado;
  final String clienteId;
  final double total;
  final Map<String, dynamic> tiempos;
  // ...
  const PedidoDto({required this.id, required this.canal, required this.estado, required this.clienteId, required this.total, required this.tiempos});

  factory PedidoDto.fromFirestore(Map<String, dynamic> doc) => PedidoDto(
    id: doc['id'], canal: doc['canal'], estado: doc['estado'], clienteId: doc['cliente_id'], total: (doc['total'] as num).toDouble(), tiempos: doc['tiempos'] ?? {},
  );

  Map<String, dynamic> toFirestore() => {
    'id': id, 'canal': canal, 'estado': estado, 'cliente_id': clienteId, 'total': total, 'tiempos': tiempos,
  };
}

// data/mappers/pedido_mapper.dart
class PedidoMapper {
  static Pedido toEntity(PedidoDto dto) => Pedido(/* ... */);
  static PedidoDto toDto(Pedido entity) => PedidoDto(/* ... */);
}
```

## 8. Navegación y Rutas (Presentación)
- **Rutas nombradas** por pantalla.
- **Guards** basados en rol (admin/operador/repartidor) y sesión.
- **Deep links** para abrir `DetallePedidoPage` desde notificación.

```dart
// application/navigation/app_router.dart
class AppRoutes {
  static const inventario = '/inventario';
  static const colaPedidos = '/pedidos/cola';
  static const detallePedido = '/pedidos/detalle';
  static const entregas = '/entregas';
}
```

## 9. Formularios y Validaciones
- **Sin lógica de negocio en widgets**: delegar a validadores.
- Reglas:
  - `Precio ≥ 0`, `Cantidad > 0`.
  - Teléfono válido (E.164 opcional).
  - Ubicación con lat/lng o dirección textual.
  - Estado del pedido solo transiciones válidas: `Capturado → Preparación → Entregando → Entregado`.

## 10. Internacionalización (l10n)
- `arb` por app: cadenas para español (y otros si aplica).
- Formateo con `intl` (moneda MXN y fechas locales).

## 11. Temas y Accesibilidad
- Tipografías legibles, tamaño mínimo 14sp.
- Contraste AA/AAA en componentes críticos.
- `Semantics` para lectores de pantalla.
- Navegación por teclado en escritorio (focus traversal, shortcuts).

## 12. Rendimiento
- **Streams** con `distinctUntilChanged` (o selectores) para evitar renders innecesarios.
- **Paginación** en listas (cola de pedidos, movimientos).
- **Memoización** de mapeos DTO→Entidad.
- **Batch** en operaciones compuestas (pedido+consumo) desde repositorio.

## 13. Pruebas (front)
- **Unit**: use cases, mappers, validadores.
- **Widget**: páginas clave (`CapturaPedidoPage`, `EntregasAsignadasPage`).
- **Integración**: navegación y estados; emuladores Firebase para lecturas/escrituras (solo capas de datos front).
- **Cobertura objetivo**: ≥ 75% en `core` y `application`.

## 14. Observabilidad (front)
- Logger con niveles (`info/warn/error`) y etiquetas de módulo.
- IDs de pedido/entrega en eventos de UI.
- Crash reporting (opcional) sin exponer datos sensibles.

## 15. Convenciones de Código
- **Nombres**: `PascalCase` para clases, `camelCase` para métodos/variables.
- **Inmutabilidad** preferente en entidades/value objects.
- **Null-safety** obligatorio, evitar `dynamic`.
- **Documentación**: `///` en contratos y use cases.
- **Imports** por capa (no saltar hacia afuera): Presentación → Aplicación → Dominio; Datos no se importa en Dominio.

## 16. DI (Inyección de Dependencias)
- Registro en `di/` por entorno (`dev`, `prod`).
- Proveer implementaciones de repositorios a controladores vía constructor.
- Evitar singletons globales no controlados; usar proveedores/locators encapsulados.

## 17. Seguridad (cliente)
- No almacenar tokens sensibles en texto plano.
- Sanitizar entradas antes de construir DTOs.
- Validar permisos (ubicación/notificaciones) con flujos de fallback.

## 18. Publicación y Versionado (front)
- Versionado semántico por app.
- `CHANGELOG.md` por release.
- Builds diferenciados (`dev/staging/prod`) con banderas de features (Remote Config).

## 19. Roadmap Técnico (inicial)
- Sprint 1: Configuración de capas y DI, entidades y repositorios abstractos.
- Sprint 2: Mappers + datasources base; pantallas iniciales de captura y cola.
- Sprint 3: Estados y navegación; validaciones; pruebas unitarias.
- Sprint 4: Integración con notificaciones y mapas; optimizaciones de rendimiento.

---
**Esta especificación define un front-end Flutter con Arquitectura Limpia, alineado al dominio del negocio de la pizzería y preparado para escalar manteniendo testabilidad y separación de responsabilidades.**
