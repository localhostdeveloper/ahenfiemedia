import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/youtube_video.dart';
import '../../providers/youtube_provider.dart';

class VideosScreen extends ConsumerStatefulWidget {
  const VideosScreen({super.key});

  @override
  ConsumerState<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends ConsumerState<VideosScreen> {
  WebViewController? _webController;
  YoutubeVideo? _currentVideo;

  void _playVideo(YoutubeVideo video) {
    if (_currentVideo?.id == video.id) return;

    final embedUrl =
        'https://www.youtube.com/embed/${video.id}?autoplay=1&playsinline=1&rel=0&modestbranding=1';

    if (_webController == null) {
      final ctrl = WebViewController(
          onPermissionRequest: (request) => request.deny(),
        )
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..loadRequest(Uri.parse(embedUrl));
      setState(() {
        _currentVideo = video;
        _webController = ctrl;
      });
    } else {
      _webController!.loadRequest(Uri.parse(embedUrl));
      setState(() => _currentVideo = video);
    }
  }

  void _closePlayer() {
    _webController?.loadRequest(Uri.parse('about:blank'));
    setState(() {
      _currentVideo = null;
      _webController = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final videosAsync = ref.watch(youtubeVideosProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(AppConstants.videosLabel),
        backgroundColor: colors.background,
      ),
      body: Column(
        children: [
          // ── Inline YouTube embed player ────────────────────────
          if (_currentVideo != null && _webController != null) ...[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: WebViewWidget(controller: _webController!),
            ),
            _NowPlayingBar(
              video: _currentVideo!,
              colors: colors,
              onClose: _closePlayer,
            ),
          ],

          // ── Video list ─────────────────────────────────────────
          Expanded(
            child: videosAsync.when(
              loading: () => const _LoadingView(),
              error: (e, _) => _ErrorView(
                onRetry: () => ref.invalidate(youtubeVideosProvider),
              ),
              data: (videos) => _VideoList(
                videos: videos,
                currentVideoId: _currentVideo?.id,
                onTap: _playVideo,
                colors: colors,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Now-playing info bar
// ─────────────────────────────────────────────────────────────────────────────
class _NowPlayingBar extends StatelessWidget {
  final YoutubeVideo video;
  final AhenfieColors colors;
  final VoidCallback onClose;

  const _NowPlayingBar({
    required this.video,
    required this.colors,
    required this.onClose,
  });

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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    AppConstants.radioName,
                    if (video.formattedViews.isNotEmpty) video.formattedViews,
                  ].join('  •  '),
                  style: TextStyle(color: colors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon:
                Icon(Icons.close_rounded, color: colors.textMuted, size: 20),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Video list
// ─────────────────────────────────────────────────────────────────────────────
class _VideoList extends StatelessWidget {
  final List<YoutubeVideo> videos;
  final String? currentVideoId;
  final ValueChanged<YoutubeVideo> onTap;
  final AhenfieColors colors;

  const _VideoList({
    required this.videos,
    required this.currentVideoId,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: videos.length,
      itemBuilder: (context, i) => _VideoCard(
        video: videos[i],
        isPlaying: videos[i].id == currentVideoId,
        onTap: () => onTap(videos[i]),
        colors: colors,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual video card — podcast-episode style
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
            // ── Thumbnail ─────────────────────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    video.thumbnailUrl,
                    width: 110,
                    height: 62,
                    fit: BoxFit.cover,
                    errorBuilder: (context, err, stack) => Container(
                      width: 110,
                      height: 62,
                      color: colors.surface,
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: colors.textMuted,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                // Duration badge
                if (video.formattedDuration.isNotEmpty)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.formattedDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Currently playing overlay
                if (isPlaying)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: AppColors.primaryGold.withValues(alpha: 0.25),
                        child: const Center(
                          child: Icon(
                            Icons.pause_circle_filled_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 10),

            // ── Metadata ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NEW badge
                  if (video.isNew) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isPlaying
                          ? AppColors.primaryGold
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
                        Icon(
                          Icons.visibility_outlined,
                          size: 11,
                          color: colors.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          video.formattedViews,
                          style:
                              TextStyle(color: colors.textMuted, fontSize: 11),
                        ),
                        Text(
                          '  •  ',
                          style:
                              TextStyle(color: colors.textMuted, fontSize: 11),
                        ),
                      ],
                      if (video.relativeDate.isNotEmpty)
                        Text(
                          video.relativeDate,
                          style:
                              TextStyle(color: colors.textMuted, fontSize: 11),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Play/Pause icon ───────────────────────────────────
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
// Loading shimmer rows
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (ctx, i) => Container(
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
            _ShimmerBox(width: 110, height: 62, radius: 8, colors: colors),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(
                      width: double.infinity, height: 13, radius: 4, colors: colors),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 160, height: 13, radius: 4, colors: colors),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 100, height: 11, radius: 4, colors: colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final AhenfieColors colors;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.divider,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────
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
            Text(
              'Could not load videos',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primaryGold),
              label: const Text(
                'Retry',
                style: TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
