import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import 'about_screen.dart';
import 'menu_screen/contact_screen.dart';
import 'menu_screen/notifications_screen.dart';
import 'menu_screen/privacy_policy_screen.dart';
import 'menu_screen/settings_screen.dart';

const _kKentePattern =
    'assets/images/b92f2e77-722f-4236-9b18-6d31266aa9dd 2.jpg';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Kente hero ──────────────────────────────────
            SizedBox(
              height: 220,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ShaderMask(
                    blendMode: BlendMode.multiply,
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF5A3800), Color(0xFF2E1C00)],
                    ).createShader(bounds),
                    child: Image.asset(_kKentePattern, fit: BoxFit.cover),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x44000000), Color(0xDD000000)],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGold,
                              width: 2.5,
                            ),
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primaryGold.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AppConstants.radioLogoUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          AppConstants.fullStationName,
                          style: TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          AppConstants.kumasiTagline,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 9,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── App ─────────────────────────────────────────
            _SectionLabel(AppConstants.profileAppSection),
            _ProfileTile(
              icon: Icons.notifications_rounded,
              label: AppConstants.notificationsLabel,
              onTap: () => _push(context, const NotificationsScreen()),
            ),
            _ProfileTile(
              icon: Icons.settings_rounded,
              label: AppConstants.settingsLabel,
              onTap: () => _push(context, const SettingsScreen()),
            ),

            const SizedBox(height: 8),

            // ── Info ────────────────────────────────────────
            _SectionLabel(AppConstants.profileInfoSection),
            _ProfileTile(
              icon: Icons.info_rounded,
              label: AppConstants.aboutUsLabel,
              onTap: () => _push(context, const AboutScreen()),
            ),
            _ProfileTile(
              icon: Icons.phone_rounded,
              label: AppConstants.contactLabel,
              onTap: () => _push(context, const ContactScreen()),
            ),
            _ProfileTile(
              icon: Icons.lock_rounded,
              label: AppConstants.privacyPolicyLabel,
              onTap: () => _push(context, const PrivacyPolicyScreen()),
            ),

            const SizedBox(height: 32),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.divider),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryGold, size: 18),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
