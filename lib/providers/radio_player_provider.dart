// lib/providers/radio_player_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:http/http.dart' as http; // For API calls
import 'dart:convert'; // For JSON parsing
import '../constants/app_constants.dart';

enum RadioPlayerState { stopped, playing, paused, loading, error }

// Your existing RadioPlayerNotifier (unchanged)
class RadioPlayerNotifier extends Notifier<RadioPlayerState> {
  late final AudioPlayer _player;
  final String _streamUrl = AppConstants.radioStreamUrl;

  String? _currentErrorMessage;

  AudioPlayer get player => _player;
  String? get errorMessage => _currentErrorMessage;

  Null get metadata => null;

  @override
  RadioPlayerState build() {
    _player = AudioPlayer();

    // Configure audio player with better streaming settings
    _player.setLoopMode(LoopMode.off);
    _player.setVolume(1.0);

    _initPlayer();
    return RadioPlayerState.stopped;
  }

  void _initPlayer() {
    _player.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      final playing = playerState.playing;

     // print("Player State: $playerState");
      //print("Processing: $processingState");
     // print("Playing: $playing");

      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        state = RadioPlayerState.loading;
        _currentErrorMessage = null;
      } else if (processingState == ProcessingState.ready) {
        if (playing) {
          state = RadioPlayerState.playing;
        } else {
          state = RadioPlayerState.paused;
        }
        _currentErrorMessage = null;
      } else if (processingState == ProcessingState.idle) {
        state = RadioPlayerState.stopped;
        _currentErrorMessage = null;
      } else if (processingState == ProcessingState.completed) {
        state = RadioPlayerState.stopped;
        _currentErrorMessage = null;
      }
    });

    _player.playbackEventStream.listen(
      (event) {
      //  print("Playback Event: ${event.processingState}");
      },
      onError: (error) {
       // print("Playback Error: $error");
        _currentErrorMessage = error.toString();
        state = RadioPlayerState.error;
      },
    );
  }

  Future<void> play() async {
    if (state == RadioPlayerState.playing) return;

   // print("Attempting to play from URL: $_streamUrl");
    state = RadioPlayerState.loading;
    _currentErrorMessage = null;

    try {
      // Stop any existing playback first
      await _player.stop();

      // Create MediaItem for background playback
      final mediaItem = MediaItem(
        id: 'ahenfie_radio_stream',
        album: AppConstants.radioName,
        title: AppConstants.radioMetadataTitle,
        artist: AppConstants.radioMetadataArtist,
        artUri: Uri.parse(AppConstants.radioLogoUrl),
        genre: 'Radio',
        duration: null, // Live stream has no fixed duration
      );

      // Configure the player for streaming
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(_streamUrl), tag: mediaItem),
      );

      // Start playback with error handling
      await _player.play();

     // print("Playback started successfully");
    } catch (e, stackTrace) {
      //print("Play error: $e");
      print("Stack trace: $stackTrace");
      _currentErrorMessage = e.toString();
      state = RadioPlayerState.error;

      // Attempt fallback: try without just_audio_background initially
      await _tryFallbackStream();
    }
  }

  Future<void> _tryFallbackStream() async {
    try {
     // print("Attempting fallback stream approach...");

      // Create a simple MediaItem for fallback
      final mediaItem = MediaItem(
        id: 'ahenfie_fallback',
        album: 'Ahenfie FM',
        title: 'Live Radio',
        artist: 'Ahenfie FM',
        artUri: Uri.parse('assets/images/noti.png')
      );

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(_streamUrl),
          tag: mediaItem,
          headers: {'User-Agent': 'AhenfieMedia/1.0', 'Icy-MetaData': '1'},
        ),
      );

      await _player.play();
      state = RadioPlayerState.playing;
      _currentErrorMessage = null;
     // print("Fallback approach succeeded!");
    } catch (e) {
     // print("Fallback approach failed: $e");
      // Try with minimal MediaItem
      await _tryMinimalStream();
    }
  }

  Future<void> _tryMinimalStream() async {
    try {
     // print("Attempting minimal stream configuration...");

      // Create minimal MediaItem
      final mediaItem = MediaItem(id: 'radio_stream', title: 'Ahenfie FM');

      await _player.stop();
      await Future.delayed(Duration(milliseconds: 500));

      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(_streamUrl), tag: mediaItem),
      );

      await _player.play();
      state = RadioPlayerState.playing;
      _currentErrorMessage = null;
     // print("Minimal configuration succeeded!");
    } catch (e) {
     // print("All playback attempts failed: $e");
      _currentErrorMessage =
          "Cannot connect to radio stream. Please try again later.";
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      state = RadioPlayerState.paused;
    } catch (e) {
      _currentErrorMessage = e.toString();
      state = RadioPlayerState.error;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      state = RadioPlayerState.stopped;
    } catch (e) {
      _currentErrorMessage = e.toString();
      state = RadioPlayerState.error;
    }
  }

  Future<void> retry() async {
 //   print("Retrying connection...");
    await play();
  }

  void setVolume(double volume) {
    _player.setVolume(volume.clamp(0.0, 1.0));
  }

  void dispose() {
    _player.dispose();
  }

  void togglePlayPause() {}
}

