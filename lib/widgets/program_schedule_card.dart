// lib/widgets/program_schedule_card.dart

import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/program.dart';
import '../screens/program_details_screen.dart';

class ProgramScheduleCard extends StatelessWidget {
  final Program program;

  const ProgramScheduleCard({
    super.key,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isCurrent = program.isCurrentlyPlaying();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProgramDetailsScreen(program: program),
          ),
        );
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ACTIVE BACKGROUND
          color: isCurrent
              ? AppColors.primaryGold.withValues(alpha: 0.10)
              : colors.card,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: isCurrent
                ? AppColors.primaryGold
                : AppColors.primaryGold.withValues(alpha: 0.08),
            width: isCurrent ? 2 : 1,
          ),

          // GLOW EFFECT
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TIME COLUMN
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primaryGold
                    : AppColors.primaryGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.startTime,
                    style: TextStyle(
                      color: isCurrent ? Colors.black : context.colors.accentText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    program.endTime,
                    style: TextStyle(
                      color: isCurrent ? Colors.black87 : colors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    program.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // HOST
                  Text(
                    program.host,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BADGES
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // CATEGORY
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.accentBrown
                              : colors.cardBorder,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          program.category,
                          style: const TextStyle(
                            color: AppColors.softGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // LIVE
                      if (program.isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            AppConstants.liveLabel,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // NOW AIRING
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            AppConstants.nowAiringLabel,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ARROW
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isCurrent ? AppColors.primaryGold : colors.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
