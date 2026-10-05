package com.localcode.ahenfiemedia

import android.app.PictureInPictureParams
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// Extends AudioServiceActivity so background radio (just_audio_background)
// keeps working. Adds picture-in-picture for Live TV, driven from Dart over
// a method channel: PiP is only armed while TV is actually playing.
class MainActivity : AudioServiceActivity() {
    private var channel: MethodChannel? = null
    private var autoEnter = false

    private val pipSupported: Boolean
        get() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSupported" -> result.success(pipSupported)
                    "setAutoEnter" -> {
                        autoEnter = call.arguments as? Boolean ?: false
                        applyParams()
                        result.success(null)
                    }
                    "enter" -> result.success(enterPip())
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun buildParams(): PictureInPictureParams? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return null
        val builder = PictureInPictureParams.Builder().setAspectRatio(Rational(16, 9))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+: system enters PiP smoothly on the home gesture
            builder.setAutoEnterEnabled(autoEnter).setSeamlessResizeEnabled(true)
        }
        return builder.build()
    }

    private fun applyParams() {
        if (!pipSupported) return
        buildParams()?.let { setPictureInPictureParams(it) }
    }

    private fun enterPip(): Boolean {
        if (!pipSupported) return false
        val params = buildParams() ?: return false
        return try {
            enterPictureInPictureMode(params)
        } catch (e: IllegalStateException) {
            false
        }
    }

    // Android 8–11: no auto-enter flag, so enter PiP when the user leaves
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (autoEnter && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            enterPip()
        }
    }

    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration,
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        channel?.invokeMethod("pipChanged", isInPictureInPictureMode)
    }

    companion object {
        private const val CHANNEL = "com.localcode.ahenfiemedia/pip"
    }
}
