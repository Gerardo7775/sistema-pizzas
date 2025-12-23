
# Anexo de Arquitectura: Uso de Dependencias en Front-End (Flutter) 

> **Alcance:** Este anexo complementa la especificación de **Front-End con Arquitectura Limpia** para el ecosistema de pizzería. Se detalla **qué dependencias se usan**, **en qué capa** y **cómo** integrarlas sin romper los principios de la arquitectura. Incluye la navegación con **`go_router`** ("go" para la navegación).

---

## 1. Principios de Integración
- **Dominio sin frameworks**: ninguna dependencia de Firebase/Flutter toca la capa **Dominio**.
- **Datos implementa contratos**: la capa **Datos** implementa repositorios con paquetes Firebase.
- **Aplicación orquesta**: usa gestores de estado, notificaciones y navegación para coordinar casos de uso.
- **Presentación**: `go_router` + widgets; UI desacoplada de lógica.

---

## 2. Mapa de Dependencias por Capa
```mermaid
flowchart LR
  subgraph Dominio
    D1[Entidades/VO]
    D2[Use Cases]
    D3[Repositorios (interfaces)]
  end

  subgraph Datos
    F1[cloud_firestore]
    F2[firebase_storage]
    F3[firebase_auth]
    F4[firebase_remote_config]
    F5[firebase_messaging]
    DS[Datasources]
    DTO[DTOs/Mappers]
    RI[Repos Impl]
  end

  subgraph Aplicacion
    ST[provider/riverpod/bloc]
    NAV[go_router]
    VAL[Validators]
  end

  subgraph Presentacion
    UI[Widgets/Pages]
    THE[Theme/l10n]
  end

  D3 --> RI
  RI --> DS
  DS --> F1 & F2 & F3 & F4 & F5
  D2 --> ST
  ST --> NAV
  NAV --> UI
  UI --> THE
```

---

## 3. `pubspec.yaml` (extracto de dependencias)
```yaml
dependencies:
  flutter: { sdk: flutter }
  # Navegación (go)
  go_router: ^14.2.0

  # Firebase (Datos / Aplicación)
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.0
  firebase_auth: ^5.3.0
  firebase_storage: ^12.2.0
  firebase_messaging: ^15.1.0
  firebase_remote_config: ^5.0.4

  # Estado
  provider: ^6.0.0
  # (Alternativas: riverpod/bloc)

  # Ubicación y mapas
  geolocator: ^12.0.0
  google_maps_flutter: ^2.9.0

  # Notificaciones locales
  flutter_local_notifications: ^17.2.0

  # Utilidades
  intl: ^0.19.0
  url_launcher: ^6.3.0
  uuid: ^4.5.1
```
> **Nota:** Versiones indicativas. Fijar y auditar en CI.

---

## 4. Navegación con `go_router`

### 4.1 Objetivos
- Rutas declarativas con **guards por rol** (admin/operador/repartidor).
- **Deep links** desde FCM y WhatsApp.
- Manejo de **shell routes** para layout compartido (paneles) y **subrutas** (detalle pedido/entrega).

### 4.2 Configuración base
```dart
// application/navigation/app_router.dart
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const root = '/';
  static const inventario = '/inventario';
  static const colaPedidos = '/pedidos/cola';
  static const detallePedido = '/pedidos/detalle/:id';
  static const entregas = '/entregas';
  static const detalleEntrega = '/entregas/:id';
}

GoRouter buildRouter(AuthController auth) {
  return GoRouter(
    initialLocation: AppRoutes.colaPedidos,
    refreshListenable: auth, // notifica cambios de sesión/rol
    redirect: (context, state) {
      final loggedIn = auth.isLoggedIn;
      final role = auth.role; // admin|operador|repartidor
      final goingTo = state.fullPath ?? state.location;

      if (!loggedIn && goingTo != AppRoutes.root) return AppRoutes.root;
      if (loggedIn && role == UserRole.repartidor && goingTo.startsWith('/inventario')) {
        return AppRoutes.entregas; // guard por rol
      }
      return null; // sin cambios
    },
    routes: [
      GoRoute(path: AppRoutes.root, builder: (_, __) => const LoginPage()),
      GoRoute(path: AppRoutes.inventario, builder: (_, __) => const InventarioPage()),
      GoRoute(path: AppRoutes.colaPedidos, builder: (_, __) => const ColaPedidosPage()),
      GoRoute(
        path: AppRoutes.detallePedido,
        builder: (_, state) => DetallePedidoPage(id: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.entregas, builder: (_, __) => const EntregasAsignadasPage()),
      GoRoute(
        path: AppRoutes.detalleEntrega,
        builder: (_, state) => EntregaDetallePage(id: state.pathParameters['id']!),
      ),
    ],
  );
}
```

### 4.3 Deep links (FCM → `go_router`)
```dart
// application/messaging/fcm_handler.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

class FcmHandler {
  final GoRouter router;
  FcmHandler(this.router);

  void init() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final action = message.data['accion'];
      final id = message.data['pedido_id'] ?? message.data['entrega_id'];
      if (action == 'abrir_pedido' && id != null) {
        router.go('/pedidos/detalle/$id');
      } else if (action == 'abrir_entrega' && id != null) {
        router.go('/entregas/$id');
      }
    });
  }
}
```

