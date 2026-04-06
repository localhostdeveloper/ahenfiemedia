// lib/screens/main_menu_screen.dart

import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';

class MainMenuScreen extends StatelessWidget {
  final ValueChanged<int> onItemSelected;

  const MainMenuScreen({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // No local AppBar needed.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          // Content starts from the top
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Title ---
            Text(
              'Select a Stream',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 30),

            // --- Radio Card (Switches to index 1) ---
            _buildMenuItem(
              context,
              icon: Icons.radio,
              title: AppConstants.radioName,
              subtitle: AppConstants.radioMetadataArtist,
              onTap: () => onItemSelected(1),
              color: accentColor,
            ),
            const SizedBox(height: 20),

            // --- TV Card (Switches to index 2) ---
            _buildMenuItem(
              context,
              icon: Icons.tv,
              title: AppConstants.tvName,
              subtitle: 'Watch Live Broadcast',
              onTap: () => onItemSelected(2),
              color: primaryColor,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- _buildMenuItem function ---
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    final textColor = (color == AppColors.primaryBlack)
        ? AppColors.textLight
        : AppColors.textDark;

    return Card(
      color: color,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color:
                    (color == AppColors.primaryBlack ||
                        color == AppColors.darkBackgroundAccent)
                    ? AppColors.accentGold
                    : AppColors.primaryBlack,
              ),
              const SizedBox(width: 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
