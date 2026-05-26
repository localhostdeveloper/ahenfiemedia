-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.plugin.**
-dontwarn io.flutter.embedding.engine.FlutterShellArgs

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ExoPlayer (just_audio, audio_service, video_player, chewie)
-keep class com.google.android.exoplayer2.** { *; }
-keep class com.google.android.exoplayer2.ext.mediasession.** { *; }

# Audio service / just_audio background
-keep class com.ryanheise.just_audio.** { *; }
-keep class com.ryanheise.audio_service.** { *; }
-keep class androidx.media.** { *; }
-keep class androidx.media.session.** { *; }

# WebView (webview_flutter)
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

# Lifecycle
-keep class android.arch.lifecycle.** { *; }

# Google Play services
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.common.**
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
