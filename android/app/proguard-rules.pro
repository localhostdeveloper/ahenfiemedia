-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn io.flutter.plugin.**
-dontwarn io.flutter.embedding.engine.FlutterShellArgs


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

# OneSignal
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# OkHttp (used by Supabase)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }

# Kotlin serialization (used by Supabase)
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keep class kotlinx.serialization.** { *; }
-dontwarn kotlinx.serialization.**

# Kotlin coroutines
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# Media3 / ExoPlayer v3 (video_player, chewie)
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**
