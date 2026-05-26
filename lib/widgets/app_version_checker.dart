import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

class AppVersionChecker extends StatefulWidget {
  const AppVersionChecker({super.key});

  @override
  State<AppVersionChecker> createState() => _AppVersionCheckerState();
}

class _AppVersionCheckerState extends State<AppVersionChecker> {
  String _currentVersion = '';
  bool _isUpdateAvailable = false;

  static const _storeLink =
      'https://play.google.com/store/apps/details?id=com.localcode.ahenfiemedia';

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final info = await PackageInfo.fromPlatform();
    final version = '${info.version} (${info.buildNumber})';

    bool updateAvailable = false;
    try {
      final upgrader = Upgrader.sharedInstance;
      await upgrader.initialize();
      updateAvailable = upgrader.isUpdateAvailable() == true;
    } catch (_) {
      updateAvailable = false;
    }

    if (mounted) {
      setState(() {
        _currentVersion = version;
        _isUpdateAvailable = updateAvailable;
      });
    }
  }

  Future<void> _openStore() async {
    final uri = Uri.parse(_storeLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        'App Version',
        style: TextStyle(
          color: _isUpdateAvailable
              ? Colors.green
              : Theme.of(context).textTheme.titleMedium?.color,
          fontWeight:
              _isUpdateAvailable ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: _isUpdateAvailable
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'New version available! Tap to update.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Current: $_currentVersion'),
              ],
            )
          : Text(_currentVersion.isEmpty ? 'Loading...' : 'v$_currentVersion'),
      trailing: _isUpdateAvailable
          ? const Icon(Icons.download_for_offline, color: Colors.green)
          : const SizedBox.shrink(),
      onTap: _isUpdateAvailable ? _openStore : null,
    );
  }
}
