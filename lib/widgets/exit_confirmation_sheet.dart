// lib/widgets/exit_confirmation_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme.dart';

/// A modal bottom sheet widget for confirming app exit.
class ExitConfirmationSheet extends StatelessWidget {
  const ExitConfirmationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents dismissal via system back button.
      child: SafeArea(
        // Ensures content respects system bars
        child: Container(
          // Use a slightly softer background color for contrast against white scaffold
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16.0),
            ),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Essential to keep the sheet small
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Title ---
              const Text(
                'Exit Application?',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),

              // --- Content ---
              Text(
                'Are you sure you want to exit the app?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24.0),

              // --- Actions ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  // --- CANCEL BUTTON (NO) ---
                  TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(false), // Returns false (Do not exit)
                    child: Text(
                      'No',
                      style: TextStyle(color: AppColors.primaryBlack),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  // --- EXIT BUTTON (YES) ---
                  ElevatedButton(
                    onPressed: () {
                      SystemNavigator.pop();
                      Navigator.of(
                        context,
                      ).pop(true); // Close sheet and handle exit
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.primaryBlack,
                    ),
                    child: const Text('Yes, Exit'),
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
