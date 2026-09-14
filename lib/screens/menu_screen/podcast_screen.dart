import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/podcast_episode.dart';
import '../../providers/podcast_provider.dart';

enum _SortOrder { latest, oldest, titleAZ, titleZA, shortest, longest }

extension _SortLabel on _SortOrder {
  String get label => switch (this) {
        _SortOrder.latest   => 'Latest First',
        _SortOrder.oldest   => 'Oldest First',
        _SortOrder.titleAZ  => 'Title A–Z',
        _SortOrder.titleZA  => 'Title Z–A',
        _SortOrder.shortest => 'Shortest First',
        _SortOrder.longest  => 'Longest First',
      };

  IconData get icon => switch (this) {
        _SortOrder.latest   => Icons.arrow_downward_rounded,
        _SortOrder.oldest   => Icons.arrow_upward_rounded,
        _SortOrder.titleAZ  => Icons.sort_by_alpha_rounded,
        _SortOrder.titleZA  => Icons.sort_by_alpha_rounded,
        _SortOrder.shortest => Icons.timer_outlined,
        _SortOrder.longest  => Icons.timer_rounded,
      };
}

List<PodcastEpisode> _sorted(List<PodcastEpisode> src, _SortOrder order) {
  final list = [...src];
  switch (order) {
    case _SortOrder.latest:
      list.sort((a, b) => (b.pubDate ?? DateTime(0))
          .compareTo(a.pubDate ?? DateTime(0)));
    case _SortOrder.oldest:
      list.sort((a, b) => (a.pubDate ?? DateTime(0))
          .compareTo(b.pubDate ?? DateTime(0)));
    case _SortOrder.titleAZ:
      list.sort((a, b) => a.title.compareTo(b.title));
    case _SortOrder.titleZA:
      list.sort((a, b) => b.title.compareTo(a.title));
    case _SortOrder.shortest:
      list.sort((a, b) =>
          (a.duration ?? Duration.zero).compareTo(b.duration ?? Duration.zero));
    case _SortOrder.longest:
      list.sort((a, b) =>
          (b.duration ?? Duration.zero).compareTo(a.duration ?? Duration.zero));
  }
  return list;
}

class PodcastScreen extends ConsumerStatefulWidget {
  const PodcastScreen({super.key});

