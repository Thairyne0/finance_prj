import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ══════════════════════════════════════════════════════════════════
/// MARATHON-INSPIRED REALISTIC GRAPHIC THEME
/// ──────────────────────────────────────────────────────────────────
/// Estetica: nero assoluto, rosso ossidato, ciano freddo, metallo
/// graffiato, bordi luminosi neon, HUD militare sci-fi.
/// ══════════════════════════════════════════════════════════════════

class AppTheme {
  AppTheme._();

  // ── PALETTE MARATHON ────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFFD4432F);  // rosso ossidato Marathon
  static const Color secondaryColor = Color(0xFF00E5CC);  // ciano freddo neon
  static const Color incomeColor    = Color(0xFF00E5CC);  // ciano = entrate
  static const Color expenseColor   = Color(0xFFD4432F);  // rosso = uscite
  static const Color warningColor   = Color(0xFFFF6A1A);  // arancio neon caldo
  static const Color accentGold     = Color(0xFFE8A838);  // oro consumato

  // ── SUPERFICI — nero profondissimo, metallo bruciato ───────────
  static const Color scaffoldDark  = Color(0xFF050507);   // void nero
  static const Color surfaceDark   = Color(0xFF0A0A0E);   // metallo scuro
  static const Color cardDark      = Color(0xFF0F1014);   // pannello HUD
  static const Color cardDarkAlt   = Color(0xFF141419);   // pannello secondario
  static const Color borderDark    = Color(0xFF1E1F26);   // bordo metallo

  // ── BORDI LUMINOSI NEON ─────────────────────────────────────────
  static const Color borderNeon    = Color(0xFF2A1A18);   // bordo rosso spento
  static const Color borderCyan    = Color(0xFF0A2926);   // bordo ciano spento

  // ── TESTO — freddo, industriale ─────────────────────────────────
  static const Color textPrimary   = Color(0xFFE8E6E3);   // bianco sporco caldo
  static const Color textSecondary = Color(0xFF8A8890);   // grigio metallo
  static const Color textTertiary  = Color(0xFF55545C);   // grigio acciaio scuro
  static const Color textMuted     = Color(0xFF35343A);   // quasi invisibile

  // ── GLASS & MATERIALI ───────────────────────────────────────────
  static const Color surfaceGlass  = Color(0x08FFFFFF);
  static const Color borderGlass   = Color(0x10FFFFFF);

  // ═══════════════════════════════════════════════════════════════
  // HELPER: OMBRE REALISTICHE
  // ═══════════════════════════════════════════════════════════════

