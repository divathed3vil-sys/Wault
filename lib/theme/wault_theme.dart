// lib/theme/wault_theme.dart
// All colors, text styles, and theme configuration for WAult.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class WaultColors {
  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0F0F14);
  static const Color surface = Color(0xFF1A1A24);
  static const Color elevated = Color(0xFF22222E);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color glassBorder = Color(0x33FFFFFF); // white 20%
  static const Color divider = Color(0x1AFFFFFF);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFF8696A0);
  static const Color textTertiary = Color(0xFF5A6670);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF25D366);
  static const Color primaryDim = Color(0x3325D366);

  // ── Overlay ───────────────────────────────────────────────────────────────
  static const Color scrim = Color(0x80000000);
}

class WaultTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: WaultColors.background,
      colorScheme: const ColorScheme.dark(
        primary: WaultColors.primary,
        surface: WaultColors.surface,
        onPrimary: Colors.black,
        onSurface: WaultColors.textPrimary,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: WaultColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: WaultColors.textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: WaultColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: WaultColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WaultColors.elevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WaultColors.glassBorder, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WaultColors.glassBorder, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WaultColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: WaultColors.textTertiary,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        color: WaultColors.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.inter(
        color: WaultColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineLarge: GoogleFonts.inter(
        color: WaultColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.inter(
        color: WaultColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.inter(
        color: WaultColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      titleMedium: GoogleFonts.inter(
        color: WaultColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.inter(
        color: WaultColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        color: WaultColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.inter(
        color: WaultColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

/// Helper to parse hex color strings like '#25D366'
Color hexColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}
