import 'channel.dart';
import 'models.dart';

/// Lectura de banda magnética (3 tracks) del Newpos 9830.
///
/// ⚠️ Sensible (PCI): el resultado contiene el PAN en claro. No persistir ni
/// loguear [TrackData]; úsalo solo en memoria el tiempo mínimo necesario.
class NewposMagcard {
  const NewposMagcard();

  /// Espera el swipe de una tarjeta con timeout y devuelve los 3 tracks.
  /// Devuelve null si hubo timeout o cancelación.
  Future<TrackData?> readTracks({Duration timeout = const Duration(seconds: 30)}) async {
    final m = await newposChannel.invokeMethod<Map<dynamic, dynamic>>('magcard.readTracks', {
      'timeoutSeconds': timeout.inSeconds,
    });
    return m == null ? null : TrackData.fromMap(m);
  }
}
