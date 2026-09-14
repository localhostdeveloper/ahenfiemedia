import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';

// ── Model ──────────────────────────────────────────────────────────────────

class _GalleryItem {
  final String id;
  final String? title;
  final String imageUrl;
  final String? category;

  const _GalleryItem({
    required this.id,
    this.title,
    required this.imageUrl,
    this.category,
  });

  factory _GalleryItem.fromMap(Map<String, dynamic> m) => _GalleryItem(
        id: m['id'] as String,
        title: m['title'] as String?,
        imageUrl: m['image_url'] ?? '',
        category: m['category'] as String?,
      );
}

// ── Provider ───────────────────────────────────────────────────────────────

final _galleryProvider = FutureProvider<List<_GalleryItem>>((_) async {
  final rows = await Supabase.instance.client
      .from('gallery')
      .select()
      .order('display_order');
  return (rows as List)
      .map((r) => _GalleryItem.fromMap(r as Map<String, dynamic>))
      .toList();
});

// ── Screen ─────────────────────────────────────────────────────────────────

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final galleryAsync = ref.watch(_galleryProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Gallery'),
        backgroundColor: colors.background,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.textMuted),
            onPressed: () => ref.invalidate(_galleryProvider),
          ),
        ],
      ),
      body: galleryAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGold)),
        error: (_, _) =>
            _ErrorView(onRetry: () => ref.invalidate(_galleryProvider)),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_outlined,
                      size: 52, color: colors.textMuted),
                  const SizedBox(height: 14),
                  Text('No photos yet.',
                      style:
                          TextStyle(color: colors.textMuted, fontSize: 14)),
                ],
              ),
            );
          }

          // Build category filter chips
          final categories = items
              .map((i) => i.category)
              .whereType<String>()
              .toSet()
              .toList()
            ..sort();

          final filtered = _selectedCategory == null
              ? items
              : items
                  .where((i) => i.category == _selectedCategory)
                  .toList();

          return Column(
            children: [
              // Category filter
              if (categories.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _selectedCategory == null,
                        colors: colors,
                        onTap: () =>
                            setState(() => _selectedCategory = null),
                      ),
                      ...categories.map((cat) => _FilterChip(
                            label: cat,
                            selected: _selectedCategory == cat,
                            colors: colors,
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                          )),
                    ],
                  ),
                ),

              // Photo grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _PhotoTile(
                    item: filtered[i],
                    colors: colors,
                    onTap: () => _openPhoto(context, filtered, i),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openPhoto(
      BuildContext context, List<_GalleryItem> items, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PhotoViewScreen(items: items, initialIndex: index),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final AhenfieColors colors;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryGold
                : colors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primaryGold
                  : colors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : colors.textSecondary,
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
}

class _PhotoTile extends StatelessWidget {
  final _GalleryItem item;
  final AhenfieColors colors;
  final VoidCallback onTap;

  const _PhotoTile(
      {required this.item, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: colors.surface,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.primaryGold, size: 32),
              ),
            ),
            if (item.title != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                  child: Text(
                    item.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────────────────────
// Full-screen photo viewer with swipe
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoViewScreen extends StatefulWidget {
  final List<_GalleryItem> items;
  final int initialIndex;

  const _PhotoViewScreen(
      {required this.items, required this.initialIndex});

  @override
  State<_PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<_PhotoViewScreen> {
  late final PageController _pageCtrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_current];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: item.title != null ? Text(item.title!) : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_current + 1} / ${widget.items.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageCtrl,
        itemCount: widget.items.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              widget.items[i].imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 48),
            ),
          ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: colors.textMuted, size: 48),
          const SizedBox(height: 14),
          Text('Could not load gallery',
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
