import 'channel.dart';

/// Lectura de códigos de barra / QR (scanner) del Newpos 9830.
class NewposScanner {
  const NewposScanner();

  /// Escanea un código (single-shot) con timeout. Devuelve el texto o null.
  Future<String?> scan({Duration timeout = const Duration(seconds: 30)}) {
    return newposChannel.invokeMethod<String>('scanner.scan', {
      'timeoutSeconds': timeout.inSeconds,
    });
  }

  /// Detiene un escaneo en curso.
  Future<void> stop() => newposChannel.invokeMethod<void>('scanner.stop');
}
