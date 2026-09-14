import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';

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

class _TVScreenState extends ConsumerState<TVScreen>
    with WidgetsBindingObserver {
  // Full top-to-bottom swipe over this many logical pixels swings 0..1.
  static const double _dragSensitivity = 220.0;

  double _volume = 1.0;
  double _brightness = 0.5;
  bool _isPaused = false;

  // True only when we auto-paused due to backgrounding — distinct from
  // _isPaused, which also covers an explicit double-tap pause.
  bool _pausedForBackground = false;

  bool _showVolumeOverlay = false;
  bool _showBrightnessOverlay = false;
  bool _showPlayPauseFlash = false;

  bool? _dragOnLeft;
  Timer? _hideOverlayTimer;
  Timer? _hidePlayPauseTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.onEnter();
    _loadInitialBrightness();
  }

  Future<void> _loadInitialBrightness() async {
    try {
      final b = await ScreenBrightness().application;
      if (mounted) setState(() => _brightness = b);
    } catch (_) {
      // Not supported on this platform — keep the default.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final tvState = ref.read(tvPlayerProvider);
    final notifier = ref.read(tvPlayerProvider.notifier);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Don't override an explicit double-tap pause, and don't bother if
      // there's nothing actually playing.
      if (!_isPaused && tvState.state == TVPlayerState.playing) {
        _pausedForBackground = true;
        notifier.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedForBackground) {
        _pausedForBackground = false;
        notifier.resume();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideOverlayTimer?.cancel();
    _hidePlayPauseTimer?.cancel();
    ScreenBrightness().resetApplicationScreenBrightness().catchError((_) {});
    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails details, double width) {
    _dragOnLeft = details.localPosition.dx < width / 2;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final onLeft = _dragOnLeft;
    if (onLeft == null) return;
    final delta = -details.delta.dy / _dragSensitivity;

    if (onLeft) {
      final next = (_brightness + delta).clamp(0.02, 1.0);
      setState(() {
        _brightness = next;
        _showBrightnessOverlay = true;
        _showVolumeOverlay = false;
      });
      ScreenBrightness().setApplicationScreenBrightness(next).catchError((_) {});
    } else {
      final next = (_volume + delta).clamp(0.0, 1.0);
      setState(() {
        _volume = next;
        _showVolumeOverlay = true;
        _showBrightnessOverlay = false;
      });
      _applyVolume(next);
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _dragOnLeft = null;
    _hideOverlayTimer?.cancel();
    _hideOverlayTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showVolumeOverlay = false;
          _showBrightnessOverlay = false;
        });
      }
    });
  }

  void _applyVolume(double normalized) {
    final tvState = ref.read(tvPlayerProvider);
    switch (tvState.mode) {
      case TVPlayerMode.chewie:
        tvState.chewieController?.videoPlayerController.setVolume(normalized);
      case TVPlayerMode.mediaKit:
        tvState.mediaKitController?.player.setVolume(normalized * 100);
      case null:
        break;
    }
  }

  void _togglePlayPause() {
    final notifier = ref.read(tvPlayerProvider.notifier);
    setState(() {
      _isPaused = !_isPaused;
      _showPlayPauseFlash = true;
    });
    if (_isPaused) {
      notifier.pause();
    } else {
      notifier.resume();
    }
    _hidePlayPauseTimer?.cancel();
    _hidePlayPauseTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showPlayPauseFlash = false);
    });
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragStart: isPlaying
                      ? (d) => _onVerticalDragStart(d, constraints.maxWidth)
                      : null,
                  onVerticalDragUpdate:
                      isPlaying ? _onVerticalDragUpdate : null,
                  onVerticalDragEnd: isPlaying ? _onVerticalDragEnd : null,
                  onDoubleTap: isPlaying ? _togglePlayPause : null,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _VideoContent(
                        tvState: tvState,
                        onRetry: () =>
                            ref.read(tvPlayerProvider.notifier).retry(),
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
                                Icon(Icons.circle,
                                    color: Colors.white, size: 6),
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

                      // Volume / brightness gesture indicator
                      if (_showVolumeOverlay)
                        Center(
                          child: _GestureIndicator(
                            icon: _volume == 0
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            value: _volume,
                          ),
                        ),
                      if (_showBrightnessOverlay)
                        Center(
                          child: _GestureIndicator(
                            icon: Icons.brightness_6_rounded,
                            value: _brightness,
                          ),
                        ),

                      // Double-tap play/pause flash
                      IgnorePointer(
                        child: AnimatedOpacity(
                          opacity: _showPlayPauseFlash ? 1 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPaused
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
class _GestureIndicator extends StatelessWidget {
  final IconData icon;
  final double value;

  const _GestureIndicator({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: Colors.white24,
                color: AppColors.primaryGold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
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

      TVPlayerState.playing => switch (tvState.mode) {
          TVPlayerMode.chewie when tvState.chewieController != null =>
            Chewie(controller: tvState.chewieController!),
          TVPlayerMode.mediaKit when tvState.mediaKitController != null =>
            Video(
              controller: tvState.mediaKitController!,
              controls: AdaptiveVideoControls,
            ),
          _ => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold)),
        },
    };
  }
}
