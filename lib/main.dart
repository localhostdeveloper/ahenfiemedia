import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:media_kit/media_kit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants/app_constants.dart';
import 'constants/env.dart';

import 'core/theme/app_theme.dart';

import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'navigation_key.dart';

void main() async {
  try {
    // 1. Core Flutter engine initialization
    WidgetsFlutterBinding.ensureInitialized();

    // MediaKit (Huawei-compatible video player)
    MediaKit.ensureInitialized();

    // 3. Supabase (for presenters data & storage)
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );

    // 4. Initialize Audio Background BEFORE other notification services
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ahenfie.radio.channel.audio',
      androidNotificationChannelName: 'Ahenfie FM Radio',
      androidNotificationOngoing: true,
      preloadArtwork: true,
    );

    // 5. Initialize OneSignal notifications
    await NotificationService.instance.initialize();

  } catch (e) {
    debugPrint("Initialization Error: $e");
    // We continue to runApp even if a service fails so the user doesn't see a white screen
  }

  runApp(
    const ProviderScope(
      child: AhenfieMedia(),
    ),
  );
}

class AhenfieMedia extends ConsumerWidget {
  const AhenfieMedia({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppConstants.appTitle,
      navigatorKey: navigatorKey,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}