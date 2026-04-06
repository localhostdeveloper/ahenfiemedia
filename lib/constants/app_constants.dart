// lib/constants/app_constants.dart

class AppConstants {
  // --- App Branding ---
  static const String appTitle = 'Ahenfie Media';
  static const String radioName = 'Ahenfie FM';
  static const String tvName = 'Ahenfie TV';

  // --- Radio Stream ---
  static const String radioStreamUrl =
      'https://radio.localstreamgh.com/listen/ahenfie_radio_/radio.mp3';
  static const String radioLogoUrl = 'https://i.imgur.com/oLHrmBI.jpeg';
  static const String radioMetadataTitle = 'Ahenfie FM';
  static const String radioMetadataArtist = '106.1MHz ';
  static const String radioChannelId = 'com.ahenfiemedia.radio';
  static const String radioNotificationName = 'Ahenfie FM';
  static const String notificationIcon = 'assets/images/noti.png';

  // --- Now Playing API ---
  static const String radioNowPlayingApiUrl =
      'https://radio.localstreamgh.com/api/nowplaying/ahenfie_radio_';

  // --- TV Stream ---
  static const String tvStreamUrl =
      'https://tv.localstreamgh.com/ahenfietv/index.m3u8';

  // --- Website URL ---
  static const String websiteUrl = "https://placeholder.com";

  // --- About Screen Text ---
  static const String appDeveloper = 'LocalCode Technology';
  static const String aboutAppDescription =
      """Ahenfie Media is your all-in-one destination for dynamic Ghanaian news, music, and entertainment. 
      Tune in to our Live Radio and Live TV broadcasts,
       catch up on the latest Podcasts, and stay informed with essential updates. 
       We connect you directly to the heartbeat of the culture, delivered seamlessly to your device.""";

  // Notification ---
  static const String keyReceiveNotifications = 'receiveNotifications';
  static const String keySoundAlerts = 'soundAlerts';
}