### 4.4 Deep link a WhatsApp
```dart
// application/integration/whatsapp.dart
import 'package:url_launcher/url_launcher.dart';

Future<void> enviarWhatsApp(String telefono, String mensaje) async {
  final uri = Uri.parse('https://wa.me/$telefono?text=${Uri.encodeComponent(mensaje)}');
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('No se pudo abrir WhatsApp');
  }
}
```

---

## 5. Firebase en Capa Datos

### 5.1 Firestore (Repositorio Pedidos)
```dart
// data/repositories_impl/pedidos_repository_impl.dart
class PedidosRepositoryImpl implements PedidosRepository {
  final FirebaseFirestore _db;
  PedidosRepositoryImpl(this._db);

  @override
  Future<Result<List<Pedido>, Failure>> listar({PedidoFiltro? filtro}) async {
    try {
      var q = _db.collection('pedidos').orderBy('hora_recepcion', descending: true).limit(50);
      final snap = await q.get();
      final items = snap.docs.map((d) => PedidoMapper.toEntity(PedidoDto.fromFirestore(d.data()))).toList();
      return Result.ok(items);
    } catch (e) {
      return Result.err(Failure('Error listando pedidos: $e'));
    }
  }

  @override
  Future<Result<Pedido, Failure>> capturar(Pedido pedido) async {
    // WriteBatch para pedido + consumo de inventario
    // ...
    return Result.ok(pedido);
  }

  @override
  Future<Result<void, Failure>> actualizarEstado(String id, PedidoEstado estado) async {
    try {
      await _db.collection('pedidos').doc(id).update({'estado': estado.name});
      return const Result.ok(null);
    } catch (e) {
      return Result.err(Failure('No se pudo actualizar estado: $e'));
    }
  }
}
```

### 5.2 Remote Config (Umbrales en UI)
```dart
// data/datasources/remote_config_datasource.dart
class RemoteConfigDatasource {
  final FirebaseRemoteConfig rc;
  RemoteConfigDatasource(this.rc);

  Future<ConfigUmbrales> fetch() async {
    await rc.fetchAndActivate();
    return ConfigUmbrales(inventarioBajo: rc.getDouble('inventario_bajo'));
  }
}
```

### 5.3 Messaging (Tokens y tópicos)
```dart
// application/controllers/auth_controller.dart
class AuthController extends ChangeNotifier {
  String? _token;
  bool get isLoggedIn => _token != null;
  UserRole get role => _role;
  // ...
  Future<void> onLogin(User user) async {
    _token = await FirebaseMessaging.instance.getToken();
    await FirebaseMessaging.instance.subscribeToTopic('repartidores');
    notifyListeners();
  }
}
```

---

## 6. Estado (Provider/Riverpod/BLoC)
- **Provider** recomendado por sencillez.
- Controladores en `application/controllers` invocan **use cases** y publican estados (`Loading/Loaded/Error`).
- `go_router` escucha (`refreshListenable`) cambios de sesión/rol para aplicar **guards**.

---

## 7. Notificaciones Locales
- Mostrar banners/toasts cuando la app está en **foreground**.
- Acciones rápidas (marcar **Entregando**/**Entregado**) disparan **use cases** y redirigen con `go_router`.

```dart
// application/notifications/local_notifs.dart
final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// Configuración de canales y handlers...
```

---

## 8. Ubicación y Mapas
- **`geolocator`** para obtener ubicación del repartidor.
- **`google_maps_flutter`** en `MapaDestinoPage` para visualizar destino.
- Encapsular en `LocationDatasource` para mantener el Dominio agnóstico.

---

## 9. DI (Inyección de Dependencias)
- Registrar repos impl y datasources en `di/`.
- Proveer `GoRouter`, `FcmHandler`, `AuthController` y repos a páginas vía `Provider`.

```dart
// di/di.dart
final di = GetIt.instance;
void setupDI() {
  di.registerLazySingleton(() => FirebaseFirestore.instance);
  di.registerLazySingleton<PedidosRepository>(() => PedidosRepositoryImpl(di()));
  di.registerLazySingleton(() => AuthController());
  di.registerLazySingleton(() => buildRouter(di<AuthController>()));
}
```

---

## 10. Buenas Prácticas y Anti-Patrones
- **No** llamar Firestore desde Widgets; usar repositorios.
- **No** exponer DTOs a Presentación; mapear a Entidades.
- **Sí** usar `Result`/`Failure` y manejar errores en controladores.
- **Sí** centralizar navegación en `go_router` y redirecciones en `redirect`.

---

## 11. Pruebas
- **Unit**: mappers, use cases, validadores.
- **Widget**: navegación con `go_router` (mock de `AuthController`).
- **Integración**: flujos con emuladores Firebase.

---

## 12. Checklist de Integración por Módulo
- [ ] Repositorios implementados en **Datos**.
- [ ] Controladores en **Aplicación** conectados a use cases.
- [ ] `go_router` configurado con guards y deep links.
- [ ] Notificaciones (FCM + locales) integradas y testeadas.
- [ ] Ubicación y mapas encapsulados en datasource.
- [ ] DI registrada y verificada al arranque.

---
**Este anexo asegura un uso coherente y mantenible de las dependencias dentro del front-end con Arquitectura Limpia, incluyendo la navegación con `go_router` sin acoplar el Dominio a frameworks.**
