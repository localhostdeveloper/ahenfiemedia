import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/playlist.dart';
import '../models/youtube_video.dart';
import '../services/youtube_service.dart';

final youtubeVideosProvider = FutureProvider<List<YoutubeVideo>>(
  (_) => YouTubeService.fetchChannelVideos(),
);

final playlistsProvider = FutureProvider<List<AppPlaylist>>((_) async {
  final rows = await Supabase.instance.client
      .from('playlists')
      .select()
      .order('display_order');
  return (rows as List)
      .map((r) => AppPlaylist.fromSupabase(r as Map<String, dynamic>))
      .toList();
});

// Keyed by playlistId — fetches videos for one specific playlist
final playlistVideosProvider =
    FutureProvider.family<List<YoutubeVideo>, String>(
  (_, playlistId) => YouTubeService.fetchPlaylistVideos(playlistId),
);
