import 'package:flutter/material.dart';

// Brand constants — never change with theme
class AppColors {
  static const Color primaryGold   = Color(0xFFE1A535);
  static const Color darkGold      = Color(0xFFC8922D);
  static const Color softGold      = Color(0xFFF5D27A);
  static const Color accentBrown   = Color(0xFF2B2713);
  static const Color success       = Color(0xFF34C759);
  static const Color error         = Color(0xFFFF453A);
  static const Color warning       = Color(0xFFFF9F0A);
}

// Semantic per-theme palette
class AhenfieColors extends ThemeExtension<AhenfieColors> {
  final Color background;
  final Color surface;
  final Color card;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;
  final Color drawerBg;
  final Color drawerHeader;

  const AhenfieColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.drawerBg,
    required this.drawerHeader,
  });

  // Dark: Midnight Gold
  static const dark = AhenfieColors(
    background:    Color(0xFF0F0F0F),
    surface:       Color(0xFF181818),
    card:          Color(0xFF1F1F1F),
    cardBorder:    Color(0xFF2A2A2A),
    textPrimary:   Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB5B5B5),
    textMuted:     Color(0xFF7A7A7A),
    divider:       Color(0xFF252525),
    drawerBg:      Color(0xFF0D0D0D),
    drawerHeader:  Color(0xFF0A0A0A),
  );

  // Light: Golden Parchment
  static const light = AhenfieColors(
    background:    Color(0xFFFAF7F2),
    surface:       Color(0xFFFFFFFF),
    card:          Color(0xFFF5F0E8),
    cardBorder:    Color(0xFFE5D9C0),
    textPrimary:   Color(0xFF1A1208),
    textSecondary: Color(0xFF5C4830),
    textMuted:     Color(0xFF9C8A6A),
    divider:       Color(0xFFE0D5BE),
    drawerBg:      Color(0xFFEFE8DC),
    drawerHeader:  Color(0xFFE8DFD0),
  );

  @override
  AhenfieColors copyWith({
    Color? background, Color? surface, Color? card, Color? cardBorder,
    Color? textPrimary, Color? textSecondary, Color? textMuted, Color? divider,
    Color? drawerBg, Color? drawerHeader,
  }) => AhenfieColors(
    background:    background    ?? this.background,
    surface:       surface       ?? this.surface,
    card:          card          ?? this.card,
    cardBorder:    cardBorder    ?? this.cardBorder,
    textPrimary:   textPrimary   ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted:     textMuted     ?? this.textMuted,
    divider:       divider       ?? this.divider,
    drawerBg:      drawerBg      ?? this.drawerBg,
    drawerHeader:  drawerHeader  ?? this.drawerHeader,
  );

  @override
  AhenfieColors lerp(AhenfieColors? other, double t) {
    if (other == null) return this;
    return AhenfieColors(
      background:    Color.lerp(background,    other.background,    t)!,
      surface:       Color.lerp(surface,       other.surface,       t)!,
      card:          Color.lerp(card,          other.card,          t)!,
      cardBorder:    Color.lerp(cardBorder,    other.cardBorder,    t)!,
      textPrimary:   Color.lerp(textPrimary,   other.textPrimary,   t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted:     Color.lerp(textMuted,     other.textMuted,     t)!,
      divider:       Color.lerp(divider,       other.divider,       t)!,
      drawerBg:      Color.lerp(drawerBg,      other.drawerBg,      t)!,
      drawerHeader:  Color.lerp(drawerHeader,  other.drawerHeader,  t)!,
    );
  }
}

// Convenience extension — use context.colors.background everywhere
extension AhenfieColorsX on BuildContext {
  AhenfieColors get colors =>
      Theme.of(this).extension<AhenfieColors>() ?? AhenfieColors.dark;
}
