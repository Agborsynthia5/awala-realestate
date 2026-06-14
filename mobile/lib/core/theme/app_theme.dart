import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Awala RealEstate (A-RE) Design System
/// Colors: Navy #0A1F44 | Sky Blue #5BA4CF | Amber #F59E0B
abstract class AppColors {
  // ─── Primary ────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0A1F44);       // Deep Navy
  static const Color accent = Color(0xFF5BA4CF);         // Sky Blue
  static const Color cta = Color(0xFFF59E0B);            // Amber

  // ─── Backgrounds ────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F8FC);     // Soft White
  static const Color surface = Color(0xFFFFFFFF);        // Cards

  // ─── Status ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);        // Emerald
  static const Color error = Color(0xFFEF4444);          // Crimson
  static const Color warning = Color(0xFFF59E0B);        // Amber

  // ─── Text ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);    // Charcoal
  static const Color textSecondary = Color(0xFF6B7280);  // Slate
  static const Color textHint = Color(0xFF9CA3AF);       // Light Slate

  // ─── Borders & Dividers ─────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ─── Gradients ──────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A1F44), Color(0xFF1A3A6E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF5BA4CF), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF4F8FC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          tertiary: AppColors.cta,
          surface: AppColors.surface,
          error: AppColors.error,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.poppins(
            fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          displayMedium: GoogleFonts.poppins(
            fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          headlineLarge: GoogleFonts.poppins(
            fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          titleLarge: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          titleMedium: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
          bodySmall: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
          labelLarge: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cta,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
          labelStyle: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.surface,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          margin: EdgeInsets.zero,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.background,
          selectedColor: AppColors.accent.withValues(alpha: 0.15),
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider, thickness: 1, space: 1),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
