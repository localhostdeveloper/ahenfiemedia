-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn com.google.firebase.**
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class android.arch.lifecycle.** { *; }



# Rules for the just_audio and audio_service packages.
# These are crucial for background playback to work properly.
-keep class com.google.android.exoplayer2.** { *; }
-keep class com.google.android.exoplayer2.ext.mediasession.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audio_service.** { *; }
-keep class androidx.media.** { *; }
-keep class androidx.media.session.** { *; }




# Rules for the video_player and chewie packages.
# These ensure the native video playback components aren't removed.
-keep class com.google.android.exoplayer2.** { *; }



# Rules for the flutter_inappwebview and webview_flutter packages.
# These are critical for the WebView to not crash.
-keepattributes *JavascriptInterface*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}


-keep class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, android.webkit.WebResourceRequest);
    public void *(android.webkit.WebView, android.webkit.WebResourceRequest, android.webkit.WebResourceError);
}
-keep class * extends android.webkit.WebChromeClient {
    public void *(android.webkit.WebView, android.webkit.ValueCallback, android.webkit.WebChromeClient$FileChooserParams);
}


-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-keep class com.pichillilorenzo.flutter_inappwebview$JavaScriptBridgeInterface {
    <fields>;
    <methods>;
    public *;
    private *;
}


# The following rules are generally good to have for most apps.
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.common.**
-dontwarn io.flutter.embedding.engine.FlutterShellArgs
-dontwarn io.flutter.plugin.**


-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**