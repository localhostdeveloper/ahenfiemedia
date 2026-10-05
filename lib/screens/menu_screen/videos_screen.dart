import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/playlist.dart';
import '../../providers/youtube_provider.dart';
import 'playlist_videos_screen.dart';
import '../../widgets/app_network_image.dart';

class VideosScreen extends ConsumerWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final playlistsAsync = ref.watch(playlistsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text(AppConstants.videosLabel),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        top: false,
        child: playlistsAsync.when(
          loading: () => _LoadingGrid(colors: colors),
          error: (_, _) => _ErrorView(
              onRetry: () => ref.invalidate(playlistsProvider)),
          data: (playlists) {
            if (playlists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.video_library_outlined,
                        size: 52, color: colors.textMuted),
                    const SizedBox(height: 14),
                    Text('No playlists available yet.',
                        style: TextStyle(color: colors.textMuted, fontSize: 14)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: playlists.length,
              itemBuilder: (_, i) => _PlaylistCard(
                playlist: playlists[i],
                colors: colors,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        PlaylistVideosScreen(playlist: playlists[i]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Playlist card
// ─────────────────────────────────────────────────────────────────────────────
class _PlaylistCard extends StatelessWidget {
  final AppPlaylist playlist;
  final AhenfieColors colors;
  final VoidCallback onTap;

  const _PlaylistCard({
    required this.playlist,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14)),
              child: playlist.thumbnailUrl != null
                  ? AppNetworkImage(
                      url: playlist.thumbnailUrl!,
                      width: 120,
                      height: 72,
                      fit: BoxFit.cover,
                      error: _placeholder(colors),
                    )
                  : _placeholder(colors),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (playlist.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        playlist.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: colors.textMuted, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: colors.textMuted, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(AhenfieColors colors) => Container(
        width: 120,
        height: 72,
        color: colors.surface,
        child: const Center(
          child: Icon(Icons.play_circle_outline_rounded,
              color: AppColors.primaryGold, size: 30),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
class _LoadingGrid extends StatelessWidget {
  final AhenfieColors colors;
  const _LoadingGrid({required this.colors});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (_, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        height: 72,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.cardBorder),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: colors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text('Could not load playlists',
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
    );
  }
}
