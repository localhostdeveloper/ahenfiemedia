// lib/widgets/app_version_checker.dart

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppVersionChecker extends StatefulWidget {
  const AppVersionChecker({super.key});

  @override
  State<AppVersionChecker> createState() => _AppVersionCheckerState();
}

class _AppVersionCheckerState extends State<AppVersionChecker> {
  String _currentVersion = 'Loading...';
  // 🌟 Placeholder: Set to true to test the update notification UI
  bool _isUpdateAvailable = false;

  // 🌟 Placeholder: Replace with actual store links 🌟
  final String _appStoreLink =
      'https://play.google.com/store/apps/details?id=com.localcode.ahenfiemedia';

  @override
  void initState() {
    super.initState();
    _loadVersionInfoAndCheckUpdate();
  }

  // --- Version Fetcher & Checker ---
  Future<void> _loadVersionInfoAndCheckUpdate() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      // Combines the version and build number
      _currentVersion = '${info.version} (${info.buildNumber})';
    });

    // 🌟 Demo Logic: Set this to 'true' to show the update notification.
    if (info.version.compareTo('1.1.0') < 0) {
      // Assuming 1.1.0 is the new version
      setState(() {
        _isUpdateAvailable = true;
      });
    }
  }

  // --- Action: Launch Store Link ---
  void _launchUpdateLink() async {
    final Uri url = Uri.parse(_appStoreLink);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open the store link: $_appStoreLink'),
        ),
      );
    }
  }

  // --- Widget Builder ---
  @override
  Widget build(BuildContext context) {
    // Customize the color/icon if an update is available
    Widget trailingWidget = _isUpdateAvailable
        ? const Icon(Icons.download_for_offline, color: Colors.green)
        : const SizedBox.shrink();

    // Use a different color for the title when an update is available
    Color titleColor = _isUpdateAvailable
        ? Colors.green
        : Theme.of(context).textTheme.titleMedium?.color ?? Colors.white;

    return ListTile(
      title: Text(
        'App Version',
        style: TextStyle(
          color: titleColor,
          fontWeight: _isUpdateAvailable ? FontWeight.bold : FontWeight.normal,
        ),
      ),

      // 🌟 FIX: Use a Column to show separate update and version lines 🌟
      subtitle: _isUpdateAvailable
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1: The bold update status
                const Text(
                  'New version available! Tap to update.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                // Line 2: The current version info
                Text('Current: $_currentVersion'),
              ],
            )
          // Default state: Show only the version number
          : Text('Current: $_currentVersion'),

      trailing: trailingWidget,
      onTap: _isUpdateAvailable
          ? _launchUpdateLink // Clickable when update is available
          : null, // Not clickable otherwise
    );
  }
}
