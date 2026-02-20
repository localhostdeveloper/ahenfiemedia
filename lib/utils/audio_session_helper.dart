// lib/utils/audio_session_helper.dart
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> setupAudioSession() async {
  final session = await AudioSession.instance;

  await session.configure(
    AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
          AVAudioSessionCategoryOptions.allowBluetoothA2dp |
          AVAudioSessionCategoryOptions.allowAirPlay,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ),
  );

  // Initialize background audio
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ahenfie.radio.channel.audio',
    androidNotificationChannelName: 'Ahenfie FM Radio',
    androidNotificationOngoing: true,
  );
}
