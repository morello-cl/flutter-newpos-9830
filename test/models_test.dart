import 'package:flutter_test/flutter_test.dart';
import 'package:newpos_9830/newpos_9830.dart';

void main() {
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
