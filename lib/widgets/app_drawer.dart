import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/app_constants.dart';
import '../core/theme/app_colors.dart';

class _DrawerItem {
  final IconData icon;
  final String label;

  const _DrawerItem(this.icon, this.label);
}

const _tabItems = <int, _DrawerItem>{
  0: _DrawerItem(Icons.home_rounded, AppConstants.homeLabel),
  1: _DrawerItem(Icons.radio_rounded, AppConstants.liveRadioTab),
  2: _DrawerItem(Icons.tv_rounded, AppConstants.liveTVTab),
  3: _DrawerItem(Icons.person_rounded, AppConstants.profileLabel),
};

const _pushLabels = [
  AppConstants.presentersLabel,
  AppConstants.podcastsLabel,
  AppConstants.videosLabel,
  AppConstants.newsLabel,
  AppConstants.showsLabel,
  AppConstants.eventsLabel,
  AppConstants.galleryLabel,
  AppConstants.aboutUsLabel,
  AppConstants.contactLabel,
];

const _pushIcons = <IconData>[
  Icons.people_rounded,
  Icons.mic_rounded,
  Icons.play_circle_rounded,
  Icons.article_rounded,
  Icons.live_tv_rounded,
  Icons.event_rounded,
  Icons.photo_library_rounded,
  Icons.info_rounded,
  Icons.phone_rounded,
];


class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelect;
  final ValueChanged<String> onPushSelect;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onTabSelect,
    required this.onPushSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Drawer(
      backgroundColor: colors.drawerBg,
      width: 270,
      child: Column(
        children: [
          // ── Brand Header ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            decoration: BoxDecoration(
              color: colors.drawerHeader,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGold,
                      width: 2,
                    ),
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryGold.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.radio_rounded,
                    color: AppColors.primaryGold,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'AHENFIE\nMEDIA',
                  style: TextStyle(
                    color: context.colors.accentText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.kumasiTagline,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ── Nav Items ────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Tab-linked items
                ..._tabItems.entries.map(
                  (e) => _NavTile(
                    icon: e.value.icon,
                    label: e.value.label,
                    selected: currentIndex == e.key,
                    onTap: () {
                      Navigator.of(context).pop();
                      onTabSelect(e.key);
                    },
                  ),
                ),

                _Divider(),

                // ── Social Media ─────────────────────────────
                _SectionLabel(AppConstants.socialMediaSectionLabel),
                _FaNavTile(
                  icon: FontAwesomeIcons.youtube,
                  color: const Color(0xFFFF0000),
                  label: AppConstants.youtubeLabel,
                  onTap: () {
                    Navigator.of(context).pop();
                    onPushSelect(AppConstants.youtubeLabel);
                  },
                ),
                _FaNavTile(
                  icon: FontAwesomeIcons.facebook,
                  color: const Color(0xFF1877F2),
                  label: AppConstants.facebookLabel,
                  onTap: () {
                    Navigator.of(context).pop();
                    onPushSelect(AppConstants.facebookLabel);
                  },
                ),
                _FaNavTile(
                  icon: FontAwesomeIcons.tiktok,
                  color: const Color(0xFFEE1D52),
                  label: AppConstants.tiktokLabel,
                  onTap: () {
                    Navigator.of(context).pop();
                    onPushSelect(AppConstants.tiktokLabel);
                  },
                ),
                _FaNavTile(
                  icon: FontAwesomeIcons.instagram,
                  color: const Color(0xFFE4405F),
                  label: AppConstants.instagramLabel,
                  onTap: () {
                    Navigator.of(context).pop();
                    onPushSelect(AppConstants.instagramLabel);
                  },
                ),

                _Divider(),

                // Push-navigation items
                ..._pushLabels.asMap().entries.map(
                  (e) => _NavTile(
                    icon: _pushIcons[e.key],
                    label: e.value,
                    selected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      onPushSelect(e.value);
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Kumasi footer ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, 16, 20, 16 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colors.divider),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.kumasiLabel,
                  style: TextStyle(
                    color: context.colors.accentText,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.footerSlogan,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _SocialIcon(
                      icon: FontAwesomeIcons.youtube,
                      color: const Color(0xFFFF0000),
                      onTap: () {
                        Navigator.of(context).pop();
                        onPushSelect(AppConstants.youtubeLabel);
                      },
                    ),
                    const SizedBox(width: 12),
                    _SocialIcon(
                      icon: FontAwesomeIcons.facebook,
                      color: const Color(0xFF1877F2),
                      onTap: () {
                        Navigator.of(context).pop();
                        onPushSelect(AppConstants.facebookLabel);
                      },
                    ),
                    const SizedBox(width: 12),
                    _SocialIcon(
                      icon: FontAwesomeIcons.tiktok,
                      color: const Color(0xFFEE1D52),
                      onTap: () {
                        Navigator.of(context).pop();
                        onPushSelect(AppConstants.tiktokLabel);
                      },
                    ),
                    const SizedBox(width: 12),
                    _SocialIcon(
                      icon: FontAwesomeIcons.instagram,
                      color: const Color(0xFFE4405F),
                      onTap: () {
                        Navigator.of(context).pop();
                        onPushSelect(AppConstants.instagramLabel);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Divider(
        color: AppColors.primaryGold.withValues(alpha: 0.15),
        height: 1,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 20, 4),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.textMuted,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGold.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primaryGold : colors.textSecondary,
            ),
            const SizedBox(width: 14),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: selected
                    ? context.colors.accentText
                    : colors.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
            if (selected) ...[
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGold,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaNavTile extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _FaNavTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: FaIcon(icon, size: 13, color: color),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final FaIconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(icon, color: color, size: 14),
        ),
      ),
    );
  }
}
