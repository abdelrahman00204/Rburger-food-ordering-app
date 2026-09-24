import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color maroon950 = Color(0xFF3E0B15);
  static const Color maroon800 = Color(0xFF5C1220);
  static const Color maroon700 = Color(0xFF7A1B2B);

  static const Color gold500 = Color(0xFFF2A93B);
  static const Color gold400 = Color(0xFFF7BE5F);
  static const Color gold300 = Color(0xFFFBD383);
  static const Color gold200 = Color(0xFFFFE3B0);

  static const Color cream50 = Color(0xFFFFF8ED);

  static const Color ink900 = Color(0xFF2A1509);
  static const Color ink600 = Color(0xFF6B4A34);

  static const Color green600 = Color(0xFF3F8F5F);
  static const Color blue600 = Color(0xFF2F6FB2);

  static const Color line = Color(0xFFEADFC9);
}

class AppTheme {
  AppTheme._();

  static const double radius = 18;
  static const double radiusPill = 999;

  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.maroon800,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.maroon800,
          onPrimary: AppColors.gold300,
          secondary: AppColors.gold500,
          onSecondary: AppColors.maroon950,
          tertiary: AppColors.green600,
          onTertiary: Colors.white,
          surface: Colors.white,
          onSurface: AppColors.ink900,
          surfaceContainerHighest: AppColors.cream50,
          outline: AppColors.line,
          error: const Color(0xFFB23A2E),
        );

    // 1. Define base fonts
    final displayFont = GoogleFonts.lalezarTextTheme();
    final bodyFont = GoogleFonts.cairoTextTheme();

    // 2. Strictly enforce Lalezar (w400) and Cairo (w400, w600, w700, w800)
    final textTheme = bodyFont.copyWith(
      // --- LALEZAR (Headlines, Modal Titles, Prices) - w400 ONLY ---
      displayLarge: displayFont.displayLarge?.copyWith(
        color: AppColors.maroon800,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: displayFont.displayMedium?.copyWith(
        color: AppColors.maroon800,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: displayFont.displaySmall?.copyWith(
        color: AppColors.maroon800,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: displayFont.headlineLarge?.copyWith(
        color: AppColors.maroon800,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: displayFont.headlineMedium?.copyWith(
        color: AppColors.maroon800,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: displayFont.headlineSmall?.copyWith(
        color: AppColors.maroon800,
        fontWeight: FontWeight.w400,
      ),

      // --- CAIRO (Body, Labels, Form Fields) ---
      titleLarge: bodyFont.titleLarge?.copyWith(
        color: AppColors.maroon800,
        fontWeight: FontWeight.w800, // Valid Cairo weight
      ),
      bodyLarge: bodyFont.bodyLarge?.copyWith(
        color: AppColors.ink900,
        fontWeight: FontWeight.w600, // Valid Cairo weight
      ),
      bodyMedium: bodyFont.bodyMedium?.copyWith(
        color: AppColors.ink600,
        fontWeight: FontWeight.w400, // Valid Cairo weight
      ),
      bodySmall: bodyFont.bodySmall?.copyWith(
        color: AppColors.ink600,
        fontWeight: FontWeight.w400, // Valid Cairo weight
      ),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream50,
      textTheme: textTheme,

      // --- WIDGET THEMES ---
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.maroon950,
        foregroundColor: AppColors.cream50,
        elevation: 4,
        shadowColor: AppColors.maroon950.withValues(alpha: 0.35),
        // Lalezar for AppBar title
        titleTextStyle: GoogleFonts.lalezar(
          fontSize: 26,
          color: AppColors.gold400,
          fontWeight: FontWeight.w400,
        ),
        iconTheme: const IconThemeData(color: AppColors.cream50),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 6,
        shadowColor: AppColors.maroon950.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.line),
        ),
        margin: EdgeInsets.zero,
      ),

      // Cairo for Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.maroon800,
          foregroundColor: AppColors.gold300,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
          elevation: 4,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cream50,
          side: BorderSide(
            color: AppColors.cream50.withValues(alpha: 0.35),
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.maroon800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
      ),

      // Cairo for Form Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        labelStyle: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.ink600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gold500, width: 2),
        ),
      ),

      // Cairo for Chips
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.06),
        selectedColor: AppColors.gold500,
        labelStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.w700,
          color: AppColors.cream50,
        ),
        secondaryLabelStyle: GoogleFonts.cairo(
          fontWeight: FontWeight.w700,
          color: AppColors.maroon950,
        ),
        shape: const StadiumBorder(
          side: BorderSide(color: Colors.white24, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),

      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.cream50),

      // Lalezar for Modal Titles
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        titleTextStyle: GoogleFonts.lalezar(
          fontSize: 26,
          color: AppColors.maroon800,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
