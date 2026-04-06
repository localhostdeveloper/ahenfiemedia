// lib/constants/app_theme.dart

import 'package:flutter/material.dart';

class AppColors {
  // --- Primary Brand Colors (Black, Gold, White) ---
  static const Color primaryBlack = Color(0xFF000000);
  static const Color accentGold = Color(0xFFFFD700); // The main accent color

  // --- UI/Background Colors ---
  static const Color background =
      Colors.white; // Main Scaffold Background (Light Theme)
  static const Color darkBackground = Color(
    0xFF121212,
  ); // New dark background color
  static const Color darkBackgroundAccent = Color(
    0xFF1E1E1E,
  ); // Darker shade for cards/surfaces

  // --- Text Colors ---
  static const Color textDark = Color(
    0xFF1A1A1A,
  ); // Near-black for main body text
  static const Color textLight = Colors.white;
  static const Color textSecondary = Color(
    0xFF888888,
  ); // Grey for unselected/secondary text

  // --- Utility Colors ---
  static const Color errorRed = Colors.red;
}

class AppThemes {
  // --- Shared Colors (Ensure consistency between themes) ---
  static const Color _primaryGold = Color.fromARGB(255, 173, 148, 7);

  // ----------------------------------------------------------------------
  // 🌟 LIGHT THEME (Your existing theme) 🌟
  // ----------------------------------------------------------------------
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    // 1. CORE COLOR SCHEME
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey).copyWith(
      secondary: const Color.fromRGBO(177, 153, 15, 1),
      primary: AppColors.primaryBlack,
      surface: AppColors.background,
      error: AppColors.errorRed,
      // Use dark colors for default text/icon (the "on" colors)
      onPrimary: AppColors.textLight,
      onSurface: AppColors.textDark,
    ),

    // 2. SCAFFOLD/BACKGROUND
    scaffoldBackgroundColor: AppColors.background,

    // 3. APP BAR THEME (Black with White text)
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBlack,
      foregroundColor: AppColors.textLight,
      elevation: 4.0,
      titleTextStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // 4. BOTTOM NAVIGATION BAR
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.textLight,
      selectedItemColor: Color.fromRGBO(173, 148, 7, 1),
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    ),

    // 5. CARD/SURFACE THEME (Important for surfaces like cards and bottom sheets)
    cardTheme: const CardThemeData(color: AppColors.background),

    // 6. TEXT STYLES
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textDark),
      bodyMedium: TextStyle(color: AppColors.textDark),
      titleLarge: TextStyle(color: AppColors.textDark),
      titleMedium: TextStyle(color: AppColors.textDark),
    ).apply(displayColor: AppColors.textDark, bodyColor: AppColors.textDark),

    // 7. PROGRESS INDICATORS
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primaryGold,
    ),

    // 8. ICON THEME
    iconTheme: const IconThemeData(color: AppColors.textDark),
  );

  // ----------------------------------------------------------------------
  // 🌟 DARK THEME (NEW IMPLEMENTATION) 🌟
  // ----------------------------------------------------------------------
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    // 1. CORE COLOR SCHEME
    colorScheme:
        ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
          // Use dark background colors
          brightness: Brightness.dark,
        ).copyWith(
          secondary: const Color.fromRGBO(
            185,
            126,
            16,
            1,
          ), // Gold accent remains
          primary:
              AppColors.textLight, // Primary color (text/icons) is light/white
          surface:
              AppColors.darkBackgroundAccent, // Dark gray for cards/surfaces
          error: AppColors.errorRed,
          // Use light colors for default text/icon
          onPrimary: AppColors.primaryBlack,
          onSurface: AppColors.textLight,
        ),

    // 2. SCAFFOLD/BACKGROUND
    scaffoldBackgroundColor: AppColors.darkBackground, // Deep dark background
    // 3. APP BAR THEME (Darker background with Gold title/icons)
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.textLight, // White Icons/Text
      elevation: 4.0,
      titleTextStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // 4. BOTTOM NAVIGATION BAR (Dark background)
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackgroundAccent, // Dark background
      selectedItemColor: _primaryGold,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(color: AppColors.textSecondary),
    ),

    // 5. CARD/SURFACE THEME (Important for surfaces like cards and bottom sheets)
    cardTheme: const CardThemeData(
      color: AppColors.darkBackgroundAccent,
      elevation: 6,
    ),

    // 6. TEXT STYLES (Default text color is light/white)
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textLight),
      bodyMedium: TextStyle(color: AppColors.textLight),
      titleLarge: TextStyle(color: AppColors.textLight),
      titleMedium: TextStyle(color: AppColors.textLight),
    ).apply(displayColor: AppColors.textLight, bodyColor: AppColors.textLight),

    // 7. PROGRESS INDICATORS
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primaryGold,
    ),

    // 8. ICON THEME
    iconTheme: const IconThemeData(color: AppColors.textLight),
  );
}
