import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═══════════════════════════════════════════════════════════════════
//  AppTheme — single source of truth for Presentra Mobile design
// ═══════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  // ── Brand Colors (static, don't change with theme mode) ─────────
  static const Color primaryBlue   = Color(0xFF137FEC);
  static const Color primaryGreen  = Color(0xFF10B981);
  static const Color accentOrange  = Color(0xFFF59E0B);
  static const Color accentRed     = Color(0xFFDC2626);
  static const Color accentPurple  = Color(0xFF7C3AED);

  // ── Semantic Status Colors ──────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger  = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // ── Light Palette ───────────────────────────────────────────────
  static const Color _lightBackground    = Color(0xFFF8FAFC);
  static const Color _lightSurface       = Color(0xFFFFFFFF);
  static const Color _lightCard          = Color(0xFFFFFFFF);
  static const Color _lightDivider       = Color(0xFFF3F4F6);
  static const Color _lightTextPrimary   = Color(0xFF111827);
  static const Color _lightTextSecondary = Color(0xFF4B5563);
  static const Color _lightTextTertiary  = Color(0xFF9CA3AF);
  static const Color _lightInputFill     = Color(0xFFFFFFFF);
  static const Color _lightInputBorder   = Color(0xFFE5E7EB);
  static const Color _lightNavBar        = Color(0xFF1E293B);

  // ── Dark Palette ────────────────────────────────────────────────
  static const Color _darkBackground    = Color(0xFF0F1117);
  static const Color _darkSurface       = Color(0xFF1A1D27);
  static const Color _darkCard          = Color(0xFF1E2130);
  static const Color _darkDivider       = Color(0xFF2D3344);
  static const Color _darkTextPrimary   = Color(0xFFF1F5F9);
  static const Color _darkTextSecondary = Color(0xFFA1A8B8);
  static const Color _darkTextTertiary  = Color(0xFF6B7280);
  static const Color _darkInputFill     = Color(0xFF1E2130);
  static const Color _darkInputBorder   = Color(0xFF2D3344);
  static const Color _darkNavBar        = Color(0xFF10131A);

  // ── LEGACY static colors (for gradual migration) ────────────────
  // Will keep these so existing code doesn't break during migration
  static const Color lightGray  = Color(0xFFF3F4F6);
  static const Color mediumGray = Color(0xFF9CA3AF);
  static const Color darkGray   = Color(0xFF4B5563);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAFC);

  // ── Spacing Constants ───────────────────────────────────────────
  static const double screenPadding = 20.0;
  static const double cardPadding   = 16.0;
  static const double sectionGap    = 24.0;
  static const double itemGap       = 12.0;
  static const double chipGap       = 8.0;

  // ── Radius ──────────────────────────────────────────────────────
  static const double radiusSm   = 8.0;
  static const double radiusMd   = 12.0;
  static const double radiusLg   = 16.0;
  static const double radiusXl   = 20.0;
  static const double radiusFull = 100.0;

  // ── Shadows (theme-aware) ───────────────────────────────────────
  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> elevatedShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? primaryBlue.withValues(alpha: 0.15)
            : primaryBlue.withValues(alpha: 0.25),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // LEGACY: static shadow getters for backward compat during migration
  static List<BoxShadow> get cardShadowStatic => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadowStatic => [
    BoxShadow(
      color: primaryBlue.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Typography (Lexend) ──────────────────────────────────────────
  static TextStyle displayLarge(BuildContext context) => GoogleFonts.lexend(
    fontSize: 28, fontWeight: FontWeight.bold,
    color: Theme.of(context).extension<AppColors>()!.textPrimary,
  );

  static TextStyle titleLarge(BuildContext context) => GoogleFonts.lexend(
    fontSize: 20, fontWeight: FontWeight.bold,
    color: Theme.of(context).extension<AppColors>()!.textPrimary,
  );

  static TextStyle titleMedium(BuildContext context) => GoogleFonts.lexend(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: Theme.of(context).extension<AppColors>()!.textPrimary,
  );

  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.lexend(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: Theme.of(context).extension<AppColors>()!.textSecondary,
  );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.lexend(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: Theme.of(context).extension<AppColors>()!.textSecondary,
  );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.lexend(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: Theme.of(context).extension<AppColors>()!.textTertiary,
  );

  static TextStyle labelBold(BuildContext context) => GoogleFonts.lexend(
    fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5,
    color: Theme.of(context).extension<AppColors>()!.textPrimary,
  );

  // ── MaterialApp ThemeData (LIGHT) ────────────────────────────────
  static ThemeData get theme => _buildTheme(
    brightness: Brightness.light,
    background: _lightBackground,
    surface: _lightSurface,
    card: _lightCard,
    divider: _lightDivider,
    textPrimary: _lightTextPrimary,
    textSecondary: _lightTextSecondary,
    textTertiary: _lightTextTertiary,
    inputFill: _lightInputFill,
    inputBorder: _lightInputBorder,
    navBar: _lightNavBar,
  );

  // ── MaterialApp ThemeData (DARK) ─────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    background: _darkBackground,
    surface: _darkSurface,
    card: _darkCard,
    divider: _darkDivider,
    textPrimary: _darkTextPrimary,
    textSecondary: _darkTextSecondary,
    textTertiary: _darkTextTertiary,
    inputFill: _darkInputFill,
    inputBorder: _darkInputBorder,
    navBar: _darkNavBar,
  );

  // ── Builder ─────────────────────────────────────────────────────
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color card,
    required Color divider,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color inputFill,
    required Color inputBorder,
    required Color navBar,
  }) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: accentOrange,
        onSecondary: Colors.white,
        error: danger,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: background,
      cardColor: card,
      dividerColor: divider,
      textTheme: GoogleFonts.lexendTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const _SlideFadeTransitionBuilder(),
          TargetPlatform.iOS: const _SlideFadeTransitionBuilder(),
          TargetPlatform.linux: const _SlideFadeTransitionBuilder(),
          TargetPlatform.windows: const _SlideFadeTransitionBuilder(),
          TargetPlatform.macOS: const _SlideFadeTransitionBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.lexend(
          fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        iconTheme: IconThemeData(color: isLight ? const Color(0xFF374151) : textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: inputBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.lexend(fontSize: 14, color: textTertiary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        unselectedLabelStyle: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primaryBlue.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.lexend(fontSize: 11, fontWeight: FontWeight.w600, color: textSecondary),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? const Color(0xFF1E293B) : surface,
        contentTextStyle: GoogleFonts.lexend(fontSize: 13, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        behavior: SnackBarBehavior.floating,
      ),
      extensions: [
        AppColors(
          background: background,
          surface: surface,
          card: card,
          divider: divider,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          textTertiary: textTertiary,
          inputFill: inputFill,
          inputBorder: inputBorder,
          navBar: navBar,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  AppColors Extension — access via Theme.of(context).extension<AppColors>()!
// ═══════════════════════════════════════════════════════════════════

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color card;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color inputFill;
  final Color inputBorder;
  final Color navBar;

  const AppColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.inputFill,
    required this.inputBorder,
    required this.navBar,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? inputFill,
    Color? inputBorder,
    Color? navBar,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      inputFill: inputFill ?? this.inputFill,
      inputBorder: inputBorder ?? this.inputBorder,
      navBar: navBar ?? this.navBar,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      navBar: Color.lerp(navBar, other.navBar, t)!,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Convenience extension on BuildContext
// ═══════════════════════════════════════════════════════════════════

extension AppThemeX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

// ═══════════════════════════════════════════════════════════════════
//  Smooth slide + fade page transition (global)
// ═══════════════════════════════════════════════════════════════════

class _SlideFadeTransitionBuilder extends PageTransitionsBuilder {
  const _SlideFadeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slide = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);

    return SlideTransition(
      position: slide,
      child: FadeTransition(opacity: fade, child: child),
    );
  }
}