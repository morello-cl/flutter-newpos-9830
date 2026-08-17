🌐 [English](README.md) · **Español**

# flutter_newpos_android_sdk

Plugin **Flutter (Android)** para el terminal de pago **Newpos 9830** y otros
equipos de la familia **asmart / Newpos** cuyo firmware expone el SDK de
plataforma `com.pos.device.*`.

Da acceso desde Dart a los periféricos del terminal —impresora térmica, datos
del equipo, scanner, lector de banda magnética y lector de chip / PSAM— con una
API sencilla y sin depender de binarios propietarios empaquetados.

> ⚠️ Solo funciona sobre hardware Newpos real. En un emulador o en cualquier
> otro dispositivo las llamadas fallan de forma controlada (el SDK lo provee el
> firmware del terminal).

---

## ¿Qué hace?

| Módulo | Qué resuelve | API |
|--------|--------------|-----|
| 🖨️ **Impresora** | Imprime un ticket ya rasterizado a imagen (PNG) y consulta el estado del cabezal | `Newpos.printer` |
| 📇 **Equipo** | N° de serie, modelo, versiones de HW/FW, IMEI y qué módulos trae el equipo | `Newpos.device` |
| 📷 **Scanner** | Lee un código de barras / QR (single-shot, con timeout) | `Newpos.scanner` |
| 💳 **Banda magnética** | Lee los 3 tracks de la banda | `Newpos.magcard` |
| 🔌 **Chip / PSAM** | Selecciona el slot (tarjeta de usuario, PSAM1‑4, NFC) e intercambia APDUs | `Newpos.icc` |

---

## Instalación

Aún no está publicado en pub.dev. Se usa como dependencia de Git o por ruta:

```yaml
dependencies:
  flutter_newpos_android_sdk:
    git:
      url: https://github.com/morello-cl/flutter-newpos-android-sdk.git
      ref: v0.0.2   # fija un tag liberado para builds reproducibles en todos los equipos
```

Cada app consumidora aporta su propio `sdk.jar` (ver más abajo) — el paquete no
lo incluye.

### SDK del fabricante (requerido para compilar)

El SDK de plataforma (`sdk.jar`, propiedad del fabricante) **no se incluye** en
este repositorio. **Debes solicitarlo directamente a Newpos (el fabricante)** en
el marco de tu contrato o licencia del terminal — no se distribuye aquí ni por
ningún canal público. Aporta los paquetes `com.pos.device.*` (periféricos) y
`com.secure.api.*` (seguridad). Colócalo antes de compilar:

```
android/libs/sdk.jar
```

Al consumir el plugin por **git o pub.dev** (el paquete publicado no trae el jar),
cada app coloca su propia copia en `<tu_app>/android/newpos-sdk/sdk.jar`. Ver
[`android/libs/README.md`](android/libs/README.md). Se enlaza como `compileOnly`:
el firmware del terminal provee las clases en tiempo de ejecución vía
`<uses-library android:name="com.pos.device" />`, así que **no se empaqueta ningún
binario propietario en la app**.

> ⚖️ **Licencia y autorización — léelo antes de usar.** El `sdk.jar`
> (`com.pos.device.*`, `com.secure.api.*`) es software propietario del fabricante,
> **no** cubierto por la licencia de este proyecto y **no** redistribuible sin
> autorización expresa del titular. Su obtención y uso están **sujetos a los
> contratos, licencias y autorizaciones vigentes entre el usuario y el
> fabricante**; usarlo **sin esos permisos está prohibido** y puede infringir
> derechos de terceros. Este plugin es solo un envoltorio: sus autores **no** son
> el fabricante del SDK, **no** conceden derecho alguno sobre él y **declinan toda
> responsabilidad** por su obtención, licenciamiento, uso o mal uso. La
> responsabilidad recae **únicamente en el usuario**.

---

## Uso

