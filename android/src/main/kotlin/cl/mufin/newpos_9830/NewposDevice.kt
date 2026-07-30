package cl.mufin.newpos_9830

import android.content.Context
import android.util.Log
import com.pos.device.config.DevConfig
import com.pos.device.sys.SystemManager

/**
 * Datos del terminal Newpos y detección de capacidades de hardware.
 * Reutilizable por el plugin y por el flavor de una app host.
 */
class NewposDevice(private val context: Context) {
    companion object {
        private const val TAG = "NewposDevice"
        const val BRAND = "NEWPOS"
    }

    /** Mapa con la ficha del equipo. Valores null si el SDK no responde. */
    fun info(): Map<String, Any?> {
        if (!NewposSdk.ensureReady(context)) return mapOf("brand" to BRAND)
        return try {
            mapOf(
                "brand" to BRAND,
                "model" to DevConfig.getMachine(),
                "serialNumber" to DevConfig.getSN(),
                "pn" to DevConfig.getPN(),
                "hardwareVersion" to DevConfig.getHardwareVersion(),
                "firmwareVersion" to DevConfig.getFirmwareVersion(),
                "imei" to runCatching { SystemManager.getImei(0) }.getOrNull(),
            )
        } catch (e: Exception) {
            Log.e(TAG, "info() falló", e)
            mapOf("brand" to BRAND)
        }
    }

    /** Nombres de los módulos de hardware presentes (PRINTER, BAR_SCANNER, ICC_READER…). */
    fun modules(): List<String> {
        if (!NewposSdk.ensureReady(context)) return emptyList()
        return try {
            DevConfig.getModules()?.map { it.name } ?: emptyList()
        } catch (e: Exception) {
            Log.e(TAG, "modules() falló", e)
            emptyList()
        }
    }

    /** true si el terminal declara el módulo (ej. DevConfig.BAR_SCANNER). */
    fun hasModule(name: String): Boolean {
        if (!NewposSdk.ensureReady(context)) return false
        return runCatching { DevConfig.getModuleByName(name) != null }.getOrDefault(false)
    }
}
