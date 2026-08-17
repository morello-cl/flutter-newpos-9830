package cl.mufin.newpos_9830

import android.content.Context
import android.util.Log
import com.pos.device.SDKManager
import com.pos.device.SDKManagerCallback
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/**
 * Gate de inicialización del SDK de firmware Newpos.
 *
 * `SDKManager.init` es asíncrono: hay que esperar `onFinish()` antes de usar
 * cualquier manager (Printer, DevConfig, Scanner, MagCardReader, IccReader).
 *
 * `ensureReady()` es idempotente y bloqueante: dispara el init una sola vez y
 * bloquea al llamador hasta que el SDK está listo. Debe llamarse SIEMPRE desde
 * un hilo secundario, nunca desde el UI thread.
 */
object NewposSdk {
    private const val TAG = "NewposSdk"
    private const val INIT_TIMEOUT_MS = 8000L

    @Volatile private var ready = false
    private var started = false
    // Recreable: un intento de init fallido debe poder reintentarse en la próxima llamada.
    @Volatile private var latch = CountDownLatch(1)

    /** Dispara el init una vez (thread-safe). No bloquea. */
    @Synchronized
    fun start(context: Context) {
        if (started || ready) return
        started = true
        latch = CountDownLatch(1)
        try {
            SDKManager.init(context.applicationContext, object : SDKManagerCallback {
                override fun onFinish() {
                    Log.d(TAG, "SDKManager init OK")
                    ready = true
                    latch.countDown()
                }
            })
        } catch (e: Exception) {
            // init lanzó sincrónicamente: no dejar el gate trabado para siempre.
            Log.e(TAG, "SDKManager.init falló; se permitirá reintento", e)
            started = false
            latch.countDown()
        }
    }

    /**
     * Garantiza que el SDK esté inicializado. Bloquea hasta [INIT_TIMEOUT_MS].
     * @return true si el SDK quedó listo. Si el init no completó a tiempo, se
     *         reinicia el gate para que una llamada posterior pueda reintentar.
     */
    fun ensureReady(context: Context): Boolean {
        if (ready) return true
        start(context)
        val current = latch
        val ok = try {
            current.await(INIT_TIMEOUT_MS, TimeUnit.MILLISECONDS) && ready
        } catch (e: InterruptedException) {
            Log.e(TAG, "ensureReady interrumpido", e)
            Thread.currentThread().interrupt()
            false
        }
        if (!ok) resetForRetry()
        return ok
    }

    /** Permite que la próxima llamada dispare el init de nuevo tras un fallo/timeout. */
    @Synchronized
    private fun resetForRetry() {
        if (!ready) started = false
    }
}
