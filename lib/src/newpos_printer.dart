import 'dart:typed_data';

import 'channel.dart';
import 'models.dart';

/// Impresión térmica del Newpos 9830.
class NewposPrinter {
  const NewposPrinter();

  /// Imprime un PNG completo. [gray] 50–200 controla la intensidad.
  /// Devuelve true si imprimió correctamente.
  Future<bool> printImage(Uint8List png, {int gray = 120}) async {
    final ok = await newposChannel.invokeMethod<bool>('printer.printImage', {
      'png': png,
      'gray': gray,
    });
    return ok ?? false;
  }

  /// Estado actual del printer.
  Future<PrinterStatus> status() async {
    final code = await newposChannel.invokeMethod<int>('printer.status') ?? -1;
    return PrinterStatus.fromCode(code);
  }
}
