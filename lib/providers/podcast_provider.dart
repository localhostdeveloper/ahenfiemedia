import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../constants/app_constants.dart';
import '../models/podcast_episode.dart';
import '../services/podcast_service.dart';

// ── Episodes ──────────────────────────────────────────────────────────────────

final podcastEpisodesProvider = FutureProvider<List<PodcastEpisode>>(
  (_) => PodcastService.fetchEpisodes(),
);

// ── Player state ──────────────────────────────────────────────────────────────

enum PodcastPlayerStatus { stopped, loading, playing, paused, error }

class PodcastPlayerState {
  final PodcastEpisode? episode;
  final PodcastPlayerStatus status;
  final String? error;

  const PodcastPlayerState({
    this.episode,
    this.status = PodcastPlayerStatus.stopped,
    this.error,
  });

  PodcastPlayerState copyWith({
    PodcastEpisode? episode,
    PodcastPlayerStatus? status,
    String? error,
    bool clearEpisode = false,
  }) =>
      PodcastPlayerState(
        episode: clearEpisode ? null : episode ?? this.episode,
        status: status ?? this.status,
        error: error,
      );

  bool get isActive =>
      episode != null && status != PodcastPlayerStatus.stopped;
}

// ── Player notifier ───────────────────────────────────────────────────────────

class PodcastPlayerNotifier extends Notifier<PodcastPlayerState> {
  late final AudioPlayer _player;

  AudioPlayer get player => _player;

  @override
  PodcastPlayerState build() {
    _player = AudioPlayer();
    _player.playerStateStream.listen(_onPlayerState);
    _player.playbackEventStream.listen(
      (_) {},
      onError: (e) {
        state = state.copyWith(
          status: PodcastPlayerStatus.error,
          error: e.toString(),
        );
      },
    );
    ref.onDispose(_player.dispose);
    return const PodcastPlayerState();
  }

  void _onPlayerState(PlayerState ps) {
    switch (ps.processingState) {
      case ProcessingState.loading:
      case ProcessingState.buffering:
        state = state.copyWith(status: PodcastPlayerStatus.loading);
      case ProcessingState.ready:
        state = state.copyWith(
          status: ps.playing
              ? PodcastPlayerStatus.playing
              : PodcastPlayerStatus.paused,
        );
      case ProcessingState.completed:
      case ProcessingState.idle:
        state = state.copyWith(status: PodcastPlayerStatus.stopped);
    }
  }

  Future<void> playEpisode(PodcastEpisode episode) async {
    state = PodcastPlayerState(
      episode: episode,
      status: PodcastPlayerStatus.loading,
    );
    try {
      await _player.stop();
      final mediaItem = MediaItem(
        id: episode.guid,
        title: episode.title,
        album: AppConstants.podcastShowTitle,
        artist: AppConstants.podcastHost,
        duration: episode.duration,
        artUri: Uri.parse('assets:///assets/images/ahenfiefm.png'),
      );
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(episode.audioUrl), tag: mediaItem),
      );
      await _player.play();
    } catch (e) {
      state = state.copyWith(
        status: PodcastPlayerStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> pause() async => _player.pause();

  Future<void> resume() async => _player.play();

  Future<void> stop() async {
    await _player.stop();
    state = const PodcastPlayerState();
  }

  Future<void> seekTo(Duration position) async => _player.seek(position);

  bool isCurrentEpisode(String guid) => state.episode?.guid == guid;
}

final podcastPlayerProvider =
    NotifierProvider<PodcastPlayerNotifier, PodcastPlayerState>(
  PodcastPlayerNotifier.new,
);

// Scoped stream providers — rebuild only the mini-player, not the full list
final podcastPositionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(podcastPlayerProvider.notifier).player.positionStream;
});

final podcastDurationProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(podcastPlayerProvider.notifier).player.durationStream;
});
