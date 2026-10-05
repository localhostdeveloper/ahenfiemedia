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
  static const _maxReconnects = 5;
  static const _reconnectDelays = [2, 4, 8, 8, 8]; // seconds, per attempt
  static const _stallTimeout = Duration(seconds: 20);

  late final AudioPlayer _player;
  final String _streamUrl = Env.radioStreamUrl;

  String? _currentErrorMessage;

  // True while the listener wants audio: set by play()/resume (in-app, lock
  // screen, or after a phone call), cleared by any pause/stop. Reconnects
  // only happen while this is true, so a paused radio never restarts itself.
  bool _wantsToPlay = false;
  bool _wasPlaying = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _stallTimer;

  // Incremented on every play/pause/stop — stale async work checks against it
  int _generation = 0;

  AudioPlayer get player => _player;
  String? get errorMessage => _currentErrorMessage;

  @override
  RadioPlayerState build() {
    _player = AudioPlayer();

    // Configure audio player with better streaming settings
    _player.setLoopMode(LoopMode.off);
    _player.setVolume(1.0);

    ref.onDispose(() {
      _cancelTimers();
      _player.dispose();
    });

    _initPlayer();
    return RadioPlayerState.stopped;
  }

  void _initPlayer() {
    _player.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      final playing = playerState.playing;

      // Pause/resume that bypassed this notifier (lock-screen controls,
      // audio-focus loss during a call) still reflects the user's intent.
      // (playing only flips to false via pause/stop — errors leave it true)
      if (_wasPlaying &&
          !playing &&
          (processingState == ProcessingState.ready ||
              processingState == ProcessingState.idle)) {
        _wantsToPlay = false;
        _cancelTimers();
      } else if (!_wasPlaying && playing) {
        _wantsToPlay = true;
      }
      _wasPlaying = playing;

      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        state = RadioPlayerState.loading;
        _currentErrorMessage = null;
        if (_wantsToPlay) _startStallTimer();
      } else if (processingState == ProcessingState.ready) {
        _stallTimer?.cancel();
        if (playing) {
          state = RadioPlayerState.playing;
          _reconnectAttempts = 0;
        } else {
          state = RadioPlayerState.paused;
        }
        _currentErrorMessage = null;
      } else if (processingState == ProcessingState.completed) {
        // A live stream never ends on its own — the server dropped us.
        if (_wantsToPlay) {
          _scheduleReconnect();
        } else {
          state = RadioPlayerState.stopped;
        }
      } else if (processingState == ProcessingState.idle) {
        // While reconnecting, keep showing "connecting" rather than stopped
        if (!_wantsToPlay) {
          state = RadioPlayerState.stopped;
          _currentErrorMessage = null;
        }
      }
    });

    _player.playbackEventStream.listen(
      (event) {},
      onError: (error) {
        if (_wantsToPlay) {
          _scheduleReconnect();
        } else {
          _currentErrorMessage = error.toString();
          state = RadioPlayerState.error;
        }
      },
    );
  }

  Future<void> play() async {
    if (state == RadioPlayerState.playing) return;

    _cancelTimers();
    _wantsToPlay = true;
    _reconnectAttempts = 0;
    _currentErrorMessage = null;
    state = RadioPlayerState.loading;
    await _connect(++_generation);
  }

  Future<void> _connect(int gen) async {
    try {
      final artUri = await _notificationArtUri(
        'assets/images/ahenfiefm.png',
        'ahenfiefm_art.png',
      );
      if (gen != _generation) return;

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
        AudioSource.uri(
          Uri.parse(_streamUrl),
          tag: mediaItem,
          headers: {'User-Agent': 'AhenfieMedia/1.0', 'Icy-MetaData': '1'},
        ),
      );
      if (gen != _generation) return;

      // play()'s future only completes when playback stops, so don't await it
      unawaited(_player.play().catchError((Object _) {}));
    } catch (e) {
      debugPrint('Radio connect failed: $e');
      if (gen != _generation) return;
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_wantsToPlay) return;
    // Errors often arrive twice (thrown + on the event stream) — retry once
    if (_reconnectTimer?.isActive ?? false) return;
    _stallTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnects) {
      _wantsToPlay = false;
      _reconnectAttempts = 0;
      _currentErrorMessage =
          'Cannot connect to radio stream. Please check your connection and try again.';
      state = RadioPlayerState.error;
      return;
    }

    final delay = Duration(seconds: _reconnectDelays[_reconnectAttempts]);
    _reconnectAttempts++;
    state = RadioPlayerState.loading;

    final gen = ++_generation;
    _reconnectTimer = Timer(delay, () {
      if (gen != _generation || !_wantsToPlay) return;
      _connect(gen);
    });
  }

  // Buffering that never recovers (dead connection with no error raised)
  void _startStallTimer() {
    if (_stallTimer?.isActive ?? false) return;
    _stallTimer = Timer(_stallTimeout, () {
      final ps = _player.processingState;
      if (_wantsToPlay &&
          (ps == ProcessingState.loading || ps == ProcessingState.buffering)) {
        _scheduleReconnect();
      }
    });
  }

  void _cancelTimers() {
    _reconnectTimer?.cancel();
    _stallTimer?.cancel();
  }

  Future<void> pause() async {
    _wantsToPlay = false;
    _generation++;
    _cancelTimers();
    try {
      await _player.pause();
      state = RadioPlayerState.paused;
    } catch (e) {
      _currentErrorMessage = e.toString();
      state = RadioPlayerState.error;
    }
  }

  Future<void> stop() async {
    _wantsToPlay = false;
    _generation++;
    _cancelTimers();
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
