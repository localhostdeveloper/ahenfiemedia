class PodcastEpisode {
  final String guid;
  final String title;
  final String? description;
  final String audioUrl;
  final DateTime? pubDate;
  final Duration? duration;

  const PodcastEpisode({
    required this.guid,
    required this.title,
    this.description,
    required this.audioUrl,
    this.pubDate,
    this.duration,
  });

  String get formattedDuration {
    final d = duration;
    if (d == null) return '';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String get relativeDate {
    final d = pubDate;
    if (d == null) return '';
    final diff = DateTime.now().toUtc().difference(d);
    if (diff.inDays >= 365) {
      final y = (diff.inDays / 365).floor();
      return '$y ${y == 1 ? 'year' : 'years'} ago';
    }
    if (diff.inDays >= 30) {
      final mo = (diff.inDays / 30).floor();
      return '$mo ${mo == 1 ? 'month' : 'months'} ago';
    }
    if (diff.inDays >= 7) {
      final w = (diff.inDays / 7).floor();
      return '$w ${w == 1 ? 'week' : 'weeks'} ago';
    }
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }

  bool get isNew {
    final d = pubDate;
    if (d == null) return false;
    return DateTime.now().toUtc().difference(d).inDays <= 7;
  }
}
