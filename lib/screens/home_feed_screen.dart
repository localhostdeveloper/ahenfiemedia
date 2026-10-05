import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../providers/radio_player_provider.dart';

const _kKentePattern = 'assets/images/b92f2e77-722f-4236-9b18-6d31266aa9dd 2.jpg';

class HomeFeedScreen extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  final ValueChanged<String> onPushSelect;

  const HomeFeedScreen({
    super.key,
    required this.onNavigate,
    required this.onPushSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nowPlaying = ref.watch(nowPlayingProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero ───────────────────────────────────────────────
        SliverToBoxAdapter(child: _HeroSection()),

        // ── Live cards ─────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: _LiveCard(
                    icon: Icons.radio_rounded,
                    label: AppConstants.liveRadioLabel,
                    title: AppConstants.radioName,
                    subtitle: nowPlaying.title.isEmpty
                        ? AppConstants.nowOnAirSubtitle
                        : nowPlaying.title,
                    cta: AppConstants.viewScheduleCTA,
                    onTap: () => onNavigate(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LiveCard(
                    icon: Icons.tv_rounded,
                    label: AppConstants.liveTVLabel,
                    title: AppConstants.tvName,
                    subtitle: AppConstants.watchLiveBroadcast,
                    cta: AppConstants.viewTVScheduleCTA,
                    onTap: () => onNavigate(2),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // ── Follow Us ──────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _SocialSection(onPushSelect: onPushSelect),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // ── Listen anywhere banner ─────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _ListenBanner(onTap: () => onNavigate(1)),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      margin: const EdgeInsets.only(bottom: 20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Kente pattern — multiply-darkened to near-black with amber tint
          ShaderMask(
            blendMode: BlendMode.multiply,
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5C3A00), Color(0xFF2E1C00)],
            ).createShader(bounds),
            child: Image.asset(_kKentePattern, fit: BoxFit.cover),
          ),

          // Dark overlay — left-to-right so text is legible
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0x99000000), Color(0xDD000000)],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LIVE badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        AppConstants.radioLiveBadge,
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Station name headline
                const Text(
                  AppConstants.appNamePart1,
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    height: 1,
                  ),
                ),
                const Text(
                  AppConstants.appNamePart2,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  AppConstants.appTagServices,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  AppConstants.appTagline,
                  style: TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Live card (Radio / TV)
// ─────────────────────────────────────────────────────────────────────────────
class _LiveCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  const _LiveCard({
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon + LIVE badge
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      AppConstants.radioLiveBadge,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Icon area
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: AppColors.primaryGold,
                  size: 34,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Station name + subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // CTA row
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: colors.divider),
                ),
              ),
              child: TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cta,
                      style: TextStyle(
                        color: context.colors.accentText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primaryGold,
                      size: 11,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Follow Us — one tappable tile per platform
// ─────────────────────────────────────────────────────────────────────────────
class _SocialSection extends StatelessWidget {
  final ValueChanged<String> onPushSelect;

  const _SocialSection({required this.onPushSelect});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.followUsLabel,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppConstants.followUsSubtitle,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => onPushSelect(AppConstants.socialMediaLabel),
              child: Text(
                AppConstants.viewAllLabel,
                style: TextStyle(
                  color: context.colors.accentText,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              _SocialTile(
                icon: FontAwesomeIcons.youtube,
                label: AppConstants.youtubeLabel,
                color: const Color(0xFFFF0000),
                onTap: () => onPushSelect(AppConstants.youtubeLabel),
              ),
              _SocialTile(
                icon: FontAwesomeIcons.facebookF,
                label: AppConstants.facebookLabel,
                color: const Color(0xFF1877F2),
                onTap: () => onPushSelect(AppConstants.facebookLabel),
              ),
              _SocialTile(
                icon: FontAwesomeIcons.instagram,
                label: AppConstants.instagramLabel,
                color: const Color(0xFFE4405F),
                onTap: () => onPushSelect(AppConstants.instagramLabel),
              ),
              // TikTok's mark is black/white, so follow the theme's text colour
              _SocialTile(
                icon: FontAwesomeIcons.tiktok,
                label: AppConstants.tiktokLabel,
                color: colors.textPrimary,
                onTap: () => onPushSelect(AppConstants.tiktokLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialTile extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: FaIcon(icon, color: color, size: 20)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Listen anywhere banner
// ─────────────────────────────────────────────────────────────────────────────
class _ListenBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _ListenBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1A1000), Color(0xFF0F0F0F)]
              : const [Color(0xFFFFFFFF), Color(0xFFFBF3E2)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.listenAnytimeLabel,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppConstants.listenSubtitle,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.headphones_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          AppConstants.listenLiveCTA,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Decorative radio icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
                width: 2,
              ),
              color: AppColors.primaryGold.withValues(alpha: 0.08),
            ),
            child: const Icon(
              Icons.radio_rounded,
              color: AppColors.primaryGold,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}
