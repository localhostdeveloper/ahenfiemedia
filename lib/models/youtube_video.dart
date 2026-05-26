class YoutubeVideo {
  final String id;
  final String title;
  final String thumbnailUrl;
  final Duration? duration;
  final int? viewCount;
  final DateTime? publishedAt;

  const YoutubeVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    this.duration,
    this.viewCount,
    this.publishedAt,
  });

  String get formattedDuration {
    final d = duration;
    if (d == null) return '';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String get formattedViews {
    final v = viewCount;
    if (v == null) return '';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M views';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K views';
    return '$v views';
  }

  String get relativeDate {
    final d = publishedAt;
    if (d == null) return '';
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 365) {
      final y = (diff.inDays / 365).floor();
      return '$y ${y == 1 ? 'year' : 'years'} ago';
    }
    if (diff.inDays >= 30) {
      final m = (diff.inDays / 30).floor();
      return '$m ${m == 1 ? 'month' : 'months'} ago';
    }
    if (diff.inDays >= 7) {
      final w = (diff.inDays / 7).floor();
      return '$w ${w == 1 ? 'week' : 'weeks'} ago';
    }
    if (diff.inDays >= 1) return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
    if (diff.inHours >= 1) return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    return 'Just now';
  }

  bool get isNew {
    final d = publishedAt;
    if (d == null) return false;
    return DateTime.now().difference(d).inDays <= 7;
  }
}
