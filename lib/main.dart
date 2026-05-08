import 'package:ahenfie_media/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'constants/app_constants.dart';
// import 'constants/app_theme.dart';

import 'core/theme/app_theme.dart';

import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'navigation_key.dart';

void main() async {
  try {
    // 1. Core Flutter engine initialization
    WidgetsFlutterBinding.ensureInitialized();

    // 2. Firebase must come first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. Initialize Audio Background BEFORE other notification services
    
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ahenfie.radio.channel.audio',
      androidNotificationChannelName: 'Ahenfie FM Radio',
      androidNotificationOngoing: true,
      preloadArtwork: true,
    );

    // 4. Initialize FCM Notifications
    
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
      home: const HomeScreen(),
    );
  }
}