🌐 **English** · [Español](README.es.md)

# newpos_9830

A **Flutter (Android)** plugin for the **Newpos 9830** payment terminal and other
**asmart / Newpos** family devices whose firmware exposes the `com.pos.device.*`
platform SDK.

It gives Dart access to the terminal peripherals —thermal printer, device info,
scanner, magnetic-stripe reader and chip / PSAM reader— through a simple API,
without bundling any proprietary binaries.

> ⚠️ Works only on real Newpos hardware. On an emulator or any other device the
> calls fail gracefully (the SDK is provided by the terminal firmware).

---

## What it does

| Module | What it solves | API |
|--------|----------------|-----|
| 🖨️ **Printer** | Prints an already-rasterized receipt image (PNG) and reads the print head status | `Newpos.printer` |
| 📇 **Device** | Serial number, model, HW/FW versions, IMEI and which modules the unit ships | `Newpos.device` |
| 📷 **Scanner** | Reads a barcode / QR (single-shot, with timeout) | `Newpos.scanner` |
| 💳 **Magnetic stripe** | Reads the 3 stripe tracks | `Newpos.magcard` |
| 🔌 **Chip / PSAM** | Selects the slot (user card, PSAM1‑4, NFC) and exchanges APDUs | `Newpos.icc` |

---

## Installation

Not published on pub.dev yet. Use it as a Git or path dependency:

```yaml
dependencies:
  newpos_9830:
    git:
      url: https://github.com/morello-cl/flutter-newpos-9830.git
      ref: v0.0.2   # pin a released tag for reproducible builds across machines
```

Each consuming app supplies its own `sdk.jar` (see below) — the package does not
ship it.

### Vendor SDK (required to build)

The platform SDK (`sdk.jar`, owned by the manufacturer) is **not included** in
this repository. It provides the `com.pos.device.*` (peripherals) and
`com.secure.api.*` (security) packages. Place it before building:

```
android/libs/sdk.jar
```

When consuming the plugin via **git or pub.dev** (the published package does not
carry the jar), each app places its own copy at `<app>/android/newpos-sdk/sdk.jar`
instead. See [`android/libs/README.md`](android/libs/README.md). It is linked as
`compileOnly`: the terminal firmware provides the classes at runtime via
`<uses-library android:name="com.pos.device" />`, so **no proprietary binary is
bundled into the app**.

> ⚖️ **License and authorization — read before use.** `sdk.jar` (`com.pos.device.*`,
> `com.secure.api.*`) is the manufacturer's proprietary software, **not** covered
> by this project's license and **not** redistributable without the owner's
> express authorization. Its acquisition and use are **governed by the contracts,
> licenses and authorizations between the user and the manufacturer**; using it
> **without those permissions is prohibited** and may infringe third-party rights.
> This plugin is only a wrapper: its authors are **not** the SDK vendor, grant **no**
> rights over it, and **disclaim all liability** for its acquisition, licensing,
> use or misuse. Responsibility lies **solely with the user**.

---

## Usage

```dart
import 'package:newpos_9830/newpos_9830.dart';

// Device info
final info = await Newpos.device.info();
print('${info.brand} ${info.model} — s/n ${info.serialNumber}');

// Has a scanner?
final hasScanner = await Newpos.device.hasModule(NewposDevice.moduleScanner);

// Print a receipt (PNG; recommended width 384px for 58mm paper)
final ok = await Newpos.printer.printImage(pngBytes);
final status = await Newpos.printer.status(); // PrinterStatus.ok / paperLack / ...

// Scan a code
final code = await Newpos.scanner.scan(timeout: Duration(seconds: 20));

// Read the magnetic stripe (3 tracks)
final tracks = await Newpos.magcard.readTracks();

// Send an APDU to a PSAM module
await Newpos.icc.connect(IccSlot.psam1);
final resp = await Newpos.icc.transmit(IccSlot.psam1, apduBytes);
await Newpos.icc.disconnect(IccSlot.psam1);
```

The [`example/`](example/) app has one button per function to try on the terminal.

---

## Internationalization (i18n)

Supports the languages the reference consumer (DTEx) handles: **Spanish, English,
Traditional Chinese and Portuguese.**

```dart
// Terminal system language (BCP-47 tags; use the locale* constants)
await Newpos.device.setLocale(NewposDevice.localeChineseTraditional); // 'zh-TW'
final supported = await Newpos.device.supportedLocales();             // what the firmware ships

// Human-readable status text in the given language (falls back to English).
// The enum stays the source of truth; describe() is a convenience for apps
// without their own l10n.
final status = await Newpos.printer.status();
print(status.describe(const Locale('en'))); // "Out of paper", "Overheated", ...
```

---

## Implementation notes

- **Printing.** Uses the `com.pos.device.printer.Printer` firmware API +
  `PrintTask.setPrintBitmap(...)`. It does not use the proprietary `libprinter.jar`
  wrapper: an already-rasterized bitmap is sent, keeping the repo binary-free.
- **Initialization.** The SDK is initialized once, asynchronously; the plugin
  blocks internally until it is ready. Init is **lazy** (on the first real call),
  so the plugin is harmless when included in a multi‑flavor app that also runs on
  non-Newpos hardware.
- **Threads.** Operations that wait on SDK callbacks run off the UI thread.

## ⚠️ Magnetic stripe and PCI

`Newpos.magcard.readTracks()` returns the track contents **in the clear,
including the PAN**. The plugin only exposes the hardware read; it is the
consuming app's responsibility to **not persist or log** that data and to comply
with PCI‑DSS.

## Status

- ✅ Printing and device info — implemented.
- 🧪 Scanner (single‑shot, no preview), magnetic stripe and PSAM — implemented;
  pending validation on a physical terminal.
- ⛔ EMV payments (card sale) — out of scope for this plugin.

## Compatibility

- Newpos 9830 and units whose firmware provides `com.pos.device.*`.
- Android (min SDK 24). No iOS support (the hardware is Android).

## License

This plugin's code is released under [MIT](LICENSE).

The vendor SDK (`sdk.jar`; `com.pos.device.*` and `com.secure.api.*` packages) is
third-party proprietary software, **not** covered by this license and **not**
distributed in this repository. Obtaining and using it requires a license and
authorization from the manufacturer; see [`android/libs/README.md`](android/libs/README.md).
The authors of this wrapper grant no rights over that SDK and **disclaim all
liability** arising from its acquisition, licensing or use.
