// lib/screens/tv_screen.dart

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';

import '../services/tv_service.dart'; // Uses the new TV service

class TVScreen extends StatefulWidget {
  final VoidCallback onEnter;
  const TVScreen({super.key, required this.onEnter});

  @override
  State<TVScreen> createState() => _TVScreenState();
}

class _TVScreenState extends State<TVScreen> {
  final TVService _tvService = TVService();

  @override
  void initState() {
    super.initState();
    // 1. Stop the radio player
    widget.onEnter();

    // 2. Initialize the TV Service player
    _tvService.initializePlayer();
  }

  @override
  void dispose() {
    // 3. Dispose the TV player when the screen is exited
    _tvService.disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<TVState>(
          stream: _tvService.tvStateStream,
          builder: (context, snapshot) {
            final state = snapshot.data;

            // 1. Show Loading (uses theme progressIndicatorTheme)
            if (state == null || state.isLoading) {
              return const CircularProgressIndicator();
            }

            // 2. Show Error Message (uses theme error color)
            if (state.errorMessage != null) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            // 3. Show Player
            if (state.chewieController != null) {
              return Chewie(controller: state.chewieController!);
            }

            // Fallback
            return const Text("TV Stream initializing...");
          },
        ),
      ),
    );
  }
}
