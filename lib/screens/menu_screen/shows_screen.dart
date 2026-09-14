import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';

// ── Model ──────────────────────────────────────────────────────────────────

class _Show {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? airDays;
  final String? airTime;
  final String type;

  const _Show({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.airDays,
    this.airTime,
    required this.type,
  });

  factory _Show.fromMap(Map<String, dynamic> m) => _Show(
        id: m['id'] as String,
        title: m['title'] ?? '',
        description: m['description'] as String?,
        imageUrl: m['image_url'] as String?,
        airDays: m['air_days'] as String?,
        airTime: m['air_time'] as String?,
        type: m['type'] ?? 'tv',
      );
}

// ── Provider ───────────────────────────────────────────────────────────────

final _showsProvider = FutureProvider<List<_Show>>((_) async {
  final rows = await Supabase.instance.client
      .from('shows')
      .select()
      .eq('is_active', true)
      .order('display_order');
  return (rows as List)
      .map((r) => _Show.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ── Screen ─────────────────────────────────────────────────────────────────

class ShowsScreen extends ConsumerWidget {
  const ShowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final showsAsync = ref.watch(_showsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Shows'),
        backgroundColor: colors.background,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.textMuted),
            onPressed: () => ref.invalidate(_showsProvider),
          ),
        ],
      ),
      body: showsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold)),
        error: (_, _) => _ErrorView(onRetry: () => ref.invalidate(_showsProvider)),
        data: (shows) {
          if (shows.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.live_tv_outlined, size: 52, color: colors.textMuted),
                  const SizedBox(height: 14),
                  Text('No shows available yet.',
                      style: TextStyle(color: colors.textMuted, fontSize: 14)),
                ],
              ),
            );
          }

          // Split by type
          final tvShows =
              shows.where((s) => s.type == 'tv').toList();
          final radioShows =
              shows.where((s) => s.type == 'radio').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              if (tvShows.isNotEmpty) ...[
                _SectionHeader('TV SHOWS', colors),
                ...tvShows.map((s) => _ShowCard(show: s, colors: colors)),
              ],
              if (radioShows.isNotEmpty) ...[
                _SectionHeader('RADIO SHOWS', colors),
                ...radioShows.map((s) => _ShowCard(show: s, colors: colors)),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final AhenfieColors colors;
  const _SectionHeader(this.title, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ShowCard extends StatelessWidget {
  final _Show show;
  final AhenfieColors colors;
  const _ShowCard({required this.show, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(14)),
            child: show.imageUrl != null
                ? Image.network(
                    show.imageUrl!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(colors),
                  )
                : _placeholder(colors),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          show.title,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (show.type == 'tv'
                                  ? AppColors.primaryGold
                                  : const Color(0xFF3B82F6))
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          show.type.toUpperCase(),
                          style: TextStyle(
                            color: show.type == 'tv'
                                ? AppColors.primaryGold
                                : const Color(0xFF3B82F6),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (show.description != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      show.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          height: 1.4),
                    ),
                  ],
                  if (show.airDays != null || show.airTime != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 13, color: colors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          [
                            if (show.airDays != null) show.airDays!,
                            if (show.airTime != null) show.airTime!,
                          ].join('  •  '),
                          style: TextStyle(
                              color: colors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(AhenfieColors colors) => Container(
        width: 90,
        height: 90,
        color: colors.surface,
        child: const Icon(Icons.live_tv_rounded,
            color: AppColors.primaryGold, size: 28),
      );
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: colors.textMuted, size: 48),
          const SizedBox(height: 14),
          Text('Could not load shows',
              style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
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
    );
  }
}
