import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../constants/env.dart';
import '../models/youtube_video.dart';

class YouTubeService {
  static const _channelUrl = 'https://www.youtube.com/@AhenfieMediagh';

  static Future<List<YoutubeVideo>> fetchChannelVideos({int limit = 30}) async {
    final yt = YoutubeExplode();
    try {
      final channel = await yt.channels.get(_channelUrl);
      final List<YoutubeVideo> result = [];
      await for (final v in yt.channels.getUploads(channel.id)) {
        result.add(YoutubeVideo(
          id: v.id.value,
          title: v.title,
          thumbnailUrl: v.thumbnails.mediumResUrl,
          duration: v.duration,
          viewCount: v.engagement.viewCount,
          publishedAt: v.uploadDate,
        ));
        if (result.length >= limit) break;
      }
      return result;
    } finally {
      yt.close();
    }
  }

  /// Fetch videos from a YouTube playlist, sorted latest first.
  ///
  /// Uses the official YouTube Data API v3 rather than scraping the
  /// playlist page — youtube_explode_dart's playlist parser is broken
  /// against YouTube's current page format (it looks for renderer keys
  /// that no longer exist, so it silently returns zero videos for every
  /// playlist). The API is stable and won't break on the next redesign.
  ///
  /// Capped at [limit] (max 50, the API's own per-request ceiling) and
  /// bounded by an overall timeout so a slow/unreachable API can't leave
  /// the UI stuck on "loading" forever.
  static Future<List<YoutubeVideo>> fetchPlaylistVideos(
    String playlistId, {
    int limit = 50,
  }) {
    return _fetchPlaylistVideos(playlistId, limit)
        .timeout(const Duration(seconds: 20));
  }

  static Future<List<YoutubeVideo>> _fetchPlaylistVideos(
      String playlistId, int limit) async {
    final apiKey = Env.youtubeApiKey;

    final itemsUri = Uri.https('www.googleapis.com', '/youtube/v3/playlistItems', {
      'part': 'snippet,contentDetails',
      'playlistId': playlistId,
      'maxResults': '${limit.clamp(1, 50)}',
      'key': apiKey,
    });
    final itemsRes = await http.get(itemsUri);
    if (itemsRes.statusCode != 200) {
      throw Exception(
          'YouTube playlistItems error (${itemsRes.statusCode}): ${itemsRes.body}');
    }
    final items =
        (jsonDecode(itemsRes.body)['items'] as List<dynamic>? ?? const []);
    if (items.isEmpty) return [];

    final videoIds = items
        .map((it) => it['contentDetails']?['videoId'] as String?)
        .whereType<String>()
        .toList();

    // Batched in one call (the API allows up to 50 IDs) to get duration
    // and view count, which playlistItems doesn't include.
    final videosUri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
      'part': 'contentDetails,statistics',
      'id': videoIds.join(','),
      'key': apiKey,
    });
    final videosRes = await http.get(videosUri);
    final detailsById = <String, Map<String, dynamic>>{
      if (videosRes.statusCode == 200)
        for (final v
            in (jsonDecode(videosRes.body)['items'] as List<dynamic>? ??
                const []))
          v['id'] as String: v as Map<String, dynamic>,
    };

    final result = <YoutubeVideo>[];
    for (final item in items) {
      final snippet = item['snippet'] as Map<String, dynamic>?;
      final contentDetails = item['contentDetails'] as Map<String, dynamic>?;
      final videoId = contentDetails?['videoId'] as String?;
      if (snippet == null || videoId == null) continue;
      final title = snippet['title'] as String? ?? '';
      if (title == 'Private video' || title == 'Deleted video') continue;

      final thumbnails = snippet['thumbnails'] as Map<String, dynamic>?;
      final thumbUrl = thumbnails?['medium']?['url'] as String? ??
          thumbnails?['default']?['url'] as String? ??
          '';

      final details = detailsById[videoId];
      final durationIso = details?['contentDetails']?['duration'] as String?;
      final viewCountStr = details?['statistics']?['viewCount'] as String?;
      final publishedAtStr = (contentDetails?['videoPublishedAt'] as String?) ??
          (snippet['publishedAt'] as String?);

      result.add(YoutubeVideo(
        id: videoId,
        title: title,
        thumbnailUrl: thumbUrl,
        duration: durationIso != null ? _parseIso8601Duration(durationIso) : null,
        viewCount: viewCountStr != null ? int.tryParse(viewCountStr) : null,
        publishedAt:
            publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null,
      ));
    }

    // Sort latest first
    result.sort((a, b) {
      if (a.publishedAt == null && b.publishedAt == null) return 0;
      if (a.publishedAt == null) return 1;
      if (b.publishedAt == null) return -1;
      return b.publishedAt!.compareTo(a.publishedAt!);
    });
    return result;
  }

  static Duration _parseIso8601Duration(String iso) {
    final match = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?').firstMatch(iso);
    if (match == null) return Duration.zero;
    return Duration(
      hours: int.tryParse(match.group(1) ?? '') ?? 0,
      minutes: int.tryParse(match.group(2) ?? '') ?? 0,
      seconds: int.tryParse(match.group(3) ?? '') ?? 0,
    );
  }
}
