import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';

class AppVersionChecker extends StatefulWidget {
  const AppVersionChecker({super.key});

  @override
  State<AppVersionChecker> createState() => _AppVersionCheckerState();
}

class _AppVersionCheckerState extends State<AppVersionChecker> {
  String _currentVersion = '';
  bool _checking = false;

  static const _storeUrl =
      'https://play.google.com/store/apps/details?id=com.localcode.ahenfiemedia';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _currentVersion = '${info.version} (${info.buildNumber})');
    }
  }

  Future<void> _checkForUpdate() async {
    if (_checking) return;
    setState(() => _checking = true);

    try {
      final upgrader = Upgrader();
      await upgrader.initialize();
      final available = upgrader.isUpdateAvailable() == true;
      if (!mounted) return;
      setState(() => _checking = false);
      _showResultSheet(available);
    } catch (_) {
      if (!mounted) return;
      setState(() => _checking = false);
      _showErrorSheet();
    }
  }

  void _showResultSheet(bool updateAvailable) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => updateAvailable
          ? _UpdateAvailableSheet(
              version: _currentVersion,
              onUpdate: _openStore,
            )
          : _UpToDateSheet(version: _currentVersion),
    );
  }

  void _showErrorSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ErrorSheet(),
    );
  }

  Future<void> _openStore() async {
    Navigator.of(context).pop();
    final uri = Uri.parse(_storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.info_outline_rounded,
              color: colors.textMuted, size: 22),
          title: const Text('App Version'),
          subtitle: Text(
            _currentVersion.isEmpty ? 'Loading...' : 'v$_currentVersion',
          ),
        ),
        ListTile(
          leading: _checking
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.textMuted,
                  ),
                )
              : Icon(Icons.system_update_outlined,
                  color: colors.textMuted, size: 22),
          title: Text(_checking ? 'Checking...' : 'Check for Updates'),
          onTap: _checking ? null : _checkForUpdate,
          trailing: !_checking
              ? Icon(Icons.chevron_right_rounded,
                  color: colors.textMuted, size: 20)
              : null,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Update Available Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _UpdateAvailableSheet extends StatelessWidget {
  final String version;
  final VoidCallback onUpdate;

  const _UpdateAvailableSheet({
    required this.version,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.system_update_rounded,
              color: AppColors.primaryGold,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            'Update Available!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),

          // Message
          Text(
            'A new version of Ahenfie Media is ready to install. Update now for the latest features and improvements.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          if (version.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Current: v$version',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Update button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onUpdate,
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text(
                'Update Now',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Later button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Later',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Up to Date Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _UpToDateSheet extends StatelessWidget {
  final String version;
  const _UpToDateSheet({required this.version});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'You\'re up to date!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Ahenfie Media is running the latest version.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          if (version.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'v$version',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Great!',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorSheet extends StatelessWidget {
  const _ErrorSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.error,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Check Failed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Could not check for updates. Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'OK',
                style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
