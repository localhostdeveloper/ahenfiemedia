class Env {
  // ── OneSignal ──────────────────────────────────────────────────────────────
  static const oneSignalAppId = String.fromEnvironment('ONESIGNAL_APP_ID');

  // ── Supabase ───────────────────────────────────────────────────────────────
  static const supabaseUrl     = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // ── Radio ──────────────────────────────────────────────────────────────────
  static const radioStreamUrl     = String.fromEnvironment('RADIO_STREAM_URL');
  static const radioNowPlayingUrl = String.fromEnvironment('RADIO_NOW_PLAYING_URL');

  // ── TV ────────────────────────────────────────────────────────────────────
  static const tvStreamUrl = String.fromEnvironment('TV_STREAM_URL');

  // ── Podcast ────────────────────────────────────────────────────────────────
  static const podcastRssUrl = String.fromEnvironment('PODCAST_RSS_URL');

  // ── Website ────────────────────────────────────────────────────────────────
  static const websiteUrl = String.fromEnvironment('WEBSITE_URL');

  // ── Contact ────────────────────────────────────────────────────────────────
  static const supportEmail       = String.fromEnvironment('SUPPORT_EMAIL');
  static const studioPhone1       = String.fromEnvironment('STUDIO_PHONE_1');
  static const studioPhone1E164   = String.fromEnvironment('STUDIO_PHONE_1_E164');
  static const studioPhone2       = String.fromEnvironment('STUDIO_PHONE_2');
  static const studioPhone2E164   = String.fromEnvironment('STUDIO_PHONE_2_E164');
  static const mapUrl             = String.fromEnvironment('MAP_URL');

  // ── Social Media ───────────────────────────────────────────────────────────
  static const youtubeUrl   = String.fromEnvironment('YOUTUBE_URL');
  static const facebookUrl  = String.fromEnvironment('FACEBOOK_URL');
  static const tiktokUrl    = String.fromEnvironment('TIKTOK_URL');
  static const instagramUrl = String.fromEnvironment('INSTAGRAM_URL');

  // ── YouTube Data API ───────────────────────────────────────────────────────
  static const youtubeApiKey = String.fromEnvironment('YOUTUBE_API_KEY');
}
