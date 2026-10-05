import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/theme/app_colors.dart';
import '../../models/playlist.dart';
import '../../models/youtube_video.dart';
import '../../providers/youtube_provider.dart';
import '../../widgets/app_network_image.dart';

class PlaylistVideosScreen extends ConsumerStatefulWidget {
  final AppPlaylist playlist;

  const PlaylistVideosScreen({super.key, required this.playlist});

  @override
  ConsumerState<PlaylistVideosScreen> createState() =>
      _PlaylistVideosScreenState();
}

class _PlaylistVideosScreenState
    extends ConsumerState<PlaylistVideosScreen> {
  YoutubePlayerController? _controller;
  YoutubeVideo? _currentVideo;

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _playVideo(YoutubeVideo video) {
    if (_currentVideo?.id == video.id) return;
    setState(() => _currentVideo = video);

    // YouTube's own embedded player resolves and buffers the stream itself
    // (no manual manifest extraction), so this starts as fast as opening
    // youtube.com directly.
    if (_controller == null) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: video.id,
        autoPlay: true,
        params: const YoutubePlayerParams(showFullscreenButton: true),
      );
    } else {
      _controller!.loadVideoById(videoId: video.id);
    }
  }

  void _closePlayer() {
    _controller?.pauseVideo();
    setState(() => _currentVideo = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final playlistId = widget.playlist.playlistId;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(widget.playlist.name),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Inline player ──────────────────────────────────────
            if (_currentVideo != null && _controller != null) ...[
              YoutubePlayer(controller: _controller!),
              _NowPlayingBar(
                video: _currentVideo!,
                colors: colors,
                onClose: _closePlayer,
              ),
            ],

            // ── Video list ─────────────────────────────────────────
            Expanded(
              child: playlistId == null
                  ? Center(
                      child: Text('Invalid playlist URL.',
                          style: TextStyle(color: colors.textMuted)),
                    )
                  : Consumer(
                      builder: (_, ref, _) {
                        final videosAsync =
                            ref.watch(playlistVideosProvider(playlistId));
                        return videosAsync.when(
                          loading: () => _LoadingView(colors: colors),
                          error: (_, _) => _ErrorView(
                            onRetry: () => ref.invalidate(
                                playlistVideosProvider(playlistId)),
                          ),
                          data: (videos) => ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: videos.length,
                            itemBuilder: (_, i) => _VideoCard(
                              video: videos[i],
                              isPlaying: videos[i].id == _currentVideo?.id,
                              onTap: () => _playVideo(videos[i]),
                              colors: colors,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _NowPlayingBar extends StatelessWidget {
  final YoutubeVideo video;
  final AhenfieColors colors;
  final VoidCallback onClose;

  const _NowPlayingBar(
      {required this.video, required this.colors, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                if (video.formattedViews.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(video.formattedViews,
                      style:
                          TextStyle(color: colors.textMuted, fontSize: 11)),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded,
                color: colors.textMuted, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _VideoCard extends StatelessWidget {
  final YoutubeVideo video;
  final bool isPlaying;
  final VoidCallback onTap;
  final AhenfieColors colors;

  const _VideoCard({
    required this.video,
    required this.isPlaying,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.primaryGold.withValues(alpha: 0.08)
              : colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPlaying
                ? AppColors.primaryGold.withValues(alpha: 0.5)
                : colors.cardBorder,
            width: isPlaying ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppNetworkImage(
                    url: video.thumbnailUrl,
                    width: 110,
                    height: 62,
                    fit: BoxFit.cover,
                    error: Container(
                      width: 110,
                      height: 62,
                      color: colors.surface,
                      child: Icon(Icons.play_circle_outline_rounded,
                          color: colors.textMuted, size: 28),
                    ),
                  ),
                ),
                if (video.formattedDuration.isNotEmpty)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.formattedDuration,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                if (isPlaying)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color:
                            AppColors.primaryGold.withValues(alpha: 0.25),
                        child: const Center(
                          child: Icon(Icons.pause_circle_filled_rounded,
                              color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 10),

            // Metadata
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (video.isNew) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('NEW',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isPlaying
                          ? context.colors.accentText
                          : colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (video.formattedViews.isNotEmpty) ...[
                        Icon(Icons.visibility_outlined,
                            size: 11, color: colors.textMuted),
                        const SizedBox(width: 3),
                        Text(video.formattedViews,
                            style: TextStyle(
                                color: colors.textMuted, fontSize: 11)),
                        Text('  •  ',
                            style: TextStyle(
                                color: colors.textMuted, fontSize: 11)),
                      ],
                      if (video.relativeDate.isNotEmpty)
                        Text(video.relativeDate,
                            style: TextStyle(
                                color: colors.textMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 4, top: 10),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isPlaying ? AppColors.primaryGold : colors.textMuted,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  final AhenfieColors colors;
  const _LoadingView({required this.colors});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 110,
                height: 62,
                decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(8))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 13,
                      decoration: BoxDecoration(
                          color: colors.divider,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 6),
                  Container(
                      width: 160,
                      height: 13,
                      decoration: BoxDecoration(
                          color: colors.divider,
                          borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(
                      width: 100,
                      height: 11,
                      decoration: BoxDecoration(
                          color: colors.divider,
                          borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: colors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text('Could not load videos',
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primaryGold),
              label: Text('Retry',
                  style: TextStyle(
                      color: context.colors.accentText,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
