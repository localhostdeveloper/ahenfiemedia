// lib/screens/menu_screen/settings_items/display_settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme_provider.dart';

class DisplaySettings extends ConsumerWidget {
  const DisplaySettings({super.key});

  // --- Confirmation Dialog for Theme Change ---
  Future<void> _confirmThemeChange(BuildContext context, WidgetRef ref) async {
    final ThemeMode currentMode = ref.read(themeProvider);

    // Determine the state if we switch: system will become dark, light will become dark, dark will become light
    final bool isCurrentlyDark = currentMode == ThemeMode.dark;
    final String newThemeName = isCurrentlyDark ? 'Light' : 'Dark';

    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Theme'),
          content: Text('Do you want to switch to the $newThemeName theme?'),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('YES, SWITCH'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final notifier = ref.read(themeProvider.notifier);
      notifier.toggleDarkMode(!isCurrentlyDark);

      // Optional: Show a quick feedback SnackBar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme switched to $newThemeName Mode.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode currentMode = ref.watch(themeProvider);
    final bool isDarkModeActive = currentMode == ThemeMode.dark;

    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Display & Appearance'),
        ListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Switch between light and dark themes.'),
          onTap: () => _confirmThemeChange(context, ref),
          trailing: Switch(
            value: isDarkModeActive,
            onChanged: (bool newValue) {
              // Switch works directly for quick toggle, using the Notifier
              themeNotifier.toggleDarkMode(newValue);
            },
          ),
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