  /// Ombre dure, industriali — non morbide, ma "tagliate"
  static List<BoxShadow> realisticShadow({double elevation = 1.0}) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.5 * elevation),
        blurRadius: 12 * elevation,
        spreadRadius: -2,
        offset: Offset(0, 3 * elevation),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3 * elevation),
        blurRadius: 4 * elevation,
        spreadRadius: -1,
        offset: Offset(0, 1 * elevation),
      ),
    ];
  }

  /// Glow neon sottile (bordo luminoso Marathon-style)
  static List<BoxShadow> neonGlow(Color color, {double intensity = 0.3}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: intensity),
        blurRadius: 12,
        spreadRadius: -2,
      ),
      BoxShadow(
        color: color.withValues(alpha: intensity * 0.3),
        blurRadius: 30,
        spreadRadius: -6,
      ),
    ];
  }

  /// Alias per retrocompatibilità
  static List<BoxShadow> glowShadow(Color color, {double blur = 20, double opacity = 0.15}) {
    return neonGlow(color, intensity: opacity);
  }

  static List<BoxShadow> premiumGlow(Color color) {
    return neonGlow(color, intensity: 0.35);
  }

  /// Decorazione pannello HUD — bordo luminoso top, fondo scuro
  static BoxDecoration hudPanel({
    Color accentColor = primaryColor,
    double borderRadius = 4,
  }) {
    return BoxDecoration(
      color: cardDark,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border(
        top: BorderSide(color: accentColor.withValues(alpha: 0.5), width: 1),
        left: BorderSide(color: accentColor.withValues(alpha: 0.15), width: 0.5),
        right: BorderSide(color: accentColor.withValues(alpha: 0.15), width: 0.5),
        bottom: BorderSide(color: accentColor.withValues(alpha: 0.05), width: 0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.08),
          blurRadius: 16,
          spreadRadius: -4,
          offset: const Offset(0, -2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 12,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Glassmorphism Marathon — vetro sporco
  static BoxDecoration glassDecoration({
    Color? tint,
    double borderRadius = 4,
    double borderOpacity = 0.06,
  }) {
    final base = tint ?? Colors.white;
    return BoxDecoration(
      color: base.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: base.withValues(alpha: borderOpacity),
        width: 0.5,
      ),
    );
  }

  /// Gradiente sfondo: radiale aggressivo con accento rosso
  static BoxDecoration ambientBackground({Color? accent}) {
    final a = accent ?? primaryColor;
    return BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0.0, -0.8),
        radius: 2.0,
        colors: [
          a.withValues(alpha: 0.04),
          scaffoldDark,
          scaffoldDark,
        ],
        stops: const [0.0, 0.3, 1.0],
      ),
    );
  }

  /// Inner shadow (decorativa per pannelli incassati)
  static BoxDecoration innerShadowDecoration({
    Color color = cardDark,
    double borderRadius = 4,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.015),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.15),
        ],
        stops: const [0.0, 0.2, 1.0],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TIPOGRAFIA — Industriale, condensata per header
  // ═══════════════════════════════════════════════════════════════

  /// Font body: Inter (leggibile, pulito)
  static TextStyle _body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    try {
      return GoogleFonts.inter(
        fontSize: fontSize, fontWeight: fontWeight, color: color,
        letterSpacing: letterSpacing, height: height,
      );
    } catch (_) {
      return TextStyle(
        fontSize: fontSize, fontWeight: fontWeight, color: color,
        letterSpacing: letterSpacing, height: height, fontFamily: '.SF Pro Text',
      );
    }
  }

  /// Font heading: Rajdhani (condensato, sci-fi, militare)
  static TextStyle _heading({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    try {
      return GoogleFonts.rajdhani(
        fontSize: fontSize, fontWeight: fontWeight, color: color,
        letterSpacing: letterSpacing ?? 1.5, height: height,
      );
    } catch (_) {
      return TextStyle(
        fontSize: fontSize, fontWeight: fontWeight, color: color,
        letterSpacing: letterSpacing ?? 1.5, height: height,
        fontFamily: '.SF Pro Display',
      );
    }
  }

  static TextTheme _safeTextTheme() {
    try {
      return GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    } catch (_) {
      return ThemeData.dark().textTheme;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // THEME DATA
  // ═══════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    GoogleFonts.config.allowRuntimeFetching = true;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceDark,
        error: expenseColor,
        onPrimary: textPrimary,
        onSecondary: scaffoldDark,
        onSurface: textPrimary,
        outline: borderDark,
      ),
      textTheme: _safeTextTheme().copyWith(
        // HEADING — Rajdhani, condensato, uppercase-ready
        headlineLarge: _heading(
          fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: 2.0,
        ),
        headlineMedium: _heading(
          fontSize: 26, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 1.5,
        ),
        headlineSmall: _heading(
          fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 1.2,
        ),
        // TITLE — Rajdhani leggero
        titleLarge: _heading(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 1.0,
        ),
        titleMedium: _heading(
          fontSize: 16, fontWeight: FontWeight.w500, color: textPrimary, letterSpacing: 0.8,
        ),
        titleSmall: _body(
          fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary,
        ),
        // BODY — Inter, leggibile
        bodyLarge: _body(
          fontSize: 15, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5,
        ),
        bodyMedium: _body(
          fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5,
        ),
        bodySmall: _body(
          fontSize: 11, fontWeight: FontWeight.w400, color: textTertiary, height: 1.4,
        ),
        // LABEL — uppercase-ready
        labelLarge: _body(
          fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: 0.8,
        ),
        labelMedium: _body(
          fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary, letterSpacing: 0.5,
        ),
        labelSmall: _body(
          fontSize: 10, fontWeight: FontWeight.w500, color: textTertiary, letterSpacing: 0.5,
        ),
      ),
      // ── CARD: bordi bassi, angoli duri ──────────────────────────
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: borderDark.withValues(alpha: 0.8), width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      // ── APPBAR: trasparente, HUD-style ─────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _heading(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: 2.0,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      // ── BOTTOM NAV ─────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      // ── INPUT: bordi duri, glow focus ──────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: borderDark, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: borderDark, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.7), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: _body(color: textMuted, fontSize: 13),
        labelStyle: _body(color: textTertiary, fontSize: 13),
      ),
      // ── BUTTON: duro, industriale ──────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: _body(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.0),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textPrimary,
        elevation: 0,
        shape: CircleBorder(),
      ),
      dividerTheme: DividerThemeData(
        color: borderDark.withValues(alpha: 0.5),
        thickness: 0.5,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: primaryColor.withValues(alpha: 0.2),
        side: BorderSide(color: borderDark, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        labelStyle: _body(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondary),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: cardDark,
          foregroundColor: textSecondary,
          selectedForegroundColor: textPrimary,
          selectedBackgroundColor: primaryColor.withValues(alpha: 0.25),
          side: BorderSide(color: borderDark, width: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
    );
  }
}

