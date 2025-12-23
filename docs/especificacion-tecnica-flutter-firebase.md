
# Especificación Técnica del Proyecto (Flutter + Firebase)

> **Alcance:** Documento técnico centrado en la implementación Flutter con Firebase como base de datos y servicios. **No se aborda arquitectura a nivel de proyecto (back/front)**; se detallan modelos de datos, configuraciones, reglas de seguridad, flujos técnicos, dependencias, pruebas, rendimiento y operación.

## 1. Entorno y Configuración

### 1.1 Plataformas objetivo
- **Android**: SDK 24+ (Android 7.0+), soporte para permisos de ubicación y notificaciones.
- **iOS**: iOS 13+, habilitar Push Notifications, Background Modes y Keychain.
- **Web** (opcional para paneles internos): configuración de Firebase Hosting y Service Worker para FCM.

### 1.2 Configuración inicial de Firebase
1. Crear proyecto en Firebase Console.
2. Registrar apps (Android, iOS, Web) y agregar archivos:
   - `google-services.json` (Android, en `android/app/`)
   - `GoogleService-Info.plist` (iOS, en `ios/Runner/`)
   - Configuración Web (`firebaseConfig`) para inicialización.
3. Habilitar servicios:
   - **Authentication**: Email/Password, Phone (opcional), OAuth (Google, Apple).
   - **Cloud Firestore**: Modo producción.
   - **Cloud Storage**: para imágenes de productos y evidencias de entrega.
   - **Cloud Messaging (FCM)**: notificaciones.
   - **Remote Config**: umbrales y tiempos máximos.

### 1.3 Dependencias recomendadas (Flutter)
```yaml
# pubspec.yaml (extracto)
dependencies:
  flutter: { sdk: flutter }
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.0
  firebase_auth: ^5.3.0
  firebase_storage: ^12.2.0
  firebase_messaging: ^15.1.0
  firebase_remote_config: ^5.0.4
  cloud_functions: ^5.0.3  # Usar solo para integraciones puntuales; evitar lógica crítica aquí
  google_maps_flutter: ^2.9.0  # Ubicación del cliente (opcional)
  geolocator: ^12.0.0        # Ubicación del repartidor
  url_launcher: ^6.3.0       # Deep links a WhatsApp
  intl: ^0.19.0              # Formateo de fechas/moneda
  flutter_local_notifications: ^17.2.0
  provider: ^6.0.0           # Estado (o Riverpod/Bloc según preferencia)
  uuid: ^4.5.1               # IDs locales
  collection: ^1.18.0

dev_dependencies:
  flutter_test: { sdk: flutter }
  mockito: ^5.4.4
  flutter_lints: ^4.0.0
```

> **Nota:** Versiones indicativas. Fijar versiones en entorno real y habilitar `--locked` en CI.

### 1.4 Inicialización en Flutter
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}
```

## 2. Modelo de Datos (Cloud Firestore)

### 2.1 Colecciones principales
- `insumos`: Materia prima (inventario).
- `productos`: Catálogo (pizzas y otros), incluye receta.
- `clientes`: Datos del cliente, historial básico.
- `pedidos`: Entidades de pedido con estados y tiempos.
- `entregas`: Seguimiento de entrega por repartidor.
- `movimientos_inventario`: Ajustes, mermas, consumos.
- `config`: Documentos de configuración (umbrales, horarios, cierre diario, corte dominical).
- `usuarios`: Perfil y roles de acceso.

### 2.2 Esquemas de documento (referencia)
```json
// insumos/{insumoId}
{
  "nombre": "Queso mozzarella",
  "unidad": "kg",
  "stock_actual": 14.5,
  "stock_minimo": 5,
  "vida_util": 14,                // días
  "fecha_ultima_compra": 1734652800000, // epoch ms
  "caducidad": 1735344000000,     // epoch ms (opcional)
  "activo": true,
  "created_at": 1734300000000,
  "updated_at": 1734652800000
}

