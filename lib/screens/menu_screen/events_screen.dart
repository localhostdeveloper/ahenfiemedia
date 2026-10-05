import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/app_network_image.dart';

// ── Model ──────────────────────────────────────────────────────────────────

class _Event {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final DateTime? eventDate;
  final String? imageUrl;

  const _Event({
    required this.id,
    required this.title,
    this.description,
    this.location,
    this.eventDate,
    this.imageUrl,
  });

  factory _Event.fromMap(Map<String, dynamic> m) => _Event(
        id: m['id'] as String,
        title: m['title'] ?? '',
        description: m['description'] as String?,
        location: m['location'] as String?,
        eventDate: m['event_date'] != null
            ? DateTime.tryParse(m['event_date'] as String)
            : null,
        imageUrl: m['image_url'] as String?,
      );

  bool get isUpcoming =>
      eventDate == null || eventDate!.isAfter(DateTime.now());
}

// ── Provider ───────────────────────────────────────────────────────────────

final _eventsProvider = FutureProvider<List<_Event>>((_) async {
  final rows = await Supabase.instance.client
      .from('events')
      .select()
      .eq('is_published', true)
      .order('event_date');
  return (rows as List)
      .map((r) => _Event.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ── Screen ─────────────────────────────────────────────────────────────────

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final eventsAsync = ref.watch(_eventsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: colors.background,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.textMuted),
            onPressed: () => ref.invalidate(_eventsProvider),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: eventsAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold)),
          error: (_, _) =>
              _ErrorView(onRetry: () => ref.invalidate(_eventsProvider)),
          data: (events) {
            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_outlined,
                        size: 52, color: colors.textMuted),
                    const SizedBox(height: 14),
                    Text('No events yet.',
                        style:
                            TextStyle(color: colors.textMuted, fontSize: 14)),
                  ],
                ),
              );
            }

            final upcoming =
                events.where((e) => e.isUpcoming).toList();
            final past =
                events.where((e) => !e.isUpcoming).toList();

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                if (upcoming.isNotEmpty) ...[
                  _SectionHeader('UPCOMING', colors),
                  ...upcoming.map(
                      (e) => _EventCard(event: e, colors: colors)),
                ],
                if (past.isNotEmpty) ...[
                  _SectionHeader('PAST EVENTS', colors),
                  ...past.map((e) => _EventCard(event: e, colors: colors)),
                ],
              ],
            );
          },
        ),
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
  Widget build(BuildContext context) => Padding(
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

class _EventCard extends StatelessWidget {
  final _Event event;
  final AhenfieColors colors;
  const _EventCard({required this.event, required this.colors});

  @override
  Widget build(BuildContext context) {
    final dateFmt = event.eventDate != null
        ? DateFormat('EEE, MMM d · h:mm a').format(event.eventDate!.toLocal())
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: event.isUpcoming
              ? AppColors.primaryGold.withValues(alpha: 0.3)
              : colors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (event.imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: AppNetworkImage(
                url: event.imageUrl!,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                error: const SizedBox.shrink(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upcoming badge
                if (event.isUpcoming)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'UPCOMING',
                        style: TextStyle(
                          color: context.colors.accentText,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                Text(
                  event.title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),

                if (dateFmt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 13,
                          color: AppColors.primaryGold),
                      const SizedBox(width: 6),
                      Text(
                        dateFmt,
                        style: TextStyle(
                          color: context.colors.accentText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                if (event.location != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 13, color: colors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: TextStyle(
                              color: colors.textMuted, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],

                if (event.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.description!,
                    style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                        height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: colors.textMuted, size: 48),
          const SizedBox(height: 14),
          Text('Could not load events',
              style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.primaryGold),
            label: Text('Retry',
                style: TextStyle(
                    color: context.colors.accentText,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
