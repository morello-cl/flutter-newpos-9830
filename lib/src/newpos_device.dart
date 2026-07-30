import 'channel.dart';
import 'models.dart';

/// Datos del terminal y detección de capacidades de hardware.
class NewposDevice {
  const NewposDevice();

  /// Constantes de módulo de `com.pos.device.config.DevConfig` (para [hasModule]).
  static const String modulePrinter = 'PRINTER';
  static const String moduleScanner = 'BAR_SCANNER';
  static const String moduleMagcard = 'MAGCARD_READER';
  static const String moduleIcc = 'ICC_READER';
  static const String modulePicc = 'PICC_READER';
  static const String moduleSam = 'SAM_SLOT';

  /// Ficha del equipo (serie, modelo, versiones, IMEI).
  Future<DeviceInfo> info() async {
    final m = await newposChannel.invokeMethod<Map<dynamic, dynamic>>('device.info');
    return DeviceInfo.fromMap(m ?? const {});
  }

  /// N° de serie del terminal (atajo de [info]).
  Future<String?> serialNumber() async => (await info()).serialNumber;

  /// Nombres de los módulos de hardware presentes.
  Future<List<String>> modules() async {
    final list = await newposChannel.invokeMethod<List<dynamic>>('device.modules');
    return (list ?? const []).cast<String>();
  }

  /// true si el terminal declara el módulo (usar las constantes `module*`).
  Future<bool> hasModule(String name) async {
    return await newposChannel.invokeMethod<bool>('device.hasModule', {'name': name}) ?? false;
  }
}
