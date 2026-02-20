// lib/widgets/radio_player_ui.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../providers/radio_player_provider.dart';

class RadioPlayerUI extends ConsumerStatefulWidget {
  const RadioPlayerUI({super.key});

  @override
  ConsumerState<RadioPlayerUI> createState() => _RadioPlayerUIState();
}

class _RadioPlayerUIState extends ConsumerState<RadioPlayerUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRotationAnimation();
  }

  void _updateRotationAnimation() {
    final playerState = ref.read(radioPlayerProvider);
    if (playerState == RadioPlayerState.playing) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    final playerState = ref.watch(radioPlayerProvider);
    final notifier = ref.read(radioPlayerProvider.notifier);
    final errorMessage = ref.watch(radioPlayerProvider.notifier).errorMessage;

    final nowPlaying = ref.watch(nowPlayingProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRotationAnimation();
    });

    void onPlayPauseTapped() {
      if (playerState == RadioPlayerState.playing) {
        notifier.pause();
      } else {
        notifier.play();
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: constraints.maxHeight),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 54.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Essential for fit
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: topPadding > 0 ? 0 : 85),

                  // Spinning Logo with Animation
                  RotationTransition(
                    turns: Tween(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(_rotationController),
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF96810E),
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          AppConstants.radioLogoUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.radio,
                              size: 100,
                              color: Color.fromARGB(255, 145, 5, 5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  Text(
                    AppConstants.radioName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF96810E),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    AppConstants.radioMetadataArtist,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),
                  // Current Song/Metadata Container
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          playerState == RadioPlayerState.loading
                              ? "Connecting..."
                              : nowPlaying.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nowPlaying.isLive
                              ? "● LIVE • ${nowPlaying.listeners} listener${nowPlaying.listeners != 1 ? 's' : ''}"
                              : "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (errorMessage != null && errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Error: ${errorMessage.split('\n').first}",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        if (nowPlaying.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              "API Error: ${nowPlaying.error}",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  GestureDetector(
                    onTap: onPlayPauseTapped,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF96810E),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(child: _buildPlayerIcon(playerState)),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _getStatusText(playerState),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: playerState == RadioPlayerState.error
                          ? Colors.red[700]
                          : const Color(0xFF96810E),
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  if (playerState == RadioPlayerState.error)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ElevatedButton.icon(
                        onPressed: () => notifier.retry(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Connection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerIcon(RadioPlayerState state) {
    switch (state) {
      case RadioPlayerState.loading:
        return const SizedBox(
          width: 50, // Slightly smaller than button
          height: 50,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 5),
        );
      case RadioPlayerState.error:
        return const Icon(Icons.error_outline, size: 55, color: Colors.white);
      default:
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            state == RadioPlayerState.playing ? Icons.pause : Icons.play_arrow,
            key: ValueKey(state),

            size: 50,
            color: Colors.white,
          ),
        );
    }
  }

  String _getStatusText(RadioPlayerState state) {
    switch (state) {
      case RadioPlayerState.loading:
        return "Connecting to stream...";
      case RadioPlayerState.error:
        return "Connection failed • Tap to retry";
      case RadioPlayerState.playing:
        return "● LIVE • On Air";
      case RadioPlayerState.paused:
        return "Paused • Tap to resume";
      default:
        return "Tap to play live radio";
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
}
