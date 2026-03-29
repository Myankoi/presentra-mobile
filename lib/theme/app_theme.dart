import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Stitch Primary Palette ──────────────────────────────
  static const Color primaryBlue  = Color(0xFF137FEC); // Stitch #137fec
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed    = Color(0xFFDC2626);

  // ── Neutrals ────────────────────────────────────────────
  static const Color lightGray  = Color(0xFFF3F4F6);
  static const Color mediumGray = Color(0xFF9CA3AF);
  static const Color darkGray   = Color(0xFF4B5563);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);

  // ── Semantic ────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger  = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // ── Radius ──────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusFull = 100.0;

  // ── Shadows ─────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primaryBlue.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Typography (Lexend) ──────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.lexend(
    fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF111827),
  );
  static TextStyle get titleLarge => GoogleFonts.lexend(
    fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF111827),
  );
  static TextStyle get titleMedium => GoogleFonts.lexend(
    fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF111827),
  );
  static TextStyle get bodyMedium => GoogleFonts.lexend(
    fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF4B5563),
  );
  static TextStyle get bodySmall => GoogleFonts.lexend(
    fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF),
  );
  static TextStyle get labelBold => GoogleFonts.lexend(
    fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5,
  );

  // ── MaterialApp ThemeData ────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      primary: primaryBlue,
      surface: background,
    ),
    textTheme: GoogleFonts.lexendTextTheme(),
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.lexend(
        fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF111827),
      ),
      iconTheme: const IconThemeData(color: primaryBlue),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.lexend(fontSize: 14, color: const Color(0xFF9CA3AF)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: mediumGray,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.lexend(fontSize: 11),
    ),
  );
}