```dart
import 'package:flutter_newpos_android_sdk/flutter_newpos_android_sdk.dart';

// Datos del equipo
final info = await Newpos.device.info();
print('${info.brand} ${info.model} — serie ${info.serialNumber}');

// ¿Trae scanner?
final tieneScanner = await Newpos.device.hasModule(NewposDevice.moduleScanner);

// Imprimir un ticket (PNG; ancho recomendado 384px para papel de 58mm)
final ok = await Newpos.printer.printImage(pngBytes);
final estado = await Newpos.printer.status(); // PrinterStatus.ok / paperLack / ...

// Escanear un código
final codigo = await Newpos.scanner.scan(timeout: Duration(seconds: 20));

// Leer banda magnética (3 tracks)
final tracks = await Newpos.magcard.readTracks();

// Enviar un APDU a un módulo PSAM
await Newpos.icc.connect(IccSlot.psam1);
final resp = await Newpos.icc.transmit(IccSlot.psam1, apduBytes);
await Newpos.icc.disconnect(IccSlot.psam1);
```

La app de [`example/`](example/) tiene un botón por cada función para probar en
el terminal.

---

## Internacionalización (i18n)

Soporta los idiomas que maneja el consumidor de referencia (DTEx): **español,
inglés, chino tradicional y portugués.**

```dart
// Idioma del sistema del terminal (tags BCP-47; usar las constantes locale*)
await Newpos.device.setLocale(NewposDevice.localeChineseTraditional); // 'zh-TW'
final soportados = await Newpos.device.supportedLocales();            // lo que trae el firmware

// Texto de estado legible en el idioma dado (cae a inglés si no está).
// El enum sigue siendo la fuente de verdad; describe() es una cortesía para
// apps sin su propio l10n.
final estado = await Newpos.printer.status();
print(estado.describe(const Locale('es'))); // "Sin papel", "Sobrecalentada", ...
```

---

## Notas de implementación

- **Impresión.** Usa la API de firmware `com.pos.device.printer.Printer` +
  `PrintTask.setPrintBitmap(...)`. No usa el wrapper propietario `libprinter.jar`:
  se envía un bitmap ya rasterizado, lo que mantiene el repo libre de binarios.
- **Inicialización.** El SDK se inicializa una sola vez y de forma asíncrona; el
  plugin bloquea internamente hasta que está listo. La init es **lazy** (en la
  primera llamada real), de modo que el plugin es inocuo si se incluye en una app
  multi‑flavor que también corre en hardware que no es Newpos.
- **Hilos.** Las operaciones que esperan callbacks del SDK corren fuera del hilo
  de UI.

## ⚠️ Banda magnética y PCI

`Newpos.magcard.readTracks()` devuelve el contenido de los tracks **en claro,
incluido el PAN**. El plugin solo expone la lectura del hardware; es
responsabilidad de la app que lo consume **no persistir ni registrar** esos datos
y cumplir PCI‑DSS.

## Estado

- ✅ Impresión y datos de equipo — implementado.
- 🧪 Scanner (single‑shot, sin preview), banda magnética y PSAM — implementados;
  falta validación en terminal físico.
- ⛔ Pagos EMV (venta con tarjeta) — fuera del alcance de este plugin.

## Compatibilidad

- Newpos 9830 y equipos con firmware que provea `com.pos.device.*`.
- Android (min SDK 24). No hay soporte iOS (el hardware es Android).

## Licencia

El código de este plugin se publica bajo [MIT](LICENSE).

El SDK del fabricante (`sdk.jar`; paquetes `com.pos.device.*` y `com.secure.api.*`)
es software propietario de terceros, **no** cubierto por esta licencia y **no**
distribuido en este repositorio. Su obtención y uso requieren licencia y
autorización del fabricante; ver [`android/libs/README.md`](android/libs/README.md).
Los autores de este envoltorio no otorgan derechos sobre dicho SDK y **declinan
toda responsabilidad** derivada de su obtención, licenciamiento o uso.
