import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_constants.dart';
import '../../constants/env.dart';
import '../../core/theme/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: colors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? const [Color(0xFF1A1000), Color(0xFF0F0F0F)]
                      : const [Color(0xFFF5ECDA), Color(0xFFEDE3CE)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.headset_mic_rounded,
                        color: AppColors.primaryGold, size: 28),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    AppConstants.contactTitle,
                    style: TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppConstants.contactSubtitle,
                    style: TextStyle(color: colors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Contact details ───────────────────────────────────
            _sectionLabel(AppConstants.contactDetailsLabel, colors),
            const SizedBox(height: 12),

            _PhoneTile(
              phone: Env.studioPhone1,
              phoneE164: Env.studioPhone1E164,
              hasWhatsApp: true,
            ),
            const SizedBox(height: 8),
            _PhoneTile(
              phone: Env.studioPhone2,
              phoneE164: Env.studioPhone2E164,
            ),
            const SizedBox(height: 8),
            _ContactTile(
              icon: Icons.email_rounded,
              label: 'Email',
              value: Env.supportEmail,
              onTap: () => _copy(context, Env.supportEmail),
              trailing: Icon(Icons.copy_rounded, color: colors.textMuted, size: 16),
            ),
            const SizedBox(height: 8),
            _ContactTile(
              icon: Icons.location_on_rounded,
              label: 'Location  •  ${AppConstants.studioGpsCode}',
              value: AppConstants.studioLocation,
              onTap: () => launchUrl(
                Uri.parse(Env.mapUrl),
                mode: LaunchMode.externalApplication,
              ),
              trailing: Icon(Icons.open_in_new_rounded,
                  color: context.colors.textMuted, size: 16),
            ),
            const SizedBox(height: 8),
            _ContactTile(
              icon: Icons.radio_rounded,
              label: 'Frequency',
              value: AppConstants.studioFrequency,
              onTap: null,
            ),

            const SizedBox(height: 28),

            // ── Studio hours ──────────────────────────────────────
            _sectionLabel(AppConstants.studioHoursLabel, colors),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _HoursRow(
                      days: AppConstants.studioHours1Days,
                      hours: AppConstants.studioHours1Time),
                  Divider(color: colors.divider, height: 20),
                  _HoursRow(
                      days: AppConstants.studioHours2Days,
                      hours: AppConstants.studioHours2Time),
                  Divider(color: colors.divider, height: 20),
                  _HoursRow(
                      days: AppConstants.studioHours3Days,
                      hours: AppConstants.studioHours3Time),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Feedback ──────────────────────────────────────────
            _sectionLabel(AppConstants.feedbackLabel, colors),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                AppConstants.feedbackText,
                style: TextStyle(
                    color: colors.textSecondary, fontSize: 13, height: 1.6),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, AhenfieColors colors) => Text(
        label,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      );

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppConstants.copiedToClipboard)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Phone tile with Call + WhatsApp actions
// ─────────────────────────────────────────────────────────────────────────────
class _PhoneTile extends StatelessWidget {
  final String phone;
  final String phoneE164;
  final bool hasWhatsApp;

  const _PhoneTile({
    required this.phone,
    required this.phoneE164,
    this.hasWhatsApp = false,
  });

  Future<void> _call() async =>
      launchUrl(Uri.parse('tel:$phoneE164'), mode: LaunchMode.externalApplication);

  Future<void> _whatsapp() async =>
      launchUrl(Uri.parse('https://wa.me/$phoneE164'),
          mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_rounded,
                color: AppColors.primaryGold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phone',
                    style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(phone,
                    style: TextStyle(
                        color: colors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          // Call button
          _ActionBtn(
            icon: Icons.call_rounded,
            label: 'Call',
            onTap: _call,
          ),
          if (hasWhatsApp) ...[
            const SizedBox(width: 6),
            _ActionBtn(
              icon: Icons.chat_rounded,
              label: 'WhatsApp',
              onTap: _whatsapp,
              color: const Color(0xFF25D366),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primaryGold,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic contact tile
// ─────────────────────────────────────────────────────────────────────────────
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryGold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hours row
// ─────────────────────────────────────────────────────────────────────────────
class _HoursRow extends StatelessWidget {
  final String days;
  final String hours;

  const _HoursRow({required this.days, required this.hours});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(days,
            style: TextStyle(color: colors.textSecondary, fontSize: 13)),
        Text(hours,
            style: const TextStyle(
                color: AppColors.primaryGold,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
