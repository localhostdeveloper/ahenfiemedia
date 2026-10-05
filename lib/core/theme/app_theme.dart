import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AhenfieColors.dark.background,
    extensions: const [AhenfieColors.dark],
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryGold,
      secondary: AppColors.darkGold,
      surface: Color(0xFF181818),
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Color(0xFFFFFFFF),
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFFFFFFFF)),
    ),
    cardTheme: CardThemeData(
      color: AhenfieColors.dark.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF0D0D0D),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AhenfieColors.dark.surface,
      indicatorColor: AppColors.primaryGold.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const IconThemeData(color: AppColors.primaryGold);
        return const IconThemeData(color: Color(0xFF7A7A7A));
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: AppColors.primaryGold, fontSize: 12, fontWeight: FontWeight.w600);
        }
        return const TextStyle(color: Color(0xFF7A7A7A), fontSize: 12);
      }),
      elevation: 0,
      height: 64,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.primaryGold),
      trackColor: WidgetStateProperty.all(AppColors.primaryGold.withValues(alpha: 0.4)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primaryGold),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AhenfieColors.dark.card,
      contentTextStyle: const TextStyle(color: Color(0xFFB5B5B5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF252525), thickness: 0.6),
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

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AhenfieColors.light.background,
    extensions: const [AhenfieColors.light],
    colorScheme: const ColorScheme.light(
      // Deeper gold so default TextButtons/links are readable on white
      primary: Color(0xFF93650D),
      secondary: AppColors.darkGold,
      surface: Color(0xFFFFFFFF),
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Color(0xFF141414),
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF141414)),
    ),
    cardTheme: CardThemeData(
      color: AhenfieColors.light.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFFFFFFFF),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFFFFFFF),
      indicatorColor: AppColors.primaryGold.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const IconThemeData(color: Color(0xFF93650D));
        return const IconThemeData(color: Color(0xFF6E6E6E));
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: Color(0xFF93650D), fontSize: 12, fontWeight: FontWeight.w600);
        }
        return const TextStyle(color: Color(0xFF6E6E6E), fontSize: 12);
      }),
      elevation: 0,
      height: 64,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.primaryGold),
      trackColor: WidgetStateProperty.all(AppColors.primaryGold.withValues(alpha: 0.35)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primaryGold),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1F1F1F),
      contentTextStyle: const TextStyle(color: Color(0xFFFFFFFF)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE8E6E1), thickness: 0.6),
    textTheme: TextTheme(
      headlineLarge: AppTypography.headlineLarge.copyWith(color: const Color(0xFF141414)),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: const Color(0xFF141414)),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: const Color(0xFF141414)),
      titleLarge: AppTypography.titleLarge.copyWith(color: const Color(0xFF141414)),
      titleMedium: AppTypography.titleMedium.copyWith(color: const Color(0xFF141414)),
      titleSmall: AppTypography.titleSmall.copyWith(color: const Color(0xFF141414)),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: const Color(0xFF141414)),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: const Color(0xFF5E5E5E)),
    ),
  );
}
