import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../constants/app_constants.dart';
import '../constants/env.dart';
import '../services/network_service.dart';

enum TVPlayerState { loading, playing, error }
enum TVPlayerMode { chewie, mediaKit }

class TVPlayerData {
  final TVPlayerState state;
  final TVPlayerMode? mode;
  final ChewieController? chewieController;
  final VideoController? mediaKitController;
  final String? errorMessage;

  const TVPlayerData({
    required this.state,
    this.mode,
    this.chewieController,
    this.mediaKitController,
    this.errorMessage,
  });
}

class TVPlayerNotifier extends Notifier<TVPlayerData> {
  static const _maxAutoRetries = 3;
  static const _autoRetryDelay = Duration(seconds: 2);

  VideoPlayerController? _vpController;
  ChewieController? _chewieController;
  Player? _mkPlayer;
  VideoController? _mkController;

  // Cancels subscriptions from the previous media_kit session
  StreamSubscription? _playingSub;
  StreamSubscription? _errorSub;

  // Watch the active session for a stream drop — unlike _playingSub/_errorSub
  // above, these stay alive for as long as playback is ongoing, not just
  // during the initial connection.
  StreamSubscription? _mkWatchdogSub;
  void Function()? _chewieWatchdogListener;

  int _autoRetryAttempts = 0;

  // True whenever pause() was called deliberately (manual pause, tab switch,
  // app backgrounded) so the watchdog doesn't mistake it for a stream drop.
  bool _pausedIntentionally = false;

  // Incremented on every retry — stale callbacks check against this
  int _generation = 0;

  @override
  TVPlayerData build() {
    ref.onDispose(_disposeAll);
    _start();
    return const TVPlayerData(state: TVPlayerState.loading);
  }

  Future<void> _start() async {
    final gen = _generation;

    try {
      final hasInternet = await NetworkService.hasInternet();
      if (gen != _generation) return;

      if (!hasInternet) {
        state = const TVPlayerData(
          state: TVPlayerState.error,
          errorMessage: 'No internet connection.',
        );
        return;
      }

      // ── Try Chewie (ExoPlayer) first ────────────────────────────
      final chewieOk = await _tryChewiePlayer(gen);
      if (gen != _generation) return;
      if (chewieOk) return;

      // ── Fall back to media_kit ──────────────────────────────────
      await _disposeChewieOnly();
      if (gen != _generation) return;

      await _tryMediaKitPlayer(gen);
    } catch (_) {
      if (gen != _generation) return;
      state = const TVPlayerData(
        state: TVPlayerState.error,
        errorMessage: 'Unable to load TV stream.',
      );
      WakelockPlus.disable();
    }
  }

  Future<bool> _tryChewiePlayer(int gen) async {
    void Function()? listener;
    try {
      _vpController = VideoPlayerController.networkUrl(
        Uri.parse(Env.tvStreamUrl),
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
        },
      );

      await _vpController!
          .initialize()
          .timeout(const Duration(seconds: 10));
      if (gen != _generation) return false;
      if (!_vpController!.value.isInitialized) return false;

      final completer = Completer<bool>();
      listener = () {
        if (completer.isCompleted) return;
        if (_vpController!.value.isPlaying) {
          completer.complete(true);
        } else if (_vpController!.value.hasError) {
          completer.complete(false);
        }
      };

      _vpController!.addListener(listener);
      await _vpController!.play();

      final started = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );

      if (gen != _generation) return false;

      if (!started) return false;

      _chewieController = ChewieController(
        videoPlayerController: _vpController!,
        autoPlay: true,
        looping: false,
        isLive: true,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: false,
      );

      state = TVPlayerData(
        state: TVPlayerState.playing,
        mode: TVPlayerMode.chewie,
        chewieController: _chewieController,
      );
      WakelockPlus.enable();
      _autoRetryAttempts = 0;

