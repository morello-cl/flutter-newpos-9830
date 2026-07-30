package cl.mufin.newpos_9830

import android.content.Context
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import com.pos.device.icc.OperatorMode
import com.pos.device.icc.SlotType
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executors

/** Plugin newpos_9830: wrapper del SDK de firmware Newpos (com.pos.device.*). */
class Newpos9830Plugin :
    FlutterPlugin,
    MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    // Los wrappers bloquean (esperan callbacks del SDK): despachar fuera del UI thread.
    private val io = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    private val printer by lazy { NewposPrinter(context) }
    private val device by lazy { NewposDevice(context) }
    private val scanner by lazy { NewposScanner(context) }
    private val magcard by lazy { NewposMagcard(context) }
    private val icc by lazy { NewposIcc(context) }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        // NO se inicializa el SDK aquí: el plugin puede estar presente en apps
        // multi-flavor que también corren en hardware no-Newpos. La init es lazy
        // (NewposSdk.ensureReady) en la primera llamada real, para no tocar
        // com.pos.device.* en devices que no lo proveen.
        channel = MethodChannel(binding.binaryMessenger, "cl.mufin.newpos_9830/methods")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        io.execute {
            try {
                val value: Any? = dispatch(call)
                main.post { result.success(value) }
            } catch (e: NotImplemented) {
                main.post { result.notImplemented() }
            } catch (e: Exception) {
                main.post { result.error("NEWPOS_ERROR", e.message, null) }
            }
        }
    }

    private class NotImplemented : Exception()

    private fun dispatch(call: MethodCall): Any? = when (call.method) {
        "device.info" -> device.info()
        "device.modules" -> device.modules()
        "device.hasModule" -> device.hasModule(call.argument("name")!!)

        "printer.printImage" -> {
            val bytes = call.argument<ByteArray>("png")!!
            val gray = call.argument<Int>("gray") ?: NewposPrinter.DEFAULT_GRAY
            val bmp = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                ?: throw IllegalArgumentException("PNG inválido")
            try {
                printer.printBitmap(bmp, gray)
            } finally {
                bmp.recycle()
            }
        }
        "printer.status" -> printer.status()

        "scanner.scan" -> scanner.scanOnce(call.argument<Int>("timeoutSeconds") ?: 30)
        "scanner.stop" -> { scanner.stop(); null }

        "magcard.readTracks" -> magcard.readTracks(call.argument<Int>("timeoutSeconds") ?: 30)

        "icc.connect" -> icc.connect(slotOf(call), modeOf(call))
        "icc.transmit" -> icc.transmit(slotOf(call), call.argument<ByteArray>("apdu")!!)
        "icc.disconnect" -> { icc.disconnect(slotOf(call)); null }

        else -> throw NotImplemented()
    }

    private fun slotOf(call: MethodCall): SlotType =
        SlotType.valueOf(call.argument<String>("slot") ?: "PSAM1")

    private fun modeOf(call: MethodCall): OperatorMode =
        OperatorMode.valueOf(call.argument<String>("mode") ?: "ISO_MODE")

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        io.shutdown()
    }
}
