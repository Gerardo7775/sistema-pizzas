# Guía de Uso de Emuladores Firebase

Esta guía explica cómo iniciar y utilizar los emuladores locales de Firebase para el desarrollo seguro de las aplicaciones del ecosistema (Admin Desktop, Comandera, Repartidor), evitando afectar los datos de producción.

## 1. Prerrequisitos

Asegúrate de tener instaladas las siguientes herramientas:

- **Node.js** (v18 o superior)
- **Firebase CLI**: `npm install -g firebase-tools`
- **Java JDK** (v17 o superior) - necesario para los emuladores.

## 2. Iniciar los Emuladores

Los emuladores simulan la nube de Firebase (Firestore, Functions, Auth) en tu computadora local.

1. Abre una terminal (PowerShell o CMD).
2. Navega a la carpeta `functions` de tu proyecto:

    ```bash
    cd C:\Users\HP\Documents\sistema-pizzas\functions
    ```

3. Ejecuta el comando de inicio:

    ```bash
    firebase emulators:start
    ```

    *Opcional: Para importar datos de prueba guardados previamente, usa:*

    ```bash
    firebase emulators:start --import=./emulator-data --export-on-exit
    ```

### ¿Qué verás?

La terminal mostrará las URLs de los servicios emulados:

- **Firestore**: `http://127.0.0.1:8080`
- **Functions**: `http://127.0.0.1:5001`
- **Auth**: `http://127.0.0.1:9099`
- **Emulator UI (Interfaz Gráfica)**: `http://127.0.0.1:4000`

> [!IMPORTANT]
> Mantén esta terminal **abierta**. Si la cierras, los emuladores se detendrán y las apps fallarán en modo Debug.

## 3. Usar la Interfaz Gráfica (Emulator UI)

Abre `http://localhost:4000` en tu navegador para ver y gestionar los datos locales.

- **Firestore**: Puedes crear colecciones (`insumos`, `pedidos`) y documentos manualmente para probar.
- **Logs**: Verás los "logs" de las Cloud Functions cuando sean invocadas por las apps.

## 4. Ejecutar las Aplicaciones

Las aplicaciones han sido configuradas para conectarse automáticamente a los emuladores cuando se ejecutan en **Modo Debug**.

### Admin Desktop (Windows)

```bash
cd admin_desktop
flutter run -d windows
```

*La app detectará `kDebugMode` y usará `http://127.0.0.1:5001` para las Functions.*

### Comandera / Repartidor (Android Emulator)

```bash
cd comandera_app
flutter run
```

*Si usas el emulador de Android oficial, la app se conectará automáticamente a `10.0.2.2` (alias de localhost en Android).*

## 5. Solución de Problemas Comunes

### "Connection refused"

- Verifica que los emuladores estén corriendo en la terminal.
- Si estás en dispositivo físico (teléfono real via USB), necesitas usar la IP local de tu PC (ej. `192.168.1.50`) en lugar de `localhost`. *Esto requiere configuración adicional en `main.dart`*.

### "Function not found"

- Asegúrate de estar corriendo las funciones en la región correcta. La configuración está en `remote_datasource.dart` (actualmente `us-central1`).
