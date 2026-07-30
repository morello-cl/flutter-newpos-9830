import 'dart:typed_data';

import 'channel.dart';
import 'models.dart';

/// Lector de tarjetas de contacto / PSAM (SAM) del Newpos 9830.
///
/// "Cambiar el chip" = elegir el [IccSlot]: tarjeta de usuario, PSAM1..4 o NFC.
/// Flujo: [connect] → [transmit]* → [disconnect].
class NewposIcc {
  const NewposIcc();

  /// Conecta la tarjeta del [slot]. [mode] mapea `OperatorMode` (ISO_MODE/EMV_MODE…).
  Future<bool> connect(IccSlot slot, {String mode = 'ISO_MODE'}) async {
    return await newposChannel.invokeMethod<bool>('icc.connect', {
          'slot': slot.sdkName,
          'mode': mode,
        }) ??
        false;
  }

  /// Envía un APDU al slot conectado. Devuelve la respuesta cruda o null.
  Future<Uint8List?> transmit(IccSlot slot, Uint8List apdu) {
    return newposChannel.invokeMethod<Uint8List>('icc.transmit', {
      'slot': slot.sdkName,
      'apdu': apdu,
    });
  }

  Future<void> disconnect(IccSlot slot) {
    return newposChannel.invokeMethod<void>('icc.disconnect', {'slot': slot.sdkName});
  }
}
