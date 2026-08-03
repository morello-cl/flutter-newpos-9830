# Changelog

Todos los cambios relevantes de este proyecto se registran aquí.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y el versionado sigue [SemVer](https://semver.org/lang/es/).

> **Dependencia propietaria.** Compilar este plugin requiere el `sdk.jar` del
> fabricante (paquetes `com.pos.device.*` y `com.secure.api.*`), que **no** se
> distribuye en este repositorio y exige licencia y autorización propias. Ver
> [«SDK del fabricante»](README.md#sdk-del-fabricante-requerido-para-compilar)
> y [`android/libs/README.md`](android/libs/README.md).

## [No liberado]

### Agregado

- **i18n — textos de estado legibles.** `PrinterStatus.describe(Locale)` entrega
  el estado en español, inglés, chino tradicional y portugués (cae a inglés si
  el idioma no está). El `enum` sigue siendo la fuente de verdad; es una
  cortesía para apps sin l10n propio.
- **i18n — idioma del terminal.** `Newpos.device.setLocale(tag)` cambia el idioma
  del sistema del terminal y `Newpos.device.supportedLocales()` lista los que el
  firmware declara. Constantes `NewposDevice.locale*` para los 4 idiomas de DTEx.
- **example — selector de idioma.** El demo agrega botones de idioma que llaman
  `setLocale` y muestra el estado del printer traducido con `describe(locale)`.
- **docs — README bilingüe.** `README.md` en inglés (primario, convención de
  pub.dev) + `README.es.md` en español, con selector de idioma cruzado. Ambos
  documentan la API i18n.

## [0.0.2]

### Corregido

- **Impresora — códigos de estado invertidos.** `PrinterStatus.fromCode`
  mapeaba valores positivos, pero los `Printer.PRINTER_STATUS_*` del SDK son
  **negativos** (`-1..-9`); toda condición de falla (papel agotado,
  sobrecalentamiento, sin batería) caía en `unknown`.
- **Inicialización del SDK sin recuperación.** Un fallo o timeout de
  `SDKManager.init` dejaba el gate trabado y el plugin inutilizable para el
  resto del proceso; ahora se permite reintento.
- **Despacho en un solo hilo.** Una operación larga (`scanner.scan` /
  `magcard.readTracks`, hasta 30 s) bloqueaba la cola y `scanner.stop()` /
  `disconnect` nunca podían interrumpirla. Se pasa a un pool de hilos.
- **Impresora — doble impresión / bitmap liberado en uso.** Ante un timeout la
  impresión seguía en curso; el reintento podía imprimir dos veces y liberar el
  bitmap mientras el SDK aún lo leía. Ahora se cancela la tarea colgada antes de
  reintentar.

## [0.0.1]

### Agregado

- Release inicial. Wrapper del SDK Newpos `com.pos.device.*` (Android):
  - Impresión térmica por bitmap (`Newpos.printer`).
  - Datos del equipo y detección de módulos (`Newpos.device`).
  - Scanner single-shot (`Newpos.scanner`).
  - Lectura de banda magnética, 3 tracks (`Newpos.magcard`).
  - Tarjeta de contacto / PSAM con selección de slot (`Newpos.icc`).

[No liberado]: https://github.com/morello-cl/flutter-newpos-9830/compare/v0.0.2...HEAD
[0.0.2]: https://github.com/morello-cl/flutter-newpos-9830/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/morello-cl/flutter-newpos-9830/releases/tag/v0.0.1
