package cl.mufin.newpos_9830

import android.content.Context
import android.util.Log
import com.pos.device.icc.ContactCard
import com.pos.device.icc.IccReader
import com.pos.device.icc.OperatorMode
import com.pos.device.icc.SlotType
import com.pos.device.icc.VCC

/**
 * Lector de tarjetas de contacto / PSAM (SAM) del Newpos 9830.
 *
 * "Cambiar el chip con el que se trabaja" = elegir el slot:
 *   USER_CARD (tarjeta del cliente), PSAM1..PSAM4 (módulos SAM), NFC.
 *
 * Flujo: connect(slot) → transmit(slot, apdu)* → disconnect(slot).
 * Mantiene una tarjeta conectada por slot. Llamar desde un hilo secundario.
 */
class NewposIcc(private val context: Context) {
    companion object {
        private const val TAG = "NewposIcc"
    }

    private val connected = HashMap<SlotType, ContactCard>()

    fun connect(slot: SlotType, mode: OperatorMode = OperatorMode.ISO_MODE, vcc: VCC = VCC.VOLT_5): Boolean {
        if (!NewposSdk.ensureReady(context)) return false
        return try {
            val reader = IccReader.getInstance(slot)
            val card = reader.connectCard(vcc, mode)
            if (card != null) { connected[slot] = card; true } else false
        } catch (e: Exception) {
            Log.e(TAG, "connect($slot) falló", e)
            false
        }
    }

    /** Envía un APDU al slot conectado. Devuelve la respuesta cruda o null. */
    fun transmit(slot: SlotType, apdu: ByteArray): ByteArray? {
        val card = connected[slot] ?: run {
            Log.e(TAG, "transmit sin connect previo en $slot")
            return null
        }
        return try {
            IccReader.getInstance(slot).transmit(card, apdu)
        } catch (e: Exception) {
            Log.e(TAG, "transmit($slot) falló", e)
            null
        }
    }

    fun disconnect(slot: SlotType) {
        runCatching { IccReader.getInstance(slot).disconnectCard() }
        connected.remove(slot)
    }
}
