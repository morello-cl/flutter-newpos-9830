/// Ficha del terminal Newpos.
class DeviceInfo {
  final String brand;
  final String? model;
  final String? serialNumber;
  final String? pn;
  final String? hardwareVersion;
  final String? firmwareVersion;
  final String? imei;

  const DeviceInfo({
    required this.brand,
    this.model,
    this.serialNumber,
    this.pn,
    this.hardwareVersion,
    this.firmwareVersion,
    this.imei,
  });

  factory DeviceInfo.fromMap(Map<dynamic, dynamic> m) => DeviceInfo(
        brand: (m['brand'] as String?) ?? 'NEWPOS',
        model: m['model'] as String?,
        serialNumber: m['serialNumber'] as String?,
        pn: m['pn'] as String?,
        hardwareVersion: m['hardwareVersion'] as String?,
        firmwareVersion: m['firmwareVersion'] as String?,
        imei: m['imei'] as String?,
      );

  @override
  String toString() => 'DeviceInfo($brand $model, sn=$serialNumber)';
}

/// Estado del printer, mapeado desde los códigos `Printer.PRINTER_*` del SDK.
enum PrinterStatus {
  ok,
  busy,
  highTemp,
  paperLack,
  noBattery,
  feed,
  printing,
  forceFeed,
  powerOn,
  tasksFull,
  unknown;

  /// Mapea el int crudo del SDK (ver `Printer.PRINTER_*`).
  static PrinterStatus fromCode(int code) {
    switch (code) {
      case 0:
        return PrinterStatus.ok; // PRINTER_OK
      case 1:
        return PrinterStatus.busy; // PRINTER_STATUS_BUSY
      case 2:
        return PrinterStatus.highTemp; // PRINTER_STATUS_HIGHT_TEMP
      case 3:
        return PrinterStatus.paperLack; // PRINTER_STATUS_PAPER_LACK
      case 4:
        return PrinterStatus.noBattery; // PRINTER_STATUS_NO_BATTERY
      case 5:
        return PrinterStatus.feed; // PRINTER_STATUS_FEED
      case 6:
        return PrinterStatus.printing; // PRINTER_STATUS_PRINT
      case 7:
        return PrinterStatus.forceFeed; // PRINTER_STATUS_FORCE_FEED
      case 8:
        return PrinterStatus.powerOn; // PRINTER_STATUS_POWER_ON
      case 9:
        return PrinterStatus.tasksFull; // PRINTER_TASKS_FULL
      default:
        return PrinterStatus.unknown;
    }
  }
}

/// Datos crudos de la banda magnética.
///
/// ⚠️ Sensible (PCI): contiene el PAN en claro. No persistir ni loguear.
class TrackData {
  final String? track1;
  final String? track2;
  final String? track3;
  final int state1;
  final int state2;
  final int state3;

  const TrackData({
    this.track1,
    this.track2,
    this.track3,
    this.state1 = -1,
    this.state2 = -1,
    this.state3 = -1,
  });

  factory TrackData.fromMap(Map<dynamic, dynamic> m) => TrackData(
        track1: m['track1'] as String?,
        track2: m['track2'] as String?,
        track3: m['track3'] as String?,
        state1: (m['state1'] as int?) ?? -1,
        state2: (m['state2'] as int?) ?? -1,
        state3: (m['state3'] as int?) ?? -1,
      );
}

/// Slots de tarjeta/chip del terminal (parámetro de [NewposIcc]).
enum IccSlot { userCard, psam1, psam2, psam3, psam4, nfc }

extension IccSlotName on IccSlot {
  /// Nombre tal como lo espera `com.pos.device.icc.SlotType`.
  String get sdkName {
    switch (this) {
      case IccSlot.userCard:
        return 'USER_CARD';
      case IccSlot.psam1:
        return 'PSAM1';
      case IccSlot.psam2:
        return 'PSAM2';
      case IccSlot.psam3:
        return 'PSAM3';
      case IccSlot.psam4:
        return 'PSAM4';
      case IccSlot.nfc:
        return 'NFC';
    }
  }
}