// productos/{productoId}
{
  "nombre": "Pizza Pepperoni",
  "categoria": "pizza",
  "precio_base": 149.0,
  "especialidades": ["Grande", "Mediana"],
  "receta": [
    {"insumo_id": "queso", "cantidad": 0.3, "unidad": "kg"},
    {"insumo_id": "harina", "cantidad": 0.25, "unidad": "kg"},
    {"insumo_id": "pepperoni", "cantidad": 20, "unidad": "pieza"}
  ],
  "activo": true,
  "created_at": 1734300000000,
  "updated_at": 1734652800000
}

// clientes/{clienteId}
{
  "nombre": "Juan Pérez",
  "telefono": "+5215512345678",
  "direcciones": [
    {"alias": "Casa", "lat": 19.4326, "lng": -99.1332, "texto": "Calle Falsa 123"}
  ],
  "preferencias_pago": "efectivo",
  "frecuente": true,
  "created_at": 1734300000000,
  "updated_at": 1734652800000
}

// pedidos/{pedidoId}
{
  "canal": "whatsapp", // o "app"
  "estado": "preparacion", // capturado | preparacion | entregando | entregado
  "cliente_id": "...",
  "total": 298.0,
  "tipo_pago": "efectivo", // tarjeta | transferencia | etc.
  "referencia_pago": null,
  "cambio": 2.0,
  "ubicacion": {"lat": 19.4326, "lng": -99.1332, "texto": "Calle Falsa 123"},
  "hora_recepcion": 1734656400000,
  "hora_estimada_entrega": 1734660000000,
  "detalles": [
    {"producto_id": "pizza_pepperoni", "especialidad": "Grande", "cantidad": 2, "precio": 149.0}
  ],
  "tiempos": {
    "inicio_preparacion": 1734656500000,
    "salida_entrega": null,
    "hora_entrega": null
  },
  "created_by": "operadorId",
  "created_at": 1734656400000,
  "updated_at": 1734656500000
}

// entregas/{entregaId}
{
  "pedido_id": "...",
  "repartidor_id": "...",
  "estado": "entregando", // asignado | entregando | entregado
  "ubicacion_destino": {"lat": 19.4326, "lng": -99.1332},
  "hora_salida": 1734657000000,
  "hora_llegada": null,
  "tiempo_transito": null,
  "evidencias": [{"storage_path": "entregas/.../foto.jpg"}],
  "created_at": 1734656900000,
  "updated_at": 1734657000000
}

// movimientos_inventario/{movId}
{
  "insumo_id": "queso",
  "tipo": "consumo", // alta | ajuste | merma | consumo
  "cantidad": 0.6,
  "unidad": "kg",
  "pedido_id": "...", // si aplica
  "usuario_id": "...",
  "fecha": 1734656500000,
  "nota": "Consumo por pedido",
  "created_at": 1734656500000
}

// config/{docId}
{
  "horarios_habiles": {
    "dias": ["Lun","Mar","Mié","Jue","Vie","Sáb","Dom"],
    "apertura": "11:00",
    "cierre": "23:00"
  },
  "cierre_diario": {"enabled": true, "hora": "23:00"},
  "corte_dominical": {"enabled": true, "hora": "22:00"},
  "umbrales": {"inventario_bajo": 0.2},
  "politica_bloqueo": {"habilitado": true}
}

