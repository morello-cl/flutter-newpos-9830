package cl.mufin.newpos_9830

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.pos.device.printer.PrintTask
import com.pos.device.printer.Printer
import com.pos.device.printer.PrinterCallback
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Impresión térmica del Newpos 9830 usando la API de firmware
 * `com.pos.device.printer.*` (sin el wrapper propietario libprinter.jar).
 *
 * `startPrint` es asíncrono; se bloquea con un CountDownLatch y se reintenta
 * ante fallo/timeout. Llamar SIEMPRE desde un hilo secundario.
 *
 * Reutilizable: tanto el plugin como el flavor de una app host (ej. DTEx)
 * instancian `NewposPrinter(context)` y llaman `printBitmap`.
 */
class NewposPrinter(private val context: Context) {
    companion object {
        private const val TAG = "NewposPrinter"
        private const val PRINT_TIMEOUT_MS = 10000L
        private const val MAX_RETRIES = 2
        const val DEFAULT_GRAY = 120
        const val DEFAULT_FEED = 32
    }

    /**
     * Imprime un bitmap completo. Bloquea hasta terminar o agotar reintentos.
     * @return true si imprimió correctamente.
     */
    @JvmOverloads
    fun printBitmap(bitmap: Bitmap, gray: Int = DEFAULT_GRAY, feed: Int = DEFAULT_FEED): Boolean {
        if (!NewposSdk.ensureReady(context)) {
            Log.e(TAG, "SDK no inicializado")
            return false
        }
        val printer = Printer.getInstance()
        for (attempt in 0..MAX_RETRIES) {
            val task = PrintTask().apply {
                setGray(gray)
                setPrintBitmap(bitmap)
                addFeedPaper(feed)
            }
            try {
                val latch = CountDownLatch(1)
                val ok = AtomicBoolean(false)

                printer.reset()
                printer.startPrint(task, PrinterCallback { code, _ ->
                    ok.set(code == Printer.PRINTER_OK)
                    if (code != Printer.PRINTER_OK) Log.e(TAG, "startPrint code=$code (intento $attempt)")
                    latch.countDown()
                })

                val finished = latch.await(PRINT_TIMEOUT_MS, TimeUnit.MILLISECONDS)
                if (finished && ok.get()) return true
                if (!finished) {
                    // Impresión colgada: abortarla antes de reintentar. Si no, el
                    // siguiente reset()/startPrint podría imprimir dos veces, y el
                    // llamador recyclaría el bitmap mientras el SDK aún lo lee.
                    Log.w(TAG, "Impresión timeout (intento $attempt); cancelando")
                    runCatching { printer.cancelPrint(task) }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Excepción imprimiendo (intento $attempt)", e)
                runCatching { printer.cancelPrint(task) }
            }
            if (attempt < MAX_RETRIES) Thread.sleep(500)
        }
        Log.e(TAG, "Impresión falló tras ${MAX_RETRIES + 1} intentos")
        return false
    }

    /** Código de estado crudo del SDK (Printer.PRINTER_*). */
    fun status(): Int {
        if (!NewposSdk.ensureReady(context)) return -1
        return Printer.getInstance().status
    }
}
