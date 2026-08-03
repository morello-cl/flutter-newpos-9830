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

  /// Tags de idioma (BCP-47) de los idiomas que maneja DTEx, para [setLocale].
  /// Verifica contra [supportedLocales] lo que el firmware realmente trae.
  static const String localeSpanish = 'es-ES';
  static const String localeEnglish = 'en-US';
  static const String localeChineseTraditional = 'zh-TW';
  static const String localePortuguese = 'pt-BR';

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

  /// Idiomas que el firmware del terminal declara soportar (tags BCP-47).
  Future<List<String>> supportedLocales() async {
    final list = await newposChannel.invokeMethod<List<dynamic>>('device.supportedLocales');
    return (list ?? const []).cast<String>();
  }

  /// Cambia el idioma del sistema del terminal. [tag] BCP-47 (usar las
  /// constantes `locale*`). Devuelve true si el terminal lo aplicó (false si no
  /// soporta el tag).
  Future<bool> setLocale(String tag) async {
    return await newposChannel.invokeMethod<bool>('device.setLocale', {'tag': tag}) ?? false;
  }
}
