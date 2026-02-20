import 'package:ahenfie_media/screens/home_screen.dart';
//import 'package:ahenfie_media/utils/audio_session_helper.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'constants/app_constants.dart';
import 'constants/app_theme.dart';

import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'navigation_key.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.instance.initialize();

  //await setupAudioSession();
  //await JustAudioBackground.init(
  //androidNotificationChannelId: 'com.ahenfie.radio.channel.audio',
  //androidNotificationChannelName: 'Ahenfie FM Radio',
  //androidNotificationOngoing: true,
  //notificationColor: Color(0xFF96810E),
  // );

  await NotificationService.instance.initialize();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ahenfie.radio.channel.audio',
    androidNotificationChannelName: 'Ahenfie FM Radio',
    androidNotificationOngoing: true,
   
    preloadArtwork: true,
  );

  runApp(const ProviderScope(child: Channel247App()));
}

class Channel247App extends ConsumerWidget {
  const Channel247App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: AppConstants.appTitle,
      navigatorKey: navigatorKey,
      themeMode: themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
