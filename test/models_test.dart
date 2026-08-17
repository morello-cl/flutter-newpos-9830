import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_newpos_android_sdk/flutter_newpos_android_sdk.dart';

void main() {
  test('PrinterStatus.describe cubre los 4 idiomas para todo estado', () {
    for (final status in PrinterStatus.values) {
      for (final lang in ['es', 'en', 'pt']) {
        expect(status.describe(Locale(lang)), isNotEmpty,
            reason: '$status sin texto en $lang');
      }
      expect(status.describe(const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')),
          isNotEmpty,
          reason: '$status sin texto en zh-Hant');
    }
  });

  test('PrinterStatus.describe traduce y cae a inglés', () {
    expect(PrinterStatus.paperLack.describe(const Locale('es')), 'Sin papel');
    expect(PrinterStatus.paperLack.describe(const Locale('en')), 'Out of paper');
    expect(PrinterStatus.paperLack.describe(const Locale('pt')), 'Sem papel');
    expect(PrinterStatus.paperLack.describe(const Locale('zh')), '缺紙');
    // Idioma no provisto (francés) → inglés.
    expect(PrinterStatus.paperLack.describe(const Locale('fr')), 'Out of paper');
  });

  test('PrinterStatus.fromCode mapea los códigos del SDK', () {
    // Los códigos de falla del SDK son negativos.
    expect(PrinterStatus.fromCode(0), PrinterStatus.ok);
    expect(PrinterStatus.fromCode(-3), PrinterStatus.paperLack);
    expect(PrinterStatus.fromCode(-2), PrinterStatus.highTemp);
    expect(PrinterStatus.fromCode(-9), PrinterStatus.tasksFull);
    expect(PrinterStatus.fromCode(99), PrinterStatus.unknown);
  });

  test('DeviceInfo.fromMap con brand por defecto', () {
    final d = DeviceInfo.fromMap({'serialNumber': 'SN123', 'model': '9830'});
    expect(d.brand, 'NEWPOS');
    expect(d.serialNumber, 'SN123');
    expect(d.model, '9830');
    expect(d.imei, isNull);
  });

  test('TrackData.fromMap conserva tracks y estados', () {
    final t = TrackData.fromMap({'track2': '123=456', 'state2': 0});
    expect(t.track1, isNull);
    expect(t.track2, '123=456');
    expect(t.state2, 0);
    expect(t.state1, -1);
  });

  test('IccSlot expone el nombre esperado por SlotType', () {
    expect(IccSlot.psam1.sdkName, 'PSAM1');
    expect(IccSlot.userCard.sdkName, 'USER_CARD');
    expect(IccSlot.nfc.sdkName, 'NFC');
  });
}
