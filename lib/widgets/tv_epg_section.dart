import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/program.dart';
import '../providers/epg_clock_provider.dart';
import '../providers/tv_epg_provider.dart';
import '../screens/program_details_screen.dart';

class TVEPGSection extends ConsumerWidget {
  const TVEPGSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epgAsync = ref.watch(tvEPGProvider);
    ref.watch(epgClockProvider);
    final colors = context.colors;

    return epgAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      ),
      error: (_, _) => Center(
        child: Text(
          AppConstants.tvEPGLoadError,
          style: const TextStyle(color: AppColors.error, fontSize: 13),
        ),
      ),
      data: (programs) {
        if (programs.isEmpty) {
          return Center(
            child: Text(
              AppConstants.tvEPGNoPrograms,
              style: TextStyle(color: colors.textMuted, fontSize: 13),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: programs.length,
          itemBuilder: (context, i) => _EPGRow(
            program: programs[i],
            isFirst: i == 0,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single EPG row — Netflix / broadcast guide style
// ─────────────────────────────────────────────────────────────────────────────
class _EPGRow extends StatelessWidget {
  final Program program;
  final bool isFirst;

  const _EPGRow({required this.program, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final isCurrent = program.isCurrentlyPlaying();
    final colors = context.colors;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProgramDetailsScreen(program: program),
        ),
      ),
      child: Container(
        color: isCurrent
            ? AppColors.primaryGold.withValues(alpha: 0.05)
            : Colors.transparent,
        child: IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 3,
              color: isCurrent
                  ? AppColors.primaryGold
                  : colors.textMuted.withValues(alpha: 0.12),
            ),

            // Time column
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.startTime,
                    style: TextStyle(
                      color: isCurrent
                          ? AppColors.primaryGold
                          : colors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    program.endTime,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              color: colors.divider,
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges row
                          if (isCurrent || program.isLive)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                children: [
                                  if (isCurrent)
                                    _Badge(
                                      label: AppConstants.nowLabel,
                                      bg: AppColors.primaryGold,
                                      fg: Colors.black,
                                    ),
                                  if (isCurrent && program.isLive)
                                    const SizedBox(width: 6),
                                  if (program.isLive)
                                    _Badge(
                                      label: AppConstants.liveLabel,
                                      bg: Colors.red,
                                      fg: Colors.white,
                                    ),
                                ],
                              ),
                            ),

                          // Title
                          Text(
                            program.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCurrent
                                  ? colors.textPrimary
                                  : colors.textSecondary,
                              fontSize: isCurrent ? 15 : 14,
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),

                          if (program.host.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              program.host,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],

                          if (program.category.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              program.category.toUpperCase(),
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Chevron
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.textMuted,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
