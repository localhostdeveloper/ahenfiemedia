// lib/screens/radio_screen.dart

import 'package:flutter/material.dart';
// 🌟 NEW IMPORTS 🌟
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_theme.dart';
// Assuming RadioPlayerUI is updated to use Riverpod internally
import '../widgets/radio_player_ui.dart';

// 🌟 Convert to ConsumerWidget 🌟
class RadioScreen extends ConsumerWidget {
  const RadioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef
    return Scaffold(
      // Override the background color for a premium look
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      // We wrap the RadioPlayerUI in a Theme to change the text color to white
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(
            bodyColor: AppColors.textLight,
            displayColor: AppColors.textLight,
          ),
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 150, 129, 14),
          ),
        ),
        // 🌟 FIX: Wrap content in SingleChildScrollView to prevent overflow 🌟
        child: SingleChildScrollView(
          // RadioPlayerUI now needs to use ref.watch(radioPlayerProvider) internally
          child: Center(child: RadioPlayerUI()),
        ),
      ),
    );
  }
}
