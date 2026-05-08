import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color brandGold = Color(0xFFFFD700); 
  static const Color pureWhite = Color(0xFFFFFFFF);
  
  // Secondary Colors
  static const Color textSecondary = Color(0xFF888888); 
  static const Color shadowColor = Color(0x26000000); // 15% opacity black
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.pureWhite,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlack,
      secondary: AppColors.brandGold,
      surface: AppColors.pureWhite,
    ),
    textTheme: const TextTheme(
      labelSmall: TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        fontSize: 11,
      ),
      titleLarge: TextStyle(
        color: AppColors.primaryBlack,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  );
}