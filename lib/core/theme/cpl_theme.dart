import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CplColors {
  // Canvas & Backgrounds
  static const Color canvas = Color(0xFFF1F5F9); // Slate 100
  static const Color surface = Color(0xFFF8FAFC); // Slate 50
  static const Color card = Color(0xFFFFFFFF); // Pure White Card

  // Industrial Slate Scale
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A); // Industrial Dark

  // Safety Amber (CPL Primary Accent)
  static const Color safety50 = Color(0xFFFFF7ED);
  static const Color safety100 = Color(0xFFFFEDD5);
  static const Color safety200 = Color(0xFFFED7AA);
  static const Color safety400 = Color(0xFFFB923C);
  static const Color safety500 = Color(0xFFF97316); // Amber Primary
  static const Color safety600 = Color(0xFFEA580C);

  // Semantic Status Colors
  // Pass / Compliant
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);

  // Critical Alarm / Fail
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);

  // Warning / Pending
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber950 = Color(0xFF451A03);

  // Blue / Info
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
}

class CplTypography {
  // Display Headings (Plus Jakarta Sans)
  static TextStyle displayHeading({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w800,
    Color color = CplColors.slate900,
    double? letterSpacing = -0.5,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  // Body & Controls (Inter)
  static TextStyle body({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color color = CplColors.slate800,
    double height = 1.4,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // Code, IDs, Coordinates, Timers (JetBrains Mono)
  static TextStyle mono({
    BuildContext? context,
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w700,
    Color color = CplColors.slate700,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Urdu Translations & Voice Text (Noto Nastaliq Urdu)
  static TextStyle urdu({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w700,
    Color color = CplColors.slate800,
    double height = 1.95,
  }) {
    return GoogleFonts.notoNastaliqUrdu(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  static TextStyle subheading([BuildContext? context]) => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: CplColors.slate900,
  );

  static TextStyle caption([BuildContext? context]) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: CplColors.slate500,
  );

  static TextStyle urduText([BuildContext? context]) => GoogleFonts.notoNastaliqUrdu(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: CplColors.slate800,
    height: 1.95,
  );
}

class CplTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: CplColors.canvas,
      colorScheme: const ColorScheme.light(
        primary: CplColors.safety500,
        onPrimary: Colors.white,
        secondary: CplColors.slate900,
        onSecondary: Colors.white,
        surface: CplColors.card,
        onSurface: CplColors.slate900,
        error: CplColors.red600,
      ),
      cardTheme: CardThemeData(
        color: CplColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: CplColors.slate200, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: CplColors.slate900,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: CplTypography.displayHeading(fontSize: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CplColors.slate50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CplColors.slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CplColors.slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: CplColors.safety500, width: 1.8),
        ),
        labelStyle: CplTypography.body(fontSize: 11, color: CplColors.slate500, fontWeight: FontWeight.w600),
        hintStyle: CplTypography.body(fontSize: 12, color: CplColors.slate400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CplColors.safety500,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: CplTypography.displayHeading(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
