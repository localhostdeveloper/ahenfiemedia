// lib/screens/menu_screen/settings_screen.dart

import 'package:flutter/material.dart';

// 🌟 Import the new setting sections 🌟
import 'settings_items/display_settings.dart';
import 'settings_items/notification_settings.dart';
import 'settings_items/app_info_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- 1. Display/Theme Section ---
            DisplaySettings(),
            _Divider(),

            // --- 2. Notifications Section ---
            NotificationSettings(),
            _Divider(),

            // --- 3. App Info/Legal Section ---
            AppInfoSection(),
          ],
        ),
      ),
    );
  }
}

// Re-defining the Divider as a separate widget for clean code
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
  }
}
