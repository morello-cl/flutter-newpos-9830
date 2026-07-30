# CLAUDE.md — newpos_9830

Guía para Claude Code / Codex al trabajar en este repositorio.

## Qué es

Plugin **Flutter (Android)** que envuelve el SDK de plataforma del terminal POS
**Newpos 9830** (`com.pos.device.*`, familia asmart/Newpos) y lo expone en Dart.
Nace extraído de la app **DTEx** (facturación electrónica chilena), que lo consume
por `path: ../newpos_9830`. Público, MIT: https://github.com/morello-cl/flutter-newpos-9830

## Idioma

El autor (Marco) es chileno. Responder y escribir copy/commits en **español chileno
neutro** — nunca argentinismos ("vos/decime/querés" → "tú/dime/quieres").

## Reglas clave (no romper)

- **`sdk.jar` es propietario de Newpos y NO se versiona** (gitignored en
  `android/libs/`). Lo provee el firmware del terminal en runtime vía
  `<uses-library com.pos.device>`; se enlaza `compileOnly`. Nunca commitear binarios
  del SDK ni empaquetarlos en la app. Para compilar hay que colocar `android/libs/sdk.jar`.
- **Impresión SIN `libprinter.jar`.** Se usa la API de firmware
  `com.pos.device.printer.Printer` + `PrintTask.setPrintBitmap(...)` (bitmap ya
  rasterizado). No reintroducir el wrapper propietario `libprinter.jar`.
- **Init lazy.** El SDK se inicializa una vez, async, vía `NewposSdk.ensureReady()`
  (NO en `onAttachedToEngine`), para que el plugin sea inocuo en apps multi-flavor
  que también corren en hardware no-Newpos. No mover la init al attach.
- **Hilos.** Todo lo que espera callbacks del SDK corre fuera del UI thread.
- **Banda magnética = PCI.** `magcard.readTracks()` devuelve el PAN en claro. No
  loguear ni persistir; solo exponer la lectura.

## Estructura

- `lib/newpos_9830.dart` — fachada `Newpos.{printer,device,scanner,magcard,icc}` + exports.
- `lib/src/` — API por dominio + `models.dart` (DeviceInfo, PrinterStatus, TrackData, IccSlot).
- `android/src/main/kotlin/cl/mufin/newpos_9830/`:
  - `Newpos9830Plugin.kt` — canal `cl.mufin.newpos_9830/methods`, dispatch en hilo IO.
  - `NewposSdk.kt` — gate de init async.
  - `Newpos{Printer,Device,Scanner,Magcard,Icc}.kt` — clases planas reutilizables
    (las llama tanto el plugin como el puente del flavor de DTEx).
- `example/` — app demo con un botón por función.
- `test/models_test.dart` — self-check de los modelos (sin device).

## Comandos

Usa **FVM** (no hay Flutter global en PATH):

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
cd example && fvm flutter build apk --debug   # valida el Kotlin contra sdk.jar
```

## Estado

- ✅ Impresión y datos de equipo — implementado y verificado por compilación.
- 🧪 Scanner (single-shot, sin preview), banda y PSAM — implementados; falta validar
  en terminal físico.
- Al agregar features, mantener la API por dominio bajo `Newpos.*` y las clases
  Kotlin planas reutilizables.

## Cambios que impactan a DTEx

DTEx consume por `path`, así que editar aquí afecta sus builds directo. Si cambias
la firma de una clase Kotlin usada por el puente, revisar
`dtex/android/app/src/newpos9830/` (Printer.java / Device.java).