      _chewieWatchdogListener = () {
        if (_pausedIntentionally) return;
        if (_vpController?.value.hasError == true) _handleStreamDropped();
      };
      _vpController!.addListener(_chewieWatchdogListener!);
      return true;
    } catch (_) {
      return false;
    } finally {
      // Always remove listener — even on exception or timeout
      if (listener != null) {
        _vpController?.removeListener(listener);
      }
    }
  }

  Future<void> _tryMediaKitPlayer(int gen) async {
    _mkPlayer = Player(
      configuration: const PlayerConfiguration(
        bufferSize: 32 * 1024 * 1024,
      ),
    );
    _mkController = VideoController(_mkPlayer!);

    if (_mkPlayer!.platform is NativePlayer) {
      await (_mkPlayer!.platform as NativePlayer)
          .setProperty('hwdec', 'mediacodec-copy');
    }
    if (gen != _generation) return;

    final completer = Completer<bool>();

    _playingSub = _mkPlayer!.stream.playing.listen((playing) {
      if (playing && !completer.isCompleted) completer.complete(true);
    });

    _errorSub = _mkPlayer!.stream.error.listen((_) {
      if (!completer.isCompleted) completer.complete(false);
    });

    await _mkPlayer!.open(
      Media(
        Env.tvStreamUrl,
        httpHeaders: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
          'Accept': '*/*',
          'Connection': 'keep-alive',
        },
      ),
      play: true,
    );

    final success = await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => false,
    );

    await _playingSub?.cancel();
    await _errorSub?.cancel();
    _playingSub = null;
    _errorSub = null;

    if (gen != _generation) return;

    if (success) {
      state = TVPlayerData(
        state: TVPlayerState.playing,
        mode: TVPlayerMode.mediaKit,
        mediaKitController: _mkController,
      );
      WakelockPlus.enable();
      _autoRetryAttempts = 0;

      _mkWatchdogSub = _mkPlayer!.stream.error.listen((_) {
        if (_pausedIntentionally) return;
        _handleStreamDropped();
      });
    } else {
      state = const TVPlayerData(
        state: TVPlayerState.error,
        errorMessage: 'Unable to load TV stream.',
      );
      WakelockPlus.disable();
    }
  }

  // Called when the active stream errors out mid-playback (network blip,
  // CDN hiccup). Silently retries a few times before surfacing an error.
  Future<void> _handleStreamDropped() async {
    if (_pausedIntentionally) return;
    final gen = _generation;
    _autoRetryAttempts++;

    if (_autoRetryAttempts > _maxAutoRetries) {
      _autoRetryAttempts = 0;
      await _disposeAll();
      if (gen != _generation) return;
      state = const TVPlayerData(
        state: TVPlayerState.error,
        errorMessage: AppConstants.tvConnectionLost,
      );
      return;
    }

    state = const TVPlayerData(state: TVPlayerState.loading);
    await _disposeAll();
    if (gen != _generation) return;
    await Future.delayed(_autoRetryDelay);
    if (gen != _generation) return;
    await _start();
  }

  Future<void> retry() async {
    _generation++; // invalidate any in-flight operations
    _autoRetryAttempts = 0;
    await _disposeAll();
    state = const TVPlayerData(state: TVPlayerState.loading);
    await _start();
  }

  Future<void> pause() async {
    _pausedIntentionally = true;
    await _vpController?.pause();
    await _mkPlayer?.pause();
    WakelockPlus.disable();
  }

  Future<void> resume() async {
    final current = state;
    if (current.state == TVPlayerState.playing) {
      _pausedIntentionally = false;
      await _vpController?.play();
      await _mkPlayer?.play();
      WakelockPlus.enable();
    } else if (current.state != TVPlayerState.loading) {
      _pausedIntentionally = false;
      await retry();
    }
  }

  Future<void> destroy() async {
    _generation++;
    await _disposeAll();
    state = const TVPlayerData(state: TVPlayerState.loading);
  }

  Future<void> _disposeChewieOnly() async {
    if (_chewieWatchdogListener != null) {
      _vpController?.removeListener(_chewieWatchdogListener!);
      _chewieWatchdogListener = null;
    }
    _chewieController?.dispose();
    _chewieController = null;
    await _vpController?.dispose();
    _vpController = null;
  }

  Future<void> _disposeAll() async {
    await _playingSub?.cancel();
    await _errorSub?.cancel();
    _playingSub = null;
    _errorSub = null;
    await _mkWatchdogSub?.cancel();
    _mkWatchdogSub = null;
    await _disposeChewieOnly();
    final mk = _mkPlayer;
    _mkPlayer = null;
    _mkController = null;
    await mk?.dispose();
    WakelockPlus.disable();
  }
}

final tvPlayerProvider =
    NotifierProvider<TVPlayerNotifier, TVPlayerData>(TVPlayerNotifier.new);
