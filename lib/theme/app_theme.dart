import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // カラーパレット
  static const Color baseWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color textBlack = Color(0xFF212121);
  static const Color darkGray = Color(0xFF757575);
  static const Color accentOrange = Color(0xFFFF9800); // Energy
  static const Color accentBlue = Color(0xFF03A9F4); // Trust

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentOrange,
        primary: accentOrange,
        secondary: accentBlue,
        surface: baseWhite,
        background: lightGray,
        onPrimary: baseWhite,
        onSecondary: baseWhite,
        onSurface: textBlack,
        onBackground: textBlack,
      ),
      scaffoldBackgroundColor: lightGray,
      textTheme: GoogleFonts.notoSansJpTextTheme(
        ThemeData.light().textTheme.apply(
              bodyColor: textBlack,
              displayColor: textBlack,
            ),
      ),
      cardTheme: CardThemeData(
        color: baseWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: darkGray.withOpacity(0.2), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: baseWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkGray.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkGray.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentOrange, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: baseWhite,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
