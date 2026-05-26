import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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
}
