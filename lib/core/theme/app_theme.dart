import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color secondaryColor = Color(0xFF00D2D3);
  static const Color incomeColor = Color(0xFF00B894);
  static const Color expenseColor = Color(0xFFFF6B6B);
  static const Color warningColor = Color(0xFFFDCB6E);

  // Dark Surface Colors — leggermente più profondi e saturi
  static const Color scaffoldDark = Color(0xFF08080D);
  static const Color surfaceDark = Color(0xFF101018);
  static const Color cardDark = Color(0xFF151524);
  static const Color cardDarkAlt = Color(0xFF16213E);
  static const Color borderDark = Color(0xFF232338);

  // ── Glassmorphism helpers ──────────────────────────────────────
  static const Color surfaceGlass = Color(0x0AFFFFFF);   // bianco alpha ~4%
  static const Color borderGlass = Color(0x18FFFFFF);     // bianco alpha ~9%

  /// BoxDecoration glassmorphism standard (va usata dentro un ClipRRect + BackdropFilter)
  static BoxDecoration glassDecoration({
    Color? tint,
    double borderRadius = 20,
    double borderOpacity = 0.10,
  }) {
    final base = tint ?? Colors.white;
    return BoxDecoration(
      color: base.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: base.withValues(alpha: borderOpacity),
        width: 0.8,
      ),
    );
  }

  /// Sottile glow colorato per card/badge
  static List<BoxShadow> glowShadow(Color color, {double blur = 20, double opacity = 0.15}) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        blurRadius: blur,
        spreadRadius: -4,
      ),
    ];
  }

  /// Glow graduale dual-layer per effetti premium
  static List<BoxShadow> premiumGlow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.18),
        blurRadius: 16,
        spreadRadius: -4,
      ),
      BoxShadow(
        color: color.withValues(alpha: 0.08),
        blurRadius: 40,
        spreadRadius: -8,
      ),
    ];
  }

  /// Helper sicuro: prova GoogleFonts.inter, se fallisce usa font di sistema
  static TextStyle _safeInter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    try {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
    } catch (_) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        fontFamily: '.SF Pro Text',
      );
    }
  }

  /// TextTheme di base sicuro
  static TextTheme _safeTextTheme() {
    try {
      return GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    } catch (_) {
      return ThemeData.dark().textTheme;
    }
  }

  static ThemeData get darkTheme {
    // Abilita il fetching runtime così può scaricare i font se disponibili
    // Se offline, il try-catch nei metodi _safe* gestisce il fallback
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
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        outline: borderDark,
      ),
      textTheme: _safeTextTheme().copyWith(
        headlineLarge: _safeInter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        headlineMedium: _safeInter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: _safeInter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: _safeInter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: _safeInter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: _safeInter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        bodyMedium: _safeInter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
        ),
        bodySmall: _safeInter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white54,
        ),
        labelLarge: _safeInter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _safeInter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: _safeInter(color: Colors.white38),
        labelStyle: _safeInter(color: Colors.white54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: _safeInter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: primaryColor.withValues(alpha: 0.3),
        side: const BorderSide(color: borderDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: _safeInter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: cardDark,
          foregroundColor: Colors.white70,
          selectedForegroundColor: Colors.white,
          selectedBackgroundColor: primaryColor,
          side: const BorderSide(color: borderDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

