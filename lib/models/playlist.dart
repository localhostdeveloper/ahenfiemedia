class AppPlaylist {
  final String id;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final String playlistUrl;
  final int displayOrder;

  const AppPlaylist({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailUrl,
    required this.playlistUrl,
    this.displayOrder = 0,
  });

  factory AppPlaylist.fromSupabase(Map<String, dynamic> j) => AppPlaylist(
        id: j['id'] as String,
        name: j['name'] ?? '',
        description: j['description'] as String?,
        thumbnailUrl: j['thumbnail_url'] as String?,
        playlistUrl: j['playlist_url'] ?? '',
        displayOrder: (j['display_order'] as num?)?.toInt() ?? 0,
      );

  // Extracts the list= param from any YouTube URL
  String? get playlistId {
    try {
      return Uri.parse(playlistUrl).queryParameters['list'];
    } catch (_) {
      return null;
    }
  }
}
