// lib/providers/tv_player_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:video_player/video_player.dart';

import 'package:chewie/chewie.dart';

import '../constants/app_constants.dart';

import '../core/theme/app_colors.dart';

import '../services/network_service.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

enum TVPlayerState {
  loading,
  playing,
  error,
}

class TVPlayerData {

  final TVPlayerState state;

  final ChewieController?
      chewieController;

  final String? errorMessage;

  const TVPlayerData({
    required this.state,
    this.chewieController,
    this.errorMessage,
  });

  TVPlayerData copyWith({
    TVPlayerState? state,
    ChewieController?
        chewieController,
    String? errorMessage,
  }) {

    return TVPlayerData(
      state:
          state ?? this.state,

      chewieController:
          chewieController ??
          this.chewieController,

      errorMessage:
          errorMessage,
    );
  }
}

class TVPlayerNotifier
    extends Notifier<TVPlayerData> {

  VideoPlayerController?
      _videoController;

  ChewieController?
      _chewieController;

  bool _isInitializing = false;

  @override
  TVPlayerData build() {

    _initializePlayer();

    ref.onDispose(() {
      _disposePlayer();
    });

    return const TVPlayerData(
      state:
          TVPlayerState.loading,
    );
  }

  Future<void>
      _initializePlayer() async {

    if (_isInitializing) {
      return;
    }

    _isInitializing = true;

    try {

      final hasInternet =
          await NetworkService
              .hasInternet();

      if (!hasInternet) {

        state = state.copyWith(
          state:
              TVPlayerState.error,

          errorMessage:
              'No internet connection.',
        );

        await WakelockPlus.disable();

        _isInitializing = false;

        return;
      }

      await _disposePlayer();

      _videoController =
          VideoPlayerController
              .networkUrl(

        Uri.parse(
          AppConstants
              .tvStreamUrl,
        ),

        httpHeaders: const {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept': '*/*',
          'Connection': 'keep-alive',
        },

        videoPlayerOptions:
            VideoPlayerOptions(
          mixWithOthers: false,
        ),
      );

      await _videoController!
          .initialize();

      _chewieController =
          ChewieController(

        videoPlayerController:
            _videoController!,

        autoPlay: true,

        looping: true,

        allowFullScreen: true,

        allowMuting: true,

        allowPlaybackSpeedChanging:
            false,

        showControls: true,

        fullScreenByDefault:
            false,

        autoInitialize: true,

        materialProgressColors:
            ChewieProgressColors(

          playedColor:
              AppColors
                  .primaryGold,

          handleColor:
              AppColors
                  .primaryGold,

          backgroundColor:
              AppColors
                  .accentBrown,

          bufferedColor:
              AppColors
                  .primaryGold
                  .withValues(alpha: 0.35),
        ),
      );

      state = state.copyWith(
        state:
            TVPlayerState.playing,

        chewieController:
            _chewieController,

        errorMessage: null,
      );

      await WakelockPlus.enable();

    } catch (_) {

      state = state.copyWith(
        state:
            TVPlayerState.error,

        errorMessage:
            'Unable to load TV stream.',
      );

      await WakelockPlus.disable();

    } finally {

      _isInitializing = false;
    }
  }

  Future<void> retry() async {

    state = state.copyWith(
      state:
          TVPlayerState.loading,

      errorMessage: null,
    );

    await _initializePlayer();
  }

  Future<void> pause() async {
    await _videoController?.pause();
    await WakelockPlus.disable();
  }

  Future<void> resume() async {
    if (_videoController != null) {
      await _videoController!.play();
      await WakelockPlus.enable();
    } else if (!_isInitializing) {
      state = const TVPlayerData(state: TVPlayerState.loading);
      await _initializePlayer();
    }
  }

  // =========================
  // DESTROY PLAYER (on logout/exit PIP)
  // =========================

  Future<void> destroy() async {

    await _disposePlayer();

    state = const TVPlayerData(
      state: TVPlayerState.loading,
    );
  }

  Future<void>
      _disposePlayer() async {

    final chewie =
        _chewieController;

    final video =
        _videoController;

    _chewieController = null;

    _videoController = null;

    chewie?.dispose();

    await video?.dispose();

    await WakelockPlus.disable();
  }
}

final tvPlayerProvider =
    NotifierProvider<
      TVPlayerNotifier,
      TVPlayerData
    >(
      TVPlayerNotifier.new,
    );