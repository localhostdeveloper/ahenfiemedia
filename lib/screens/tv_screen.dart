import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/theme/app_colors.dart';

import '../providers/tv_player_provider.dart';

import '../models/program.dart';

import '../widgets/program_schedule_card.dart';

class TVScreen extends ConsumerStatefulWidget {
  final VoidCallback onEnter;

  const TVScreen({
    super.key,
    required this.onEnter,
  });

  @override
  ConsumerState<TVScreen> createState() =>
      _TVScreenState();
}

class _TVScreenState
    extends ConsumerState<TVScreen> {

  @override
  void initState() {
    super.initState();

    // STOP RADIO WHEN TV OPENS
    widget.onEnter();
  }

  @override
  Widget build(BuildContext context) {
    final tvState =
        ref.watch(tvPlayerProvider);

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
            // TV PLAYER SECTION
            // =====================================

            Container(
              margin:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color: AppColors.surface,

                borderRadius:
                    BorderRadius.circular(26),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.25),

                    blurRadius: 20,

                    offset: const Offset(
                      0,
                      10,
                    ),
                  ),
                ],
              ),

              clipBehavior: Clip.antiAlias,

              child: AspectRatio(
                aspectRatio: 16 / 9,

                child: switch (tvState.state) {

                  // =====================
                  // LOADING
                  // =====================

                  TVPlayerState.loading =>
                    Container(
                      color:
                          AppColors.surface,

                      child: const Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          CircularProgressIndicator(
                            color: AppColors
                                .primaryGold,
                          ),

                          SizedBox(height: 18),

                          Text(
                            'Loading TV Stream...',

                            style: TextStyle(
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // =====================
                  // ERROR
                  // =====================

                  TVPlayerState.error =>
                    Container(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),

                      color:
                          AppColors.surface,

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          const Icon(
                            Icons
                                .tv_off_rounded,

                            color: Colors.red,

                            size: 52,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          Text(
                            tvState.errorMessage ??
                                'Failed to load stream',

                            textAlign:
                                TextAlign.center,

                            style:
                                const TextStyle(
                              color: AppColors
                                  .textPrimary,

                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(
                                    tvPlayerProvider
                                        .notifier,
                                  )
                                  .retry();
                            },

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors
                                      .primaryGold,
                            ),

                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                color:
                                    Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // =====================
                  // PLAYER
                  // =====================

                  TVPlayerState.playing =>
                    Chewie(
                      controller:
                          tvState
                              .chewieController!,
                    ),
                },
              ),
            ),

            // =====================================
            // TV DETAILS
            // =====================================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          'Ahenfie TV',

                          style: TextStyle(
                            color: AppColors
                                .textPrimary,

                            fontSize: 24,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'Satellite Television • Live Broadcast',

                          style: TextStyle(
                            color: AppColors
                                .textSecondary,

                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.red
                          .withOpacity(0.12),

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),

                    child: const Text(
                      '● LIVE',

                      style: TextStyle(
                        color: Colors.red,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =====================================
            // EPG SECTION
            // =====================================

            Expanded(
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
                            'TV Schedule',

                            style: TextStyle(
                              color: AppColors
                                  .textPrimary,

                              fontSize: 20,

                              fontWeight:
                                  FontWeight.bold,
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
                              'EPG',

                              style: TextStyle(
                                color: AppColors
                                    .primaryGold,

                                fontWeight:
                                    FontWeight.bold,

                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // PROGRAMS
                      Expanded(
                        child:
                            StreamBuilder<
                                QuerySnapshot
                            >(
                          stream:
                              FirebaseFirestore
                                  .instance
                                  .collection(
                                    'tv_programs',
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
                                  'Failed to load TV schedule',

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
                                  'No TV programs available',

                                  style: TextStyle(
                                    color: AppColors
                                        .textSecondary,
                                  ),
                                ),
                              );
                            }

                            // LIST
                            return ListView.builder(
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