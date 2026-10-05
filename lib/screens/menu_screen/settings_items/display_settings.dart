// lib/screens/menu_screen/settings_items/display_settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/theme_provider.dart';

class DisplaySettings extends ConsumerWidget {
  const DisplaySettings({super.key});

  static const _subtitles = {
    ThemeMode.system: 'Matches your phone\'s light or dark setting.',
    ThemeMode.light: 'Always use the light theme.',
    ThemeMode.dark: 'Always use the dark theme.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final currentMode = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Display & Appearance'),
        ListTile(
          title: const Text('Theme'),
          subtitle: Text(_subtitles[currentMode]!),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_rounded),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded),
                  label: Text('Dark'),
                ),
              ],
              selected: {currentMode},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  ref.read(themeProvider.notifier).setTheme(selection.first),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? colors.accentText
                      : colors.textSecondary,
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.primaryGold.withValues(alpha: 0.16)
                      : Colors.transparent,
                ),
                side: WidgetStatePropertyAll(
                  BorderSide(color: colors.cardBorder),
                ),
              ),
            ),
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
