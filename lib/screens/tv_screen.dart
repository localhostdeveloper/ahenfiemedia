import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../providers/tv_player_provider.dart';
import '../widgets/tv_epg_section.dart';

class TVScreen extends ConsumerStatefulWidget {
  final VoidCallback onEnter;

  const TVScreen({super.key, required this.onEnter});

  @override
  ConsumerState<TVScreen> createState() => _TVScreenState();
}

class _TVScreenState extends ConsumerState<TVScreen> {
  @override
  void initState() {
    super.initState();
    widget.onEnter();
  }

  @override
  Widget build(BuildContext context) {
    final tvState = ref.watch(tvPlayerProvider);
    final isPlaying = tvState.state == TVPlayerState.playing;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Video player ─────────────────────────────────────
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _VideoContent(
                  tvState: tvState,
                  onRetry: () => ref.read(tvPlayerProvider.notifier).retry(),
                ),

                // LIVE badge
                if (isPlaying)
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 6),
                          SizedBox(width: 5),
                          Text(
                            AppConstants.liveLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Channel info strip ───────────────────────────────
          Container(
            color: colors.drawerHeader,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  color: AppColors.primaryGold.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.tv_rounded,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.tvName,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        isPlaying
                            ? AppConstants.tvStreamingLive
                            : tvState.state == TVPlayerState.loading
                            ? AppConstants.tvConnecting
                            : AppConstants.tvOffline,
                        style: TextStyle(
                          color: isPlaying ? AppColors.success : colors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colors.textMuted.withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    AppConstants.hdLabel,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Schedule header ──────────────────────────────────
          Container(
            color: colors.background,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  AppConstants.tvScheduleLabel,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 1,
                  height: 14,
                  color: colors.textMuted.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 12),
                const Text(
                  AppConstants.tvEPGLabel,
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // ── EPG list ─────────────────────────────────────────
          const Expanded(child: TVEPGSection()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _VideoContent extends StatelessWidget {
  final TVPlayerData tvState;
  final VoidCallback onRetry;

  const _VideoContent({required this.tvState, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return switch (tvState.state) {
      TVPlayerState.loading => Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryGold),
              const SizedBox(height: 16),
              Text(
                AppConstants.tvLoadingStream,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),

      TVPlayerState.error => Container(
        color: Colors.black,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.signal_wifi_connected_no_internet_4_rounded,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                tvState.errorMessage ?? AppConstants.tvErrorStream,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primaryGold,
                  size: 18,
                ),
                label: const Text(
                  AppConstants.retryLabel,
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      TVPlayerState.playing => tvState.chewieController != null
          ? Chewie(controller: tvState.chewieController!)
          : const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold),
            ),
    };
  }
}
