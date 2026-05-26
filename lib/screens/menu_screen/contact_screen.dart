import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_constants.dart';
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
            // Header
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
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: AppColors.primaryGold,
                      size: 28,
                    ),
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
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              AppConstants.contactDetailsLabel,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            _ContactTile(
              icon: Icons.email_rounded,
              label: 'Email',
              value: AppConstants.supportEmail,
              onTap: () => _copy(context, AppConstants.supportEmail),
            ),
            const SizedBox(height: 8),
            _ContactTile(
              icon: Icons.location_on_rounded,
              label: 'Location',
              value: AppConstants.studioLocation,
              onTap: null,
            ),
            const SizedBox(height: 8),
            _ContactTile(
              icon: Icons.radio_rounded,
              label: 'Frequency',
              value: AppConstants.studioFrequency,
              onTap: null,
            ),

            const SizedBox(height: 28),

            Text(
              AppConstants.studioHoursLabel,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                    hours: AppConstants.studioHours1Time,
                  ),
                  Divider(color: colors.divider, height: 20),
                  _HoursRow(
                    days: AppConstants.studioHours2Days,
                    hours: AppConstants.studioHours2Time,
                  ),
                  Divider(color: colors.divider, height: 20),
                  _HoursRow(
                    days: AppConstants.studioHours3Days,
                    hours: AppConstants.studioHours3Time,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              AppConstants.feedbackLabel,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                  color: colors.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppConstants.copiedToClipboard)),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
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
                  Text(
                    label,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.copy_rounded, color: colors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

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
        Text(
          days,
          style: TextStyle(color: colors.textSecondary, fontSize: 13),
        ),
        Text(
          hours,
          style: const TextStyle(
            color: AppColors.primaryGold,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
