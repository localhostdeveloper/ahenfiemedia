// lib/constants/app_constants.dart
// Only static branding, labels, and non-sensitive strings.
// All URLs, API keys, and credentials live in .env via lib/constants/env.dart

class AppConstants {
  // ── App Branding ──────────────────────────────────────────────────────────
  static const String appTitle         = 'Ahenfie Media';
  static const String appNamePart1     = 'AHENFIE';
  static const String appNamePart2     = 'MEDIA';
  static const String appTagline       = 'NOKORE YE BAAKO PE';
  static const String appTagServices   = 'Radio  •  Podcast  •  TV  •  Digital';
  static const String kumasiTagline    = 'KUMASI, HEART OF ASHANTI';
  static const String footerSlogan     = 'NOKORE YE BAAKOPE';
  static const String kumasiLabel      = 'Kumasi';

  // ── Station ───────────────────────────────────────────────────────────────
  static const String radioName            = 'Ahenfie FM';
  static const String tvName               = 'Ahenfie TV';
  static const String radioFrequency       = '106.1 MHz · FM';
  static const String radioFrequencyShort  = '106.1 MHz FM';
  static const String fullStationName      = 'AHENFIE 106.1 FM';

  // ── Radio assets / metadata (not sensitive) ───────────────────────────────
  static const String radioLogoUrl          = 'assets/images/ahenfiefm.png';
  static const String radioMetadataTitle    = 'Ahenfie FM';
  static const String radioMetadataArtist   = '106.1MHz';
  static const String radioChannelId        = 'com.ahenfiemedia.radio';
  static const String radioNotificationName = 'Ahenfie FM';
  static const String notificationIcon      = 'assets/images/noti.png';

  // ── Podcast branding ──────────────────────────────────────────────────────
  static const String podcastShowTitle = 'Anopa Ahenfie';
  static const String podcastHost      = 'Nana Kwadwo Jantuah, PhD';

  // ── Radio player labels ───────────────────────────────────────────────────
  static const String radioConnecting  = 'CONNECTING...';
  static const String radioLiveOnAir   = '● LIVE ON AIR';
  static const String radioPaused      = 'PAUSED';
  static const String radioStreamError = 'STREAM ERROR';
  static const String radioTapToPlay   = 'TAP DISC TO PLAY';
  static const String radioLiveBadge   = 'LIVE';
  static const String radioOffAir      = 'OFF AIR';

  // ── Schedule sheet ────────────────────────────────────────────────────────
  static const String programScheduleLabel = 'PROGRAM SCHEDULE';
  static const String scheduleSheetTitle   = 'Program Schedule';
  static const String scheduleSheetBadge   = 'Daily';
  static const String noScheduleAvailable  = 'No programs available';
  static const String scheduleLoadError    = 'Failed to load schedule';

  // ── TV labels ─────────────────────────────────────────────────────────────
  static const String tvLoadingStream  = 'Loading stream...';
  static const String tvErrorStream    = 'Unable to load TV stream.';
  static const String tvConnectionLost = 'Connection lost. Tap retry to reconnect.';
  static const String tvStreamingLive  = 'Streaming live';
  static const String tvConnecting     = 'Connecting...';
  static const String tvOffline        = 'Offline';
  static const String tvScheduleLabel  = 'TV SCHEDULE';
  static const String tvEPGLabel       = 'EPG';
  static const String tvEPGLoadError   = 'Failed to load TV schedule';
  static const String tvEPGNoPrograms  = 'No programs scheduled';
  static const String noInternet       = 'No internet connection.';

  // ── EPG / Program ─────────────────────────────────────────────────────────
  static const String nowAiringLabel = 'NOW AIRING';
  static const String liveLabel      = 'LIVE';
  static const String nowLabel       = 'NOW';
  static const String hdLabel        = 'HD';
  static const String retryLabel     = 'Retry';

  // ── Home feed ─────────────────────────────────────────────────────────────
  static const String liveRadioLabel          = 'LIVE RADIO';
  static const String liveTVLabel             = 'LIVE TV';
  static const String nowOnAirSubtitle        = 'Now on air';
  static const String watchLiveBroadcast      = 'Watch Live Broadcast';
  static const String viewScheduleCTA         = 'View Schedule';
  static const String viewTVScheduleCTA       = 'View TV Schedule';
  static const String socialMediaLabel        = 'Social Media';
  static const String socialMediaSectionLabel = 'SOCIAL MEDIA';
  static const String viewAllLabel            = 'View All';
  static const String viewFeedsLabel          = 'VIEW\nFEEDS';
  static const String followUsLabel           = 'FOLLOW US';
  static const String followUsSubtitle        = 'Stay connected across all platforms';
  static const String listenAnytimeLabel      = 'LISTEN ANYTIME,\nANYWHERE';
  static const String listenSubtitle          = 'Ahenfie Media is with you';
  static const String listenLiveCTA           = 'LISTEN LIVE';

