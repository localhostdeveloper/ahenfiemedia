import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/youtube_video.dart';
import '../services/youtube_service.dart';

final youtubeVideosProvider = FutureProvider<List<YoutubeVideo>>(
  (_) => YouTubeService.fetchChannelVideos(),
);
