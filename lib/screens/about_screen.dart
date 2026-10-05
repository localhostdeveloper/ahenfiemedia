import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_constants.dart';
import '../constants/env.dart';
import '../core/theme/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<PackageInfo> _packageInfo;

  @override
  void initState() {
    super.initState();
    _packageInfo = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text(AppConstants.aboutUsLabel),
        backgroundColor: colors.background,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Brand Hero ───────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? const [Color(0xFF1A1000), Color(0xFF0F0F0F)]
                        : const [Color(0xFFFFFFFF), Color(0xFFFBF3E2)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGold, width: 2),
                        color: AppColors.primaryGold.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        Icons.radio_rounded,
                        color: AppColors.primaryGold,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'AHENFIE MEDIA',
                      style: TextStyle(
                        color: context.colors.accentText,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.kumasiTagline,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Description ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.aboutWhoWeAreLabel,
                      style: TextStyle(
                        color: context.colors.accentText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.aboutAppDescription.trim(),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Services row ─────────────────────────────────
                    Text(
                      AppConstants.aboutWhatWeOfferLabel,
                      style: TextStyle(
                        color: context.colors.accentText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _ServiceChip(
                          icon: Icons.radio_rounded,
                          label: AppConstants.liveRadioTab,
                        ),
                        const SizedBox(width: 10),
                        _ServiceChip(icon: Icons.tv_rounded, label: AppConstants.liveTVTab),
                        const SizedBox(width: 10),
                        _ServiceChip(
                          icon: Icons.mic_rounded,
                          label: AppConstants.podcastsLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _ServiceChip(
                          icon: Icons.article_rounded,
                          label: AppConstants.newsLabel,
                        ),
                        const SizedBox(width: 10),
                        _ServiceChip(
                          icon: Icons.event_rounded,
                          label: AppConstants.eventsLabel,
                        ),
                        const SizedBox(width: 10),
                        _ServiceChip(
                          icon: Icons.play_circle_rounded,
                          label: AppConstants.videosLabel,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Social ───────────────────────────────────────
                    Text(
                      AppConstants.aboutFindOnlineLabel,
                      style: TextStyle(
                        color: context.colors.accentText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SocialBadge(
                            icon: FontAwesomeIcons.facebook,
                            color: const Color(0xFF1877F2),
                            label: AppConstants.facebookLabel,
                          ),
                          _SocialBadge(
                            icon: FontAwesomeIcons.youtube,
                            color: const Color(0xFFFF0000),
                            label: AppConstants.youtubeLabel,
                          ),
                          _SocialBadge(
                            icon: FontAwesomeIcons.tiktok,
                            color: const Color(0xFFEE1D52),
                            label: AppConstants.tiktokLabel,
                          ),
                          _SocialBadge(
                            icon: FontAwesomeIcons.instagram,
                            color: const Color(0xFFE4405F),
                            label: AppConstants.instagramLabel,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Version info ─────────────────────────────────
                    FutureBuilder<PackageInfo>(
                      future: _packageInfo,
                      builder: (context, snap) {
                        final version = snap.data?.version ?? '—';
                        final build = snap.data?.buildNumber ?? '';
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primaryGold.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            children: [
                              _InfoRow(
                                label: AppConstants.appVersionLabel,
                                value: '$version ($build)',
                              ),
                              Divider(
                                color: colors.divider,
                                height: 20,
                              ),
                              _InfoRow(
                                label: AppConstants.developerLabel,
                                value: AppConstants.appDeveloper,
                              ),
                              Divider(
                                color: colors.divider,
                                height: 20,
                              ),
                              _InfoRow(
                                label: AppConstants.contactLabel,
                                value: Env.supportEmail,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        '© 2025 ${AppConstants.appTitle}. All rights reserved.',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
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

class _ServiceChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGold, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialBadge extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final String label;

  const _SocialBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(child: FaIcon(icon, color: color, size: 18)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: colors.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: colors.textMuted, fontSize: 13),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