final radioPlayerProvider =
    NotifierProvider<RadioPlayerNotifier, RadioPlayerState>(
      RadioPlayerNotifier.new,
    );

// Provider for error messages
final radioPlayerErrorMessageProvider = Provider<String?>((ref) {
  return ref.watch(radioPlayerProvider.notifier).errorMessage;
});

// Provider for volume control
final radioVolumeProvider = StateProvider<double>((ref) => 1.0);

// NEW: Now Playing from API
class NowPlayingNotifier extends Notifier<NowPlayingData> {
  Timer? _timer;
  final String _apiUrl = AppConstants.radioNowPlayingApiUrl;

  @override
  NowPlayingData build() {
    _startPolling();
    return NowPlayingData.empty(); // Initial empty state
  }

  void _startPolling() {
    _timer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _fetchNowPlaying(),
    );
    _fetchNowPlaying(); // Fetch immediately
  }

  Future<void> _fetchNowPlaying() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final nowPlaying = json['now_playing'];
        final live = json['live'];
        final listeners = json['listeners']['current'] ?? 0;

        final artist = nowPlaying?['song']?['artist']?.toString() ?? '';
        final title = nowPlaying?['song']?['title']?.toString() ?? '';
        final displayTitle = title.isNotEmpty && artist.isNotEmpty
            ? '$artist - $title'
            : title.isNotEmpty
            ? title
            : 'Ahenfie FM • Live';

        state = NowPlayingData(
          title: displayTitle,
          isLive: live?['is_live'] ?? false,
          listeners: listeners,
          albumArt: nowPlaying?['song']?['art']?.toString(),
          elapsed: nowPlaying?['elapsed'] ?? 0,
          remaining: nowPlaying?['remaining'] ?? 0,
        );
      } else {
        state = NowPlayingData.error('API unavailable');
      }
    } catch (e) {
    //  print('API fetch error: $e');
      state = NowPlayingData.error('Connection issue');
    }
  }

  void dispose() {
    _timer?.cancel();
    //super.dispose();
  }
}

class NowPlayingData {
  final String title;
  final bool isLive;
  final int listeners;
  final String? albumArt;
  final int elapsed;
  final int remaining;
  final String? error;

  NowPlayingData({
    required this.title,
    this.isLive = false,
    this.listeners = 0,
    this.albumArt,
    this.elapsed = 0,
    this.remaining = 0,
    this.error,
  });

  factory NowPlayingData.empty() => NowPlayingData(title: 'Ahenfie FM');
  factory NowPlayingData.error(String error) =>
      NowPlayingData(title: 'Ahenfie FM', error: error);
}

final nowPlayingProvider = NotifierProvider<NowPlayingNotifier, NowPlayingData>(
  NowPlayingNotifier.new,
);
