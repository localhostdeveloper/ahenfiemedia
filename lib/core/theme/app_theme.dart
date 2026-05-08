import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

class AppTheme {
  // ================= DARK THEME =================

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryGold,
      secondary: AppColors.darkGold,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.textPrimary,
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.primaryGold),
      trackColor: WidgetStateProperty.all(
        AppColors.primaryGold.withValues(alpha: 0.4),
      ),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryGold,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.card,
      contentTextStyle: AppTypography.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.accentBrown,
      thickness: 0.6,
    ),

    textTheme: const TextTheme(
      headlineLarge: AppTypography.headlineLarge,
      headlineMedium: AppTypography.headlineMedium,
      headlineSmall: AppTypography.headlineSmall,

      titleLarge: AppTypography.titleLarge,
      titleMedium: AppTypography.titleMedium,
      titleSmall: AppTypography.titleSmall,

      bodyLarge: AppTypography.bodyLarge,
      bodyMedium: AppTypography.bodyMedium,
      bodySmall: AppTypography.bodySmall,

      labelLarge: AppTypography.labelLarge,
      labelMedium: AppTypography.labelMedium,
      labelSmall: AppTypography.labelSmall,
    ),
  );

  // ================= LIGHT THEME =================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.lightBackground,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGold,
      secondary: AppColors.darkGold,
      surface: AppColors.lightSurface,
      error: AppColors.error,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: AppColors.lightTextPrimary,
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.primaryGold,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryGold,
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 0.6,
    ),

    textTheme: TextTheme(
      headlineLarge: AppTypography.headlineLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),

      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: AppColors.lightTextPrimary,
      ),

      headlineSmall: AppTypography.headlineSmall.copyWith(
        color: AppColors.lightTextPrimary,
      ),

      titleLarge: AppTypography.titleLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),

      titleMedium: AppTypography.titleMedium.copyWith(
        color: AppColors.lightTextPrimary,
      ),

      titleSmall: AppTypography.titleSmall.copyWith(
        color: AppColors.lightTextPrimary,
      ),

      bodyLarge: AppTypography.bodyLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),

      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: Colors.black87,
      ),
    ),
  );
}