// usuarios/{uid}
{
  "nombre": "Operador",
  "rol": "operador", // admin | operador | repartidor
  "telefono": "+5215512345678",
  "activo": true
}
```

### 2.3 Índices sugeridos (Firestore)
- `pedidos`: índice compuesto por `estado ASC`, `hora_recepcion DESC` (para colas).
- `entregas`: `repartidor_id ASC`, `estado ASC`, `hora_salida DESC`.
- `movimientos_inventario`: `insumo_id ASC`, `fecha DESC`.
- `insumos`: `activo ASC`, `stock_actual ASC`.

> Configurar en Firebase Console: Firestore → Indexes. Documentar IDs generados automáticamente.

## 3. Reglas de Seguridad (Firestore/Storage)

### 3.1 Firestore Security Rules
```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }
    function hasRole(role) {
      return isSignedIn() && role in request.auth.token.roles;
    }

    match /usuarios/{uid} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == uid; // el propio usuario
    }

    match /insumos/{doc} {
      allow read: if hasRole('operador') || hasRole('admin');
      allow write: if hasRole('admin');
    }

    match /productos/{doc} {
      allow read: if true; // catálogo público
      allow write: if hasRole('admin');
    }

    match /clientes/{doc} {
      allow read, write: if hasRole('operador') || hasRole('admin');
    }

    match /pedidos/{doc} {
      allow read: if hasRole('operador') || hasRole('admin') || hasRole('repartidor');
      allow create: if hasRole('operador') || hasRole('admin');
      allow update: if hasRole('operador') || hasRole('admin');
    }

    match /entregas/{doc} {
      allow read: if hasRole('operador') || hasRole('admin') || hasRole('repartidor');
      allow create: if hasRole('operador') || hasRole('admin');
      allow update: if hasRole('repartidor') || hasRole('operador') || hasRole('admin');
    }

    match /movimientos_inventario/{doc} {
      allow read: if hasRole('operador') || hasRole('admin');
      allow create: if hasRole('operador') || hasRole('admin');
    }

    match /config/{doc} {
      allow read: if hasRole('operador') || hasRole('admin');
      allow write: if hasRole('admin');
    }
  }
}
```

> **Roles**: se recomiendan **Custom Claims** en Firebase Auth para `admin`, `operador`, `repartidor`.

### 3.2 Cloud Storage Rules
```js
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /entregas/{path=**} {
      allow read: if request.auth != null; // repartidores y operadores
      allow write: if request.auth != null; // subir evidencias
    }
    match /productos/{path=**} {
      allow read: if true; // imágenes públicas
      allow write: if request.auth != null && request.auth.token.roles.hasAny(['admin']);
    }
  }
}
```

## 4. Flujos Técnicos Clave

### 4.1 Captura y Confirmación de Pedido
1. Operador ingresa datos del pedido (WhatsApp o app).
2. Validación de inventario contra receta: lectura de `productos.receta` y `insumos.stock_actual`.
3. Cálculo de total y tiempo estimado (Remote Config puede aportar umbrales).
4. Persistencia en `pedidos` y generación de `movimientos_inventario` de tipo `consumo`.
5. Notificación FCM a repartidores disponibles (tópico `repartidores` o token específico).

### 4.2 Asignación y Entrega
1. Repartidor recibe notificación con detalles.
2. Marca **Entregando**: actualización de `pedidos.estado` y creación/actualización en `entregas`.
3. Seguimiento de ubicación (opcional) con `geolocator` para medir tiempos.
4. Marca **Entregado**: se registran `hora_llegada` y tiempos; se dispara notificación de confirmación.

### 4.3 Cierre Diario y Corte Dominical
- En el cliente (Flutter) se programa trabajo en **background** (según plataforma) para:
  - Recalcular métricas del día y leer configuraciones de `config`.
  - Generar reportes locales y/o marcar estados de jornada.
- Remote Config controla hora de ejecución y umbrales.

> **Nota:** Evitar lógica crítica dependiente de procesos en background en cliente. Para consolidaciones, usar lectura de datos y vistas calculadas en tiempo real.

## 5. Notificaciones (FCM)

### 5.1 Suscripción y tokens
- Guardar `fcm_token` en `usuarios/{uid}` y tópicos por rol (`/topics/repartidores`).

### 5.2 Ejemplo de payload
```json
{
  "to": "/topics/repartidores",
  "notification": {
    "title": "Nuevo pedido asignado",
    "body": "Pedido #123 listo para entrega"
  },
  "data": {
    "pedido_id": "123",
    "accion": "abrir_entrega"
  }
}
```

### 5.3 Manejo en Flutter
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Mostrar notificación local si la app está en foreground
});

FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Navegar a detalle de entrega/pedido
});
```