  // ── Social platform labels (URLs are in Env) ──────────────────────────────
  static const String youtubeLabel   = 'YouTube';
  static const String facebookLabel  = 'Facebook';
  static const String tiktokLabel    = 'TikTok';
  static const String instagramLabel = 'Instagram';

  // ── Exit sheet ────────────────────────────────────────────────────────────
  static const String exitTitle        = 'Exit Ahenfie Media?';
  static const String exitSubtitle     = 'This will stop radio playback and close the app.';
  static const String cancelLabel      = 'Cancel';
  static const String exitConfirmLabel = 'Yes, Exit';

  // ── Videos ────────────────────────────────────────────────────────────────
  static const String loadingVideos = 'Loading Videos...';

  // ── Coming Soon ───────────────────────────────────────────────────────────
  static const String comingSoonLabel       = 'COMING SOON';
  static const String comingSoonDescription =
      "We're working on something great. This section will be available in an upcoming update.";

  // ── Contact (non-sensitive) ───────────────────────────────────────────────
  static const String contactTitle        = 'GET IN TOUCH';
  static const String contactSubtitle     = "We'd love to hear from you";
  static const String contactDetailsLabel = 'CONTACT DETAILS';
  static const String studioHoursLabel    = 'STUDIO HOURS';
  static const String feedbackLabel       = 'FEEDBACK';
  static const String copiedToClipboard   = 'Copied to clipboard';
  static const String studioLocation      = 'Ankobea Street, Ollive Link, Kumasi';
  static const String studioGpsCode       = 'AK-038-1113';
  static const String studioFrequency     = '106.1 MHz FM';
  static const String studioHours1Days    = 'Monday - Friday';
  static const String studioHours1Time    = '6:00 AM - 10:00 PM';
  static const String studioHours2Days    = 'Saturday';
  static const String studioHours2Time    = '7:00 AM - 9:00 PM';
  static const String studioHours3Days    = 'Sunday';
  static const String studioHours3Time    = '8:00 AM - 6:00 PM';
  static const String feedbackText        =
      "Have a request, programme feedback, or want to advertise? "
      "Send us an email and we'll respond within 24 hours.";

  // ── About ─────────────────────────────────────────────────────────────────
  static const String aboutWhoWeAreLabel    = 'Who We Are';
  static const String aboutWhatWeOfferLabel = 'What We Offer';
  static const String aboutFindOnlineLabel  = 'Find Us Online';
  static const String appVersionLabel       = 'App Version';
  static const String developerLabel        = 'Developer';
  static const String contactLabel          = 'Contact';
  static const String appDeveloper          = 'LocalCode Technology';
  static const String aboutAppDescription =
      """Ahenfie Media is your all-in-one destination for dynamic Ghanaian news, music, and entertainment.
      Tune in to our Live Radio and Live TV broadcasts,
       catch up on the latest Podcasts, and stay informed with essential updates.
       We connect you directly to the heartbeat of the culture, delivered seamlessly to your device.""";

  // ── Profile / Settings ────────────────────────────────────────────────────
  static const String profileAppSection    = 'APP';
  static const String profileInfoSection   = 'INFO';
  static const String notificationsLabel   = 'Notifications';
  static const String settingsLabel        = 'Settings';
  static const String aboutUsLabel         = 'About Us';
  static const String privacyPolicyLabel   = 'Privacy Policy';
  static const String darkModeLabel        = 'Dark Mode';
  static const String darkModeSubtitle     = 'Switch between light and dark themes.';
  static const String changeThemeLabel     = 'Change Theme';
  static const String displaySettingsLabel = 'Display & Appearance';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String keyReceiveNotifications = 'receiveNotifications';
  static const String keySoundAlerts          = 'soundAlerts';

  // ── Drawer nav labels ─────────────────────────────────────────────────────
  static const String homeLabel        = 'Home';
  static const String liveRadioTab     = 'Live Radio';
  static const String liveTVTab        = 'Live TV';
  static const String profileLabel     = 'Profile';
  static const String podcastsLabel    = 'Podcasts';
  static const String presentersLabel  = 'Presenters';
  static const String videosLabel      = 'Videos';
  static const String newsLabel        = 'News';
  static const String showsLabel       = 'Shows';
  static const String eventsLabel      = 'Events';
  static const String galleryLabel     = 'Gallery';
}
