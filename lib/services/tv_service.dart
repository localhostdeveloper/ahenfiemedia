// lib/services/tv_service.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:rxdart/rxdart.dart';
import '../constants/app_constants.dart';

// --- 1. Custom TV State Model ---
class TVState {
  final ChewieController? chewieController;
  final bool isLoading;
  final String? errorMessage;

  TVState({
    required this.chewieController,
    required this.isLoading,
    this.errorMessage,
  });
}

// --- 2. TV Service (Singleton) ---
class TVService {
  // Singleton Pattern
  static final TVService _instance = TVService._internal();
  factory TVService() => _instance;
  TVService._internal();

  // Core controllers
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  // Stream Controller for exposing the custom state to the UI
  final _tvState = BehaviorSubject<TVState>();
  Stream<TVState> get tvStateStream => _tvState.stream;

  // --- Initialization and Stream Setup ---

  Future<void> initializePlayer() async {
    // 1. Emit loading state
    _tvState.add(TVState(chewieController: null, isLoading: true));

    // Ensure wakelock is enabled when player starts loading
    WakelockPlus.enable();

    // Handle potential previous instances
    if (_videoController != null) {
      await disposePlayer();
    }

    try {
      // Initialize Video Controller
      // ignore: deprecated_member_use
      _videoController = VideoPlayerController.network(
        AppConstants.tvStreamUrl,
      );

      await _videoController!.initialize();

      // Initialize Chewie Controller
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        allowMuting: true,
        showControls: true,
        fullScreenByDefault: false,
        autoInitialize: true,
      );

      // 2. Emit success state
      _tvState.add(
        TVState(chewieController: _chewieController, isLoading: false),
      );
    } catch (e) {
      debugPrint('Failed to initialize TV player in service: $e');

      // 3. Emit error state
      _tvState.add(
        TVState(
          chewieController: null,
          isLoading: false,
          errorMessage:
              'Failed to load TV stream. Please check your internet connection or try again later.',
        ),
      );
    }
  }

  // --- Disposal Method ---
  Future<void> disposePlayer() async {
    WakelockPlus.disable();
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;

    // Reset stream state to initial/disposed state
    _tvState.add(TVState(chewieController: null, isLoading: false));
  }

  // Should be called when the app closes permanently
  void disposeService() {
    disposePlayer();
    _tvState.close();
  }
}
