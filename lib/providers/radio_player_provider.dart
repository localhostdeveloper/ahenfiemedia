// lib/providers/radio_player_provider.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../constants/env.dart';

enum RadioPlayerState { stopped, playing, paused, loading, error }

// just_audio_background's notification artwork only supports file:// and
// content:// URIs — anything else gets fetched as a network URL, which
// fails (and can crash) for a bundled asset path. Copy the asset to a real
// file once and reuse that file:// URI.
Future<Uri?> _notificationArtUri(String assetPath, String fileName) async {
  try {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    if (!await file.exists()) {
      final bytes = await rootBundle.load(assetPath);
      await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
    }
    return Uri.file(file.path);
  } catch (_) {
    return null;
  }
}

class RadioPlayerNotifier extends Notifier<RadioPlayerState> {
  late final AudioPlayer _player;
  final String _streamUrl = Env.radioStreamUrl;

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
      (event) {},
      onError: (error) {
        _currentErrorMessage = error.toString();
        state = RadioPlayerState.error;
      },
    );
  }

  Future<void> play() async {
    if (state == RadioPlayerState.playing) return;

    state = RadioPlayerState.loading;
    _currentErrorMessage = null;

    try {
      await _player.stop();

      final artUri = await _notificationArtUri(
        'assets/images/ahenfiefm.png',
        'ahenfiefm_art.png',
      );
      final mediaItem = MediaItem(
        id: 'ahenfie_radio_stream',
        album: AppConstants.radioName,
        title: AppConstants.radioMetadataTitle,
        artist: AppConstants.radioMetadataArtist,
        artUri: artUri,
        genre: 'Radio',
        duration: null,
      );

      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(_streamUrl), tag: mediaItem),
      );

      await _player.play();
    } catch (e, stackTrace) {
      debugPrint('Stack trace: $stackTrace');
      _currentErrorMessage = e.toString();
      state = RadioPlayerState.error;

      await _tryFallbackStream();
    }
  }

  Future<void> _tryFallbackStream() async {
    try {
      final artUri = await _notificationArtUri(
        'assets/images/noti.png',
        'noti_art.png',
      );
      final mediaItem = MediaItem(
        id: 'ahenfie_fallback',
        album: 'Ahenfie FM',
        title: 'Live Radio',
        artist: 'Ahenfie FM',
        artUri: artUri,
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
    } catch (e) {
      await _tryMinimalStream();
    }
  }

  Future<void> _tryMinimalStream() async {
    try {
      final mediaItem = MediaItem(id: 'radio_stream', title: 'Ahenfie FM');

      await _player.stop();
      await Future.delayed(Duration(milliseconds: 500));

      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(_streamUrl), tag: mediaItem),
      );

      await _player.play();
      state = RadioPlayerState.playing;
      _currentErrorMessage = null;
    } catch (e) {
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

// Now Playing from API
class NowPlayingNotifier extends Notifier<NowPlayingData> {
  Timer? _timer;
  final String _apiUrl = Env.radioNowPlayingUrl;

  @override
  NowPlayingData build() {
    _startPolling();
    return NowPlayingData.empty();
  }

  void _startPolling() {
    _timer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _fetchNowPlaying(),
    );
    _fetchNowPlaying();
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
      state = NowPlayingData.error('Connection issue');
    }
  }

  void dispose() {
    _timer?.cancel();
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