## 6. Integraciones

### 6.1 WhatsApp (deep link)
- Uso de `url_launcher` con esquema `https://wa.me/<telefono>?text=<mensaje>` para prellenar detalles.
- Plantillas de mensaje construidas desde datos de `pedidos`.

### 6.2 Mapas y ubicación
- `google_maps_flutter` para mostrar destino del cliente.
- `geolocator` para obtener posición del repartidor y estimar tiempo de tránsito.

## 7. Consideraciones de Rendimiento
- **Lecturas paginadas** y **consultas con límites** (p.ej., `limit(50)` en colas).
- **Cache y offline**: habilitar `settings = const Settings(persistenceEnabled: true)` en Firestore.
- **Escrituras atómicas**: usar `WriteBatch` para pedido + consumo de inventario.
- **Minimizar documentos calientes**: evitar contadores globales; usar agregaciones a nivel cliente.
- **Indexación**: mantener índices compuestos documentados.

## 8. Gestión de Estados y Sincronización
- Estado local con `provider` (o Riverpod/Bloc) por módulos: pedidos, inventario, entregas.
- **Streams** de Firestore para colas de pedidos y entregas.
- **Debounce** en entradas de usuario (búsqueda de clientes, productos).
- **Optimistic UI**: actualizar UI previo a confirmación de escritura y reconciliar en errores.

## 9. Validaciones y Reglas de Negocio (Cliente)
- Bloquear confirmación si receta no puede cubrirse con stock disponible.
- Alertar por **inventario bajo** según `config.umbrales`.
- Medición de **tiempos**: diferenciar preparación y tránsito.
- Preventivo: no permitir transición a `preparacion` si `productos.activo == false` o insumo crítico agotado.

## 10. Pruebas

### 10.1 Unit tests
- Modelos (serialización/deserialización) para `Pedido`, `Entrega`, `Insumo`.
- Cálculo de tiempos y validaciones de stock.

### 10.2 Integration tests
- Flujo de captura → confirmación → entrega.
- Reglas de Firestore (usar emuladores) y Storage.
- Notificaciones FCM (mock de onMessage/onMessageOpenedApp).

### 10.3 End-to-end (opcional)
- Scripts con `flutter_driver`/`integration_test` para escenarios de pico de pedidos.

## 11. Observabilidad y Registro
- Logging client-side (niveles: info/warn/error) con etiquetas de módulo.
- Trazabilidad: IDs de pedido y entrega en logs.
- Errores críticos: reporte a Crashlytics (opcional).

## 12. Internacionalización y Formato
- Uso de `intl` para moneda y fechas; zona horaria local.
- Textos externos en colecciones `config_textos` (opcional) para mensajes parametrizables.

## 13. Accesibilidad y UX Técnica
- Notificaciones locales con acciones (marcar "Entregando", "Entregado").
- Permisos de ubicación con racionales y fallback.
- Manejadores de estados vacíos y errores de red.

## 14. Seguridad adicional (cliente)
- Enmascarar números telefónicos en UI cuando sea necesario.
- Validar entradas (precios ≥ 0, cantidades enteras, fechas válidas).
- Evitar almacenar datos sensibles en preferencias sin cifrado.

## 15. Publicación y Versionado
- Incremento de `version`/`buildNumber` por release.
- Firmas: keystore (Android), certificados (iOS).
- Variantes de build: `dev`, `staging`, `prod` con `firebase_options` por ambiente.

## 16. Riesgos y Mitigaciones
- **Desincronización de inventario** por operaciones concurrentes → usar `WriteBatch` y validaciones en cliente.
- **Latencia en notificaciones** → fallback a chat interno y refresco en tiempo real.
- **Permisos de ubicación** denegados → permitir confirmación manual de tiempos.

---
**Este documento sirve como guía técnica de implementación para Flutter + Firebase, alineado con los requerimientos del ecosistema (inventario, pedidos, reparto), sin entrar en arquitectura de back/front.**
