import 'dart:ui' show Locale;

import 'models.dart';

/// Descripciones legibles de [PrinterStatus] en los idiomas que maneja el
/// consumidor de referencia (DTEx): español, inglés, chino tradicional y
/// portugués.
///
/// Es una **cortesía** para apps sin su propio sistema de localización. El
/// `enum` sigue siendo la fuente de verdad: una app con l10n propio (como DTEx)
/// debe mapear el `enum` a sus claves, no depender de estos textos.
extension PrinterStatusL10n on PrinterStatus {
  /// Texto legible del estado en [locale]. Cae a inglés si el idioma no está.
  ///
  /// El chino se resuelve como tradicional (el único variante provisto): se
  /// distingue por `scriptCode == 'Hant'` o país TW/HK/MO, pero cualquier `zh`
  /// entrega el tradicional antes que caer a inglés.
  String describe(Locale locale) {
    final row = _text[this] ?? _text[PrinterStatus.unknown]!;
    return row[_langKey(locale)] ?? row['en']!;
  }
}

String _langKey(Locale locale) {
  final lang = locale.languageCode.toLowerCase();
  if (lang == 'zh') return 'zhHant';
  if (lang == 'es' || lang == 'pt' || lang == 'en') return lang;
  return 'en';
}

/// Tabla estado → {idioma: texto}. Toda fila trae es/en/zhHant/pt (ver test).
const Map<PrinterStatus, Map<String, String>> _text = {
  PrinterStatus.ok: {'es': 'Lista', 'en': 'Ready', 'zhHant': '就緒', 'pt': 'Pronta'},
  PrinterStatus.busy: {'es': 'Ocupada', 'en': 'Busy', 'zhHant': '忙碌', 'pt': 'Ocupada'},
  PrinterStatus.highTemp: {'es': 'Sobrecalentada', 'en': 'Overheated', 'zhHant': '過熱', 'pt': 'Superaquecida'},
  PrinterStatus.paperLack: {'es': 'Sin papel', 'en': 'Out of paper', 'zhHant': '缺紙', 'pt': 'Sem papel'},
  PrinterStatus.noBattery: {'es': 'Sin batería', 'en': 'No battery', 'zhHant': '無電池', 'pt': 'Sem bateria'},
  PrinterStatus.feed: {'es': 'Avanzando papel', 'en': 'Feeding paper', 'zhHant': '進紙中', 'pt': 'Avançando papel'},
  PrinterStatus.printing: {'es': 'Imprimiendo', 'en': 'Printing', 'zhHant': '列印中', 'pt': 'Imprimindo'},
  PrinterStatus.forceFeed: {'es': 'Avance forzado', 'en': 'Force feed', 'zhHant': '強制進紙', 'pt': 'Avanço forçado'},
  PrinterStatus.powerOn: {'es': 'Encendida', 'en': 'Powering on', 'zhHant': '開機中', 'pt': 'Ligando'},
  PrinterStatus.tasksFull: {'es': 'Cola de tareas llena', 'en': 'Task queue full', 'zhHant': '工作佇列已滿', 'pt': 'Fila de tarefas cheia'},
  PrinterStatus.unknown: {'es': 'Desconocido', 'en': 'Unknown', 'zhHant': '未知', 'pt': 'Desconhecido'},
};