  @override
  ConsumerState<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends ConsumerState<PodcastScreen> {
  _SortOrder _sortOrder = _SortOrder.latest;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final episodesAsync = ref.watch(podcastEpisodesProvider);
    final playerState = ref.watch(podcastPlayerProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Podcasts'),
        backgroundColor: colors.background,
        actions: [
          // Sort menu
          PopupMenuButton<_SortOrder>(
            icon: Icon(Icons.sort_rounded, color: colors.textMuted),
            tooltip: 'Sort',
            color: colors.surface,
            onSelected: (order) => setState(() => _sortOrder = order),
            itemBuilder: (_) => _SortOrder.values.map((o) {
              final selected = o == _sortOrder;
              return PopupMenuItem(
                value: o,
                child: Row(
                  children: [
                    Icon(o.icon,
                        size: 18,
                        color: selected
                            ? AppColors.primaryGold
                            : colors.textMuted),
                    const SizedBox(width: 10),
                    Text(
                      o.label,
                      style: TextStyle(
                        color: selected
                            ? AppColors.primaryGold
                            : colors.textPrimary,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    if (selected) ...[
                      const Spacer(),
                      const Icon(Icons.check_rounded,
                          size: 16, color: AppColors.primaryGold),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.textMuted),
            onPressed: () => ref.invalidate(podcastEpisodesProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: episodesAsync.when(
              loading: () => const _LoadingView(),
              error: (_, _) => _ErrorView(
                onRetry: () => ref.invalidate(podcastEpisodesProvider),
              ),
              data: (episodes) {
                if (episodes.isEmpty) return const _EmptyView();
                final sorted = _sorted(episodes, _sortOrder);
                return _EpisodeList(
                  episodes: sorted,
                  playerState: playerState,
                  onTap: (ep) {
                    final notifier =
                        ref.read(podcastPlayerProvider.notifier);
                    if (notifier.isCurrentEpisode(ep.guid)) {
                      if (playerState.status == PodcastPlayerStatus.playing) {
                        notifier.pause();
                      } else {
                        notifier.resume();
                      }
                    } else {
                      notifier.playEpisode(ep);
                    }
                  },
                );
              },
            ),
          ),
          if (playerState.isActive)
            _MiniPlayer(
              onClose: () =>
                  ref.read(podcastPlayerProvider.notifier).stop(),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Episode list
// ─────────────────────────────────────────────────────────────────────────────
class _EpisodeList extends StatelessWidget {
  final List<PodcastEpisode> episodes;
  final PodcastPlayerState playerState;
  final ValueChanged<PodcastEpisode> onTap;

  const _EpisodeList({
    required this.episodes,
    required this.playerState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemCount: episodes.length,
      itemBuilder: (_, i) {
        final ep = episodes[i];
        final isCurrent =
            playerState.episode?.guid == ep.guid && playerState.isActive;
        final isPlaying =
            isCurrent && playerState.status == PodcastPlayerStatus.playing;
        final isLoading =
            isCurrent && playerState.status == PodcastPlayerStatus.loading;
        return _EpisodeCard(
          episode: ep,
          number: i + 1,
          isCurrent: isCurrent,
          isPlaying: isPlaying,
          isLoading: isLoading,
          onTap: () => onTap(ep),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Episode card
// ─────────────────────────────────────────────────────────────────────────────
class _EpisodeCard extends StatelessWidget {
  final PodcastEpisode episode;
  final int number;
  final bool isCurrent;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onTap;

  const _EpisodeCard({
    required this.episode,
    required this.number,
    required this.isCurrent,
    required this.isPlaying,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primaryGold.withValues(alpha: 0.08)
              : colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent
                ? AppColors.primaryGold.withValues(alpha: 0.5)
                : colors.cardBorder,
            width: isCurrent ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // ── Episode number / state icon ────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primaryGold
                    : AppColors.primaryGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: isCurrent ? Colors.black : AppColors.primaryGold,
                      size: 24,
                    ),
            ),

            const SizedBox(width: 12),

            // ── Title + meta ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (episode.isNew) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
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
                    episode.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCurrent
                          ? AppColors.primaryGold
                          : colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 10, color: colors.textMuted),
                      const SizedBox(width: 3),
                      Text(
                        episode.relativeDate,
                        style:
                            TextStyle(color: colors.textMuted, fontSize: 11),
                      ),
                      if (episode.formattedDuration.isNotEmpty) ...[
                        Text('  •  ',
                            style: TextStyle(
                                color: colors.textMuted, fontSize: 11)),
                        Icon(Icons.access_time_rounded,
                            size: 10, color: colors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          episode.formattedDuration,
                          style: TextStyle(
                              color: colors.textMuted, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Ep number badge ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'EP $number',
                style: TextStyle(
                  color: isCurrent
                      ? AppColors.primaryGold
                      : colors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini player — stateful for the seek slider
// ─────────────────────────────────────────────────────────────────────────────
class _MiniPlayer extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  const _MiniPlayer({required this.onClose});

  @override
  ConsumerState<_MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<_MiniPlayer> {
  double? _dragValue;

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(podcastPlayerProvider);
    final position =
        ref.watch(podcastPositionProvider).value ?? Duration.zero;
    final duration = ref.watch(podcastDurationProvider).value;

    final maxSec = (duration?.inSeconds ?? 0).toDouble();
    final curSec =
        (_dragValue ?? position.inSeconds.toDouble()).clamp(0.0, maxSec);
    final isPlaying = state.status == PodcastPlayerStatus.playing;
    final isLoading = state.status == PodcastPlayerStatus.loading;
    final notifier = ref.read(podcastPlayerProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
            top: BorderSide(color: AppColors.primaryGold.withValues(alpha: 0.3))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Title row ────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.mic_rounded,
                        color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.episode?.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          AppConstants.podcastShowTitle,
                          style: TextStyle(
                              color: colors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // Play / Pause
                  isLoading
                      ? const SizedBox(
                          width: 36,
                          height: 36,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        )
                      : IconButton(
                          onPressed: isPlaying
                              ? notifier.pause
                              : notifier.resume,
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            color: AppColors.primaryGold,
                            size: 36,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                  const SizedBox(width: 4),
                  // Close
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Icon(Icons.close_rounded,
                        color: colors.textMuted, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // ── Progress slider ───────────────────────────────────
              Row(
                children: [
                  Text(
                    _fmt(Duration(seconds: curSec.toInt())),
                    style:
                        TextStyle(color: colors.textMuted, fontSize: 11),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2.5,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14),
                        activeTrackColor: AppColors.primaryGold,
                        inactiveTrackColor:
                            AppColors.primaryGold.withValues(alpha: 0.2),
                        thumbColor: AppColors.primaryGold,
                        overlayColor:
                            AppColors.primaryGold.withValues(alpha: 0.15),
                      ),
                      child: Slider(
                        value: maxSec > 0 ? curSec : 0,
                        min: 0,
                        max: maxSec > 0 ? maxSec : 1,
                        onChanged: maxSec > 0
                            ? (v) => setState(() => _dragValue = v)
                            : null,
                        onChangeEnd: maxSec > 0
                            ? (v) {
                                notifier
                                    .seekTo(Duration(seconds: v.toInt()));
                                setState(() => _dragValue = null);
                              }
                            : null,
                      ),
                    ),
                  ),
                  Text(
                    duration != null ? _fmt(duration) : '--:--',
                    style:
                        TextStyle(color: colors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading view
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryGold),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty view
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_none_rounded, size: 64, color: AppColors.primaryGold),
            const SizedBox(height: 16),
            Text(
              'No episodes yet',
              style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back soon for new Ahenfie podcast episodes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, fontSize: 13),
            ),
          ],
        ),
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
              'Could not load episodes',
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
