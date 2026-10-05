import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/app_network_image.dart';

// ── Model ──────────────────────────────────────────────────────────────────

class _NewsArticle {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String author;
  final DateTime? publishedAt;

  const _NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.author,
    this.publishedAt,
  });

  factory _NewsArticle.fromMap(Map<String, dynamic> m) => _NewsArticle(
        id: m['id'] as String,
        title: m['title'] ?? '',
        content: m['content'] ?? '',
        imageUrl: m['image_url'] as String?,
        author: m['author'] ?? '',
        publishedAt: m['published_at'] != null
            ? DateTime.tryParse(m['published_at'] as String)
            : null,
      );
}

// ── Provider ───────────────────────────────────────────────────────────────

final _newsProvider = FutureProvider<List<_NewsArticle>>((_) async {
  final rows = await Supabase.instance.client
      .from('news')
      .select()
      .eq('is_published', true)
      .order('published_at', ascending: false)
      .limit(50);
  return (rows as List)
      .map((r) => _NewsArticle.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ── Screen ─────────────────────────────────────────────────────────────────

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final newsAsync = ref.watch(_newsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('News'),
        backgroundColor: colors.background,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.textMuted),
            onPressed: () => ref.invalidate(_newsProvider),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: newsAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGold)),
          error: (_, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, color: colors.textMuted, size: 48),
                const SizedBox(height: 14),
                Text('Could not load news',
                    style: TextStyle(color: colors.textMuted)),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => ref.invalidate(_newsProvider),
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.primaryGold),
                  label: Text('Retry',
                      style: TextStyle(color: context.colors.accentText)),
                ),
              ],
            ),
          ),
          data: (articles) {
            if (articles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.article_outlined,
                        size: 52, color: colors.textMuted),
                    const SizedBox(height: 14),
                    Text('No news available yet.',
                        style: TextStyle(color: colors.textMuted, fontSize: 14)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: articles.length,
              itemBuilder: (_, i) => _ArticleCard(
                article: articles[i],
                colors: colors,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final _NewsArticle article;
  final AhenfieColors colors;

  const _ArticleCard({required this.article, required this.colors});

  @override
  Widget build(BuildContext context) {
    final fmt = article.publishedAt != null
        ? DateFormat('MMM d, y').format(article.publishedAt!.toLocal())
        : null;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _NewsDetailScreen(article: article, colors: colors),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: AppNetworkImage(
                  url: article.imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  error: const SizedBox.shrink(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  if (article.content.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      article.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (article.author.isNotEmpty) ...[
                        Icon(Icons.person_outline_rounded,
                            size: 13, color: colors.textMuted),
                        const SizedBox(width: 4),
                        Text(article.author,
                            style: TextStyle(
                                color: colors.textMuted, fontSize: 12)),
                      ],
                      if (article.author.isNotEmpty && fmt != null)
                        Text('  •  ',
                            style: TextStyle(
                                color: colors.textMuted, fontSize: 12)),
                      if (fmt != null)
                        Text(fmt,
                            style: TextStyle(
                                color: colors.textMuted, fontSize: 12)),
                      const Spacer(),
                      Text('Read more',
                          style: TextStyle(
                              color: context.colors.accentText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.primaryGold, size: 16),
                    ],
                  ),
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
class _NewsDetailScreen extends StatelessWidget {
  final _NewsArticle article;
  final AhenfieColors colors;

  const _NewsDetailScreen(
      {required this.article, required this.colors});

  @override
  Widget build(BuildContext context) {
    final fmt = article.publishedAt != null
        ? DateFormat('MMMM d, y').format(article.publishedAt!.toLocal())
        : null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(backgroundColor: colors.background),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl != null)
                AppNetworkImage(
                  url: article.imageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  error: const SizedBox.shrink(),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (article.author.isNotEmpty) ...[
                          Icon(Icons.person_outline_rounded,
                              size: 14, color: colors.textMuted),
                          const SizedBox(width: 4),
                          Text(article.author,
                              style: TextStyle(
                                  color: colors.textMuted, fontSize: 13)),
                        ],
                        if (article.author.isNotEmpty && fmt != null)
                          Text('  •  ',
                              style: TextStyle(
                                  color: colors.textMuted, fontSize: 13)),
                        if (fmt != null)
                          Text(fmt,
                              style: TextStyle(
                                  color: colors.textMuted, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Divider(color: colors.divider),
                    const SizedBox(height: 8),
                    Text(
                      article.content,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
