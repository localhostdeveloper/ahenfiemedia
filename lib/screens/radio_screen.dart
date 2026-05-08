// lib/screens/radio_screen.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marquee/marquee.dart';

import '../core/theme/app_colors.dart';
import '../models/program.dart';
import '../providers/radio_player_provider.dart';
import '../widgets/program_schedule_card.dart';

class RadioScreen extends ConsumerStatefulWidget {
  const RadioScreen({super.key});

  @override
  ConsumerState<RadioScreen> createState() =>
      _RadioScreenState();
}

class _RadioScreenState
    extends ConsumerState<RadioScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nowPlaying =
        ref.watch(nowPlayingProvider);

    final playerState =
        ref.watch(radioPlayerProvider);

    // ROTATION CONTROL
    if (playerState ==
        RadioPlayerState.playing) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: 0,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // =====================================
            // TOP PLAYER SECTION
            // =====================================

            Expanded(
              flex: 3,

              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),

                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

                  child: Column(
                    children: [
                      const SizedBox(height: 26),

                      // =====================================
                      // SPINNING RADIO LOGO
                      // =====================================

                      GestureDetector(
                        onTap: () {
                          final notifier =
                              ref.read(
                            radioPlayerProvider
                                .notifier,
                          );

                          playerState ==
                                  RadioPlayerState
                                      .playing
                              ? notifier.pause()
                              : notifier.play();
                        },

                        child: AnimatedBuilder(
                          animation:
                              _rotationController,

                          builder:
                              (context, child) {
                            return Transform.rotate(
                              angle:
                                  _rotationController
                                          .value *
                                      2 *
                                      math.pi,

                              child: child,
                            );
                          },

                          child: AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds: 350,
                            ),

                            width: 110,
                            height: 110,

                            padding:
                                const EdgeInsets.all(
                              8,
                            ),

                            decoration:
                                BoxDecoration(
                              shape:
                                  BoxShape.circle,

                              color:
                                  AppColors.surface,

                              border: Border.all(
                                color: AppColors
                                    .primaryGold
                                    .withOpacity(
                                  playerState ==
                                          RadioPlayerState
                                              .playing
                                      ? 0.9
                                      : 0.35,
                                ),

                                width: 3,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: AppColors
                                      .primaryGold
                                      .withOpacity(
                                    playerState ==
                                            RadioPlayerState
                                                .playing
                                        ? 0.35
                                        : 0.12,
                                  ),

                                  blurRadius:
                                      playerState ==
                                              RadioPlayerState
                                                  .playing
                                          ? 50
                                          : 20,

                                  spreadRadius: 4,
                                ),
                              ],
                            ),

                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/ahenfiefm.png',

                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // =====================================
                      // PLAYER STATUS
                      // =====================================

                      Text(
                        switch (playerState) {
                          RadioPlayerState.loading =>
                            'CONNECTING TO STREAM...',

                          RadioPlayerState.playing =>
                            '● LIVE ON AIR',

                          RadioPlayerState.paused =>
                            'PAUSED',

                          RadioPlayerState.error =>
                            'STREAM ERROR',

                          _ =>
                            'TAP TO PLAY',
                        },

                        style: TextStyle(
                          color:
                              switch (playerState) {
                            RadioPlayerState
                                    .playing =>
                              AppColors
                                  .primaryGold,

                            RadioPlayerState
                                    .loading =>
                              Colors.orange,

                            RadioPlayerState
                                    .error =>
                              Colors.red,

                            _ =>
                              AppColors.textMuted,
                          },

                          fontWeight:
                              FontWeight.w700,

                          letterSpacing: 1.3,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // =====================================
                      // NOW PLAYING MARQUEE
                      // =====================================

                      SizedBox(
                        height: 24,

                        child: Marquee(
                          text: nowPlaying.error !=
                                  null
                              ? 'No internet connection • Trying to reconnect...'
                              : nowPlaying.title
                                      .isEmpty
                                  ? 'Ahenfie FM Live Broadcast'
                                  : nowPlaying.title,

                          style: const TextStyle(
                            color: AppColors
                                .textPrimary,

                            fontSize: 15,

                            fontWeight:
                                FontWeight.w600,
                          ),

                          blankSpace: 40,

                          velocity: 30,

                          pauseAfterRound:
                              const Duration(
                            seconds: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // =====================================
            // PROGRAM SCHEDULE SECTION
            // =====================================

            Expanded(
              flex: 4,

              child: Container(
                width: double.infinity,

                decoration:
                    const BoxDecoration(
                  color: AppColors.surface,

                  borderRadius:
                      BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),

                child: Padding(
                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [
                          const Text(
                            'Program Schedule',

                            style: TextStyle(
                              color: AppColors
                                  .textPrimary,

                              fontSize: 20,

                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),

                            decoration:
                                BoxDecoration(
                              color: AppColors
                                  .primaryGold
                                  .withOpacity(
                                0.10,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),

                            child: const Text(
                              'Daily',

                              style: TextStyle(
                                color: AppColors
                                    .primaryGold,

                                fontWeight:
                                    FontWeight
                                        .bold,

                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // =====================================
                      // PROGRAM LIST
                      // =====================================

                      Expanded(
                        child:
                            StreamBuilder<
                                QuerySnapshot
                            >(
                          stream:
                              FirebaseFirestore
                                  .instance
                                  .collection(
                                    'programs',
                                  )
                                  .orderBy(
                                    'time',
                                  )
                                  .snapshots(),

                          builder: (
                            context,
                            snapshot,
                          ) {
                            // ERROR
                            if (snapshot
                                .hasError) {
                              return const Center(
                                child: Text(
                                  'Failed to load programs',

                                  style: TextStyle(
                                    color:
                                        AppColors
                                            .error,
                                  ),
                                ),
                              );
                            }

                            // LOADING
                            if (snapshot
                                    .connectionState ==
                                ConnectionState
                                    .waiting) {
                              return const Center(
                                child:
                                    CircularProgressIndicator(
                                  color: AppColors
                                      .primaryGold,
                                ),
                              );
                            }

                            final docs =
                                snapshot.data
                                        ?.docs ??
                                    [];

                            // EMPTY
                            if (docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No programs available',

                                  style: TextStyle(
                                    color: AppColors
                                        .textSecondary,
                                  ),
                                ),
                              );
                            }

                            // PROGRAM LIST
                            return ListView
                                .builder(
                              physics:
                                  const BouncingScrollPhysics(),

                              itemCount:
                                  docs.length,

                              itemBuilder:
                                  (
                                    context,
                                    index,
                                  ) {
                                final program =
                                    Program.fromFirestore(
                                  docs[index],
                                );

                                return ProgramScheduleCard(
                                  program:
                                      program,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}