# newpos_9830

Plugin Flutter (Android) para el terminal POS **Newpos 9830** y compatibles con
el SDK de plataforma `com.pos.device.*` (familia asmart/Newpos).

Expone en Dart las capacidades del terminal:

| Área | API |
|------|-----|
| Impresión térmica | `Newpos.printer.printImage(png)`, `.status()` |
| Datos del equipo | `Newpos.device.info()`, `.serialNumber()`, `.modules()`, `.hasModule(...)` |
| Scanner | `Newpos.scanner.scan()`, `.stop()` |
| Banda magnética (3 tracks) | `Newpos.magcard.readTracks()` |
| Tarjeta contacto / PSAM | `Newpos.icc.connect(slot)`, `.transmit(slot, apdu)`, `.disconnect(slot)` |

## Requisitos

- Solo funciona en un **terminal Newpos** cuyo firmware provea `com.pos.device`
  (se declara `<uses-library com.pos.device>` y se enlaza el SDK como `compileOnly`).
- El `sdk.jar` del fabricante **no se incluye** en el repo. Colócalo en
  `android/libs/sdk.jar` para compilar (ver `android/libs/README.md`).

## Uso

```dart
import 'package:newpos_9830/newpos_9830.dart';

final info = await Newpos.device.info();       // serie, modelo, versiones
await Newpos.printer.printImage(pngBytes);      // imprime un PNG (58mm = 384px)
final code = await Newpos.scanner.scan();       // lee un código
```

Corre `example/` para probar cada función en el device.

## Impresión

La impresión usa la API de firmware `com.pos.device.printer.Printer` +
`PrintTask.setPrintBitmap(...)` — **no** se empaqueta el wrapper propietario
`libprinter.jar`. Se envía un bitmap ya rasterizado (ancho recomendado 384px
para 58mm). El SDK se inicializa una sola vez de forma asíncrona; el plugin
bloquea internamente hasta que está listo.

## ⚠️ Banda magnética (PCI)

`readTracks()` devuelve el contenido de los tracks **en claro, incluido el PAN**.
Es responsabilidad de quien lo consume no persistirlo ni registrarlo, y cumplir
PCI-DSS. El plugin solo expone la lectura del hardware.

## Estado

- ✅ Impresión y datos de equipo: implementado.
- 🧪 Scanner (single-shot, headless), banda y PSAM: implementados; validar en device.
- Scanner con preview de cámara: no incluido (ver nota en `NewposScanner`).

## Licencia

MIT — ver [LICENSE](LICENSE). El SDK `com.pos.device.*` es propiedad de Newpos y
no está cubierto por esta licencia.
