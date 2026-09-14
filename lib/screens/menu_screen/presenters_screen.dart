import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../models/presenter.dart';
import '../../providers/presenter_provider.dart';
import 'presenter_detail_screen.dart';

class PresentersScreen extends ConsumerWidget {
  const PresentersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final presentersAsync = ref.watch(presentersProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Presenters'),
        backgroundColor: colors.background,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.textMuted),
            onPressed: () => ref.invalidate(presentersProvider),
          ),
        ],
      ),
      body: presentersAsync.when(
        loading: () => const _LoadingGrid(),
        error: (_, _) => _ErrorView(
          onRetry: () => ref.invalidate(presentersProvider),
        ),
        data: (presenters) => presenters.isEmpty
            ? const _EmptyView()
            : _PresenterGrid(presenters: presenters),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Presenter grid
// ─────────────────────────────────────────────────────────────────────────────
class _PresenterGrid extends StatelessWidget {
  final List<Presenter> presenters;

  const _PresenterGrid({required this.presenters});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: presenters.length,
      itemBuilder: (_, i) => _PresenterCard(presenter: presenters[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Presenter card
// ─────────────────────────────────────────────────────────────────────────────
class _PresenterCard extends StatelessWidget {
  final Presenter presenter;

  const _PresenterCard({required this.presenter});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PresenterDetailScreen(presenter: presenter),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Photo ─────────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: presenter.imageUrl != null
                    ? Image.network(
                        presenter.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) =>
                            progress == null
                                ? child
                                : _PhotoShimmer(),
                        errorBuilder: (_, _, _) => _PhotoPlaceholder(),
                      )
                    : _PhotoPlaceholder(),
              ),
            ),

            // ── Info ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    presenter.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    presenter.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  if (presenter.programs.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.live_tv_rounded,
                            size: 11, color: AppColors.primaryGold),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            presenter.programs
                                .map((p) => p.name)
                                .join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.primaryGold.withValues(alpha: 0.06),
        child: const Center(
          child: Icon(Icons.person_rounded,
              color: AppColors.primaryGold, size: 48),
        ),
      );
}

class _PhotoShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        color: context.colors.divider,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading shimmer grid
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(color: colors.divider),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(4),
                      )),
                  const SizedBox(height: 6),
                  Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(4),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty + Error
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline_rounded,
                color: colors.textMuted, size: 56),
            const SizedBox(height: 16),
            Text('No presenters yet',
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Presenter profiles will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: colors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text('Could not load presenters',
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primaryGold),
              label: const Text('Retry',
                  style: TextStyle(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
