import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/presenter.dart';
import '../../widgets/app_network_image.dart';

class PresenterDetailScreen extends StatelessWidget {
  final Presenter presenter;

  const PresenterDetailScreen({super.key, required this.presenter});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            // ── Photo header ─────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: colors.background,
              flexibleSpace: FlexibleSpaceBar(
                background: presenter.imageUrl != null
                    ? AppNetworkImage(
                        url: presenter.imageUrl!,
                        fit: BoxFit.cover,
                        error: _PlaceholderPhoto(),
                      )
                    : _PlaceholderPhoto(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Name + title ────────────────────────────────
                    Text(
                      presenter.name,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.primaryGold.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        presenter.title,
                        style: TextStyle(
                          color: context.colors.accentText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // ── Bio ─────────────────────────────────────────
                    if (presenter.bio.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'About',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        presenter.bio,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 14,
                          height: 1.65,
                        ),
                      ),
                    ],

                    // ── Programs ────────────────────────────────────
                    if (presenter.programs.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text(
                        'PROGRAMS',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...presenter.programs.map(
                        (p) => _ProgramCard(program: p),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryGold.withValues(alpha: 0.08),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.primaryGold,
          size: 80,
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final PresenterProgram program;

  const _ProgramCard({required this.program});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isTV = program.type == 'tv';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isTV ? Icons.tv_rounded : Icons.radio_rounded,
              color: AppColors.primaryGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program.name,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${program.days}  •  ${program.time}',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isTV ? 'TV' : 'RADIO',
              style: TextStyle(
                color: context.colors.accentText,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
