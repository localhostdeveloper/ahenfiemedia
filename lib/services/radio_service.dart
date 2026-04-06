// lib/services/radio_service.dart

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../constants/app_constants.dart';

// --- 1. Custom Player State Model ---

class RadioState {
  final bool playing;
  final bool loading;
  final String title;
  final Uri? artUri;

  RadioState({
    required this.playing,
    required this.loading,
    required this.title,
    this.artUri,
  });
}

// Manages the AudioPlayer lifecycle and exposes state streams.
class RadioService {
  // Singleton Pattern: Ensures only one instance of the service exists.
  static final RadioService _instance = RadioService._internal();
  factory RadioService() => _instance;
  RadioService._internal();

  // Core player instance
  final AudioPlayer _player = AudioPlayer();

  // Stream Controller for exposing the custom state to the UI
  final _radioState = BehaviorSubject<RadioState>();

  // Public stream getter
  Stream<RadioState> get radioStateStream => _radioState.stream;

  // Stream for exposing the raw PlayerState (useful for complex UI like animations)
  Stream<PlayerState> get justAudioPlayerStateStream =>
      _player.playerStateStream;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // --- Initialization and Stream Setup ---

  Future<void> init() async {
    if (_isInitialized) return;

    // Initial state emission (loading = true)
    _radioState.add(
      RadioState(
        playing: false,
        loading: true,
        title: AppConstants.radioMetadataTitle,
        artUri: Uri.parse(AppConstants.radioLogoUrl),
      ),
    );

    // Define the MediaItem using App Constants
    final mediaItem = MediaItem(
      id: 'ahenfiefm',
      title: AppConstants.radioMetadataTitle,
      artist: AppConstants.radioMetadataArtist,
      artUri: Uri.parse(AppConstants.radioLogoUrl),
    );

    try {
      // Set the audio source
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(AppConstants.radioStreamUrl), tag: mediaItem),
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to load audio source: $e');

      _radioState.add(
        RadioState(
          playing: false,
          loading: false,
          title: AppConstants.radioMetadataTitle,
          artUri: Uri.parse(AppConstants.radioLogoUrl),
        ),
      );
      _isInitialized = false;
    }

    // Start listening to the internal player state
    _player.playerStateStream.listen((playerState) {
      final playing = playerState.playing;
      final processingState = playerState.processingState;
      final loading =
          processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering;

      // Manage Wakelock (since this logic is now centralized)
      if (playing && !loading) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }

      // Emit the new custom state
      _radioState.add(
        RadioState(
          playing: playing,
          loading: loading,
          title: AppConstants.radioMetadataTitle,
          artUri: Uri.parse(AppConstants.radioLogoUrl),
        ),
      );
    });
  }

  // --- Public Control Methods ---

  void play() {
    if (!_isInitialized) {
      return;
    }
    _player.play();
  }

  void pause() {
    _player.pause();
  }

  void stop() {
    // Used when navigating away (e.g., to the TV screen)
    _player.stop();
  }

  // Should only be called when the app is permanently closing
  void dispose() {
    _radioState.close();
    // Do NOT dispose the player here, it should be done in the application's top-level dispose.
  }
}
