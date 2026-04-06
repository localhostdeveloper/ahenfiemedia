import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../widgets/app_version_checker.dart';

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  // --- Confirmation UI for Clearing Cache ---
  void _confirmClearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear App Cache?'),
          content: const Text(
            'This will delete temporary files and stored preferences (except your theme setting). You may need to log in again if you use any login feature.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              // Call the actual clear logic when confirmed
              onPressed: () {
                Navigator.of(context).pop(); // Close confirmation dialog
                _clearCacheAndShowResult(context);
              },
              child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // --- Actual Clear Cache Handler (Now shows final result dialog) ---
  void _clearCacheAndShowResult(BuildContext context) async {
    HapticFeedback.mediumImpact();
    bool success = true;

    // 1. Clear SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('userThemeMode');
      await prefs.clear();
      if (themeIndex != null) {
        // Restore theme setting after clearing all others
        await prefs.setInt('userThemeMode', themeIndex);
      }
    } catch (e) {
      success = false;
      print('Error clearing preferences cache: $e');
    }

    // 2. Clear Temporary File Cache
    try {
      final Directory tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
        await tempDir.create(recursive: true);
      }
    } catch (e) {
      success = false;
      print('Error clearing file cache: $e');
    }

    // 3. Final Confirmation Dialog UI
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(success ? 'Cache Cleared' : 'Action Completed'),
            content: Text(
              success
                  ? 'All temporary app data has been successfully cleared.'
                  : 'Cache clearing finished with minor errors. Restart the app if you notice issues.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionHeader(context, 'App Information'),

        // App Version Checker
        const AppVersionChecker(),

        // Clear Cache Button
        ListTile(
          title: const Text('Clear Cache'),
          subtitle: const Text('Free up storage space used by the app.'),
          // 🌟 NEW: Call confirmation dialog 🌟
          onTap: () => _confirmClearCache(context),
          trailing: const Icon(Icons.cleaning_services),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
