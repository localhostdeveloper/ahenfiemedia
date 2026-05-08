import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProgramDetailsScreen(
              program: program,
            ),
          ),
        );
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        margin: const EdgeInsets.only(bottom: 16),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.card,
              AppColors.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          borderRadius: BorderRadius.circular(28),

          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.08),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          children: [
            // TIME
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color: AppColors.primaryGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),

              child: Text(
                program.time,
                style: const TextStyle(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(width: 18),

            // CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          program.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (program.isLive)
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    program.host,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    program.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ARROW
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}