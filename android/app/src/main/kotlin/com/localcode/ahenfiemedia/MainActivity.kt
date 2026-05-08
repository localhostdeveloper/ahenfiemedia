package com.localcode.ahenfiemedia



import android.app.PictureInPictureParams
import android.os.Build
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {

            val params = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(16, 9))
                .build()

            enterPictureInPictureMode(params)
        }
    }
}