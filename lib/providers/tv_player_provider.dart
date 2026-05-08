import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../constants/app_constants.dart';
import '../core/theme/app_colors.dart';

enum TVPlayerState {
  loading,
  playing,
  error,
}

class TVPlayerData {
  final TVPlayerState state;

  final ChewieController? chewieController;

  final String? errorMessage;

  const TVPlayerData({
    required this.state,
    this.chewieController,
    this.errorMessage,
  });

  TVPlayerData copyWith({
    TVPlayerState? state,
    ChewieController? chewieController,
    String? errorMessage,
  }) {
    return TVPlayerData(
      state: state ?? this.state,
      chewieController:
          chewieController ??
          this.chewieController,
      errorMessage:
          errorMessage ??
          this.errorMessage,
    );
  }
}

class TVPlayerNotifier
    extends Notifier<TVPlayerData> {

  VideoPlayerController? _videoController;

  ChewieController? _chewieController;

  @override
  TVPlayerData build() {
    _initializePlayer();

    ref.onDispose(() {
      _disposePlayer();
    });

    return const TVPlayerData(
      state: TVPlayerState.loading,
    );
  }

  Future<void> _initializePlayer() async {
    try {
      // =====================
      // VIDEO PLAYER
      // =====================

      _videoController =
          VideoPlayerController.networkUrl(
        Uri.parse(
          AppConstants.tvStreamUrl,
        ),
      );

      await _videoController!.initialize();

      // =====================
      // CHEWIE
      // =====================

      _chewieController = ChewieController(
        videoPlayerController:
            _videoController!,

        autoPlay: true,

        looping: true,

        allowFullScreen: true,

        allowMuting: true,

        allowPlaybackSpeedChanging: false,

        showControls: true,

        fullScreenByDefault: false,

        autoInitialize: true,

        materialProgressColors:
            ChewieProgressColors(
          playedColor:
              AppColors.primaryGold,

          handleColor:
              AppColors.primaryGold,

          backgroundColor:
              AppColors.accentBrown,

          bufferedColor:
              AppColors.primaryGold
                  .withOpacity(0.35),
        ),
      );

      // =====================
      // SUCCESS
      // =====================

      state = state.copyWith(
        state: TVPlayerState.playing,

        chewieController:
            _chewieController,

        errorMessage: null,
      );
    } catch (e) {

      // =====================
      // ERROR
      // =====================

      state = state.copyWith(
        state: TVPlayerState.error,

        errorMessage:
            'Failed to load TV stream.',
      );
    }
  }

  Future<void> retry() async {
    state = state.copyWith(
      state: TVPlayerState.loading,
      errorMessage: null,
    );

    await _disposePlayer();

    await _initializePlayer();
  }

  Future<void> _disposePlayer() async {

    _chewieController?.dispose();

    await _videoController?.dispose();

    _chewieController = null;

    _videoController = null;
  }
}

final tvPlayerProvider =
    NotifierProvider<
      TVPlayerNotifier,
      TVPlayerData
    >(
      TVPlayerNotifier.new,
    );