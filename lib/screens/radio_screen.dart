import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/program.dart';
import '../providers/radio_player_provider.dart';
import '../widgets/program_schedule_card.dart';

const _kKentePattern = 'assets/images/b92f2e77-722f-4236-9b18-6d31266aa9dd 2.jpg';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class RadioScreen extends ConsumerStatefulWidget {
  const RadioScreen({super.key});

  @override
  ConsumerState<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends ConsumerState<RadioScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _disc;

  @override
  void initState() {
    super.initState();
    _disc = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _disc.dispose();
    super.dispose();
  }

  void _openSchedule() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ScheduleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(radioPlayerProvider);
    final isPlaying = playerState == RadioPlayerState.playing;
    final isLoading = playerState == RadioPlayerState.loading;

    if (isPlaying) {
      _disc.repeat();
    } else {
      _disc.stop();
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Kente pattern background ──────────────────────────
          // ShaderMask multiply: white areas → dark amber, gold lines → deeper amber
          // Result: dark screen with subtle traditional Kente texture
          ShaderMask(
            blendMode: BlendMode.multiply,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A3000), Color(0xFF2E1C00)],
            ).createShader(bounds),
            child: Image.asset(_kKentePattern, fit: BoxFit.cover),
          ),

          // Heavy dark overlay — pushes texture to near-black, keeps feel subtle
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xCC000000),
                  Color(0xE0000000),
                  Color(0xF2000000),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Warm gold bottom wash
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFFD4A843).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Reactive glow behind disc
          AnimatedOpacity(
            opacity: isPlaying ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 700),
            child: Center(
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withValues(alpha: 0.18),
                      blurRadius: 130,
                      spreadRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Foreground content ────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Station header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.radioName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Text(
                            AppConstants.radioFrequency,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      _LiveBadge(isPlaying: isPlaying),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Spinning disc
                GestureDetector(
                  onTap: () {
                    final n = ref.read(radioPlayerProvider.notifier);
                    isPlaying ? n.pause() : n.play();
                  },
                  child: _SpinningDisc(controller: _disc, isPlaying: isPlaying),
                ),

                const Spacer(flex: 1),

                // Status label
                Text(
                  switch (playerState) {
                    RadioPlayerState.loading => AppConstants.radioConnecting,
                    RadioPlayerState.playing => AppConstants.radioLiveOnAir,
                    RadioPlayerState.paused  => AppConstants.radioPaused,
                    RadioPlayerState.error   => AppConstants.radioStreamError,
                    _ => AppConstants.radioTapToPlay,
                  },
                  style: TextStyle(
                    color: switch (playerState) {
                      RadioPlayerState.playing => AppColors.primaryGold,
                      RadioPlayerState.loading => AppColors.warning,
                      RadioPlayerState.error   => AppColors.error,
                      _ => Colors.white54,
                    },
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),

                // Loading indicator
                if (isLoading) ...[
                  const SizedBox(height: 14),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.warning,
                      strokeWidth: 2,
                    ),
                  ),
                ],

                const Spacer(flex: 1),

                // Play / Pause button
                _PlayButton(
                  playerState: playerState,
                  isPlaying: isPlaying,
                  onTap: () {
                    final n = ref.read(radioPlayerProvider.notifier);
                    if (playerState == RadioPlayerState.error) {
                      n.retry();
                    } else {
                      isPlaying ? n.pause() : n.play();
                    }
                  },
                ),

                const Spacer(flex: 2),

                // Schedule pill
                GestureDetector(
                  onTap: _openSchedule,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 28),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: AppColors.primaryGold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primaryGold,
                          size: 15,
                        ),
                        SizedBox(width: 10),
                        Text(
                          AppConstants.programScheduleLabel,
                          style: TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.keyboard_arrow_up_rounded,
                          color: AppColors.primaryGold,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spinning disc
// ─────────────────────────────────────────────────────────────────────────────
class _SpinningDisc extends StatelessWidget {
  final AnimationController controller;
  final bool isPlaying;

  const _SpinningDisc({required this.controller, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) => Transform.rotate(
        angle: controller.value * 2 * math.pi,
        child: child,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryGold.withValues(
              alpha: isPlaying ? 0.9 : 0.3,
            ),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(
                alpha: isPlaying ? 0.35 : 0.06,
              ),
              blurRadius: isPlaying ? 60 : 16,
              spreadRadius: isPlaying ? 8 : 0,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(AppConstants.radioLogoUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Play / Pause button
// ─────────────────────────────────────────────────────────────────────────────
class _PlayButton extends StatelessWidget {
  final RadioPlayerState playerState;
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayButton({
    required this.playerState,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isPlaying)
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGold,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(
                    alpha: isPlaying ? 0.5 : 0.2,
                  ),
                  blurRadius: isPlaying ? 36 : 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(child: _icon()),
          ),
        ],
      ),
    );
  }

  Widget _icon() {
    if (playerState == RadioPlayerState.loading) {
      return const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 2.5,
        ),
      );
    }
    if (playerState == RadioPlayerState.error) {
      return const Icon(Icons.refresh_rounded, color: Colors.black, size: 32);
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Icon(
        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        key: ValueKey(isPlaying),
        color: Colors.black,
        size: 36,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live badge
// ─────────────────────────────────────────────────────────────────────────────
class _LiveBadge extends StatefulWidget {
  final bool isPlaying;
  const _LiveBadge({required this.isPlaying});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isPlaying) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_LiveBadge old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isPlaying && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: const Text(
          AppConstants.radioOffAir,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryGold
              .withValues(alpha: 0.15 + _pulse.value * 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryGold
                .withValues(alpha: 0.4 + _pulse.value * 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.primaryGold
                    .withValues(alpha: 0.7 + _pulse.value * 0.3),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              AppConstants.radioLiveBadge,
              style: TextStyle(
                color: AppColors.primaryGold,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Program Schedule bottom sheet (draggable)
// ─────────────────────────────────────────────────────────────────────────────
class _ScheduleSheet extends StatelessWidget {
  const _ScheduleSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.textMuted.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppConstants.scheduleSheetTitle,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            AppConstants.scheduleSheetBadge,
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Divider(color: colors.divider, height: 20),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('programs')
                      .orderBy('time')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          AppConstants.scheduleLoadError,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGold,
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          AppConstants.noScheduleAvailable,
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (_, i) => ProgramScheduleCard(
                        program: Program.fromFirestore(docs[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
