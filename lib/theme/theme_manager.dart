import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テーマタイプ
enum ThemeType {
  pop,
  elegant,
  formal,
  simple,
}

/// テーマスタイル情報
class ThemeStyle {
  final double cardBorderRadius;
  final double buttonBorderRadius;
  final double graphBarWidth;
  final double graphLineWidth;
  final EdgeInsets cardPadding;
  final EdgeInsets graphPadding;
  final double elevation;
  final bool useBoldShadows;

  const ThemeStyle({
    required this.cardBorderRadius,
    required this.buttonBorderRadius,
    required this.graphBarWidth,
    required this.graphLineWidth,
    required this.cardPadding,
    required this.graphPadding,
    required this.elevation,
    required this.useBoldShadows,
  });
}

/// テーママネージャー
class ThemeManager {
  static const String _themeKey = 'selected_theme';
  static ThemeType _currentTheme = ThemeType.simple;

  /// 現在のテーマタイプを取得
  static ThemeType get currentTheme => _currentTheme;

  /// テーマを読み込む
  static Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? ThemeType.simple.index;
      _currentTheme = ThemeType.values[themeIndex];
    } catch (e) {
      _currentTheme = ThemeType.simple;
    }
  }

  /// テーマを保存
  static Future<void> saveTheme(ThemeType theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
      _currentTheme = theme;
    } catch (e) {
      // エラーハンドリング
    }
  }

  /// テーマに応じたThemeDataを取得
  static ThemeData getTheme(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.pop:
        return _getPopTheme();
      case ThemeType.elegant:
        return _getElegantTheme();
      case ThemeType.formal:
        return _getFormalTheme();
      case ThemeType.simple:
        return _getSimpleTheme();
    }
  }

  /// テーマスタイル情報を取得
  static ThemeStyle getThemeStyle(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.pop:
        return const ThemeStyle(
          cardBorderRadius: 12,
          buttonBorderRadius: 12,
          graphBarWidth: 20,
          graphLineWidth: 1,
          cardPadding: EdgeInsets.all(16),
          graphPadding: EdgeInsets.all(16),
          elevation: 1,
          useBoldShadows: false,
        );
      case ThemeType.elegant:
        return const ThemeStyle(
          cardBorderRadius: 12,
          buttonBorderRadius: 12,
          graphBarWidth: 20,
          graphLineWidth: 1,
          cardPadding: EdgeInsets.all(16),
          graphPadding: EdgeInsets.all(16),
          elevation: 1,
          useBoldShadows: false,
        );
      case ThemeType.formal:
        return const ThemeStyle(
          cardBorderRadius: 8,
          buttonBorderRadius: 8,
          graphBarWidth: 20,
          graphLineWidth: 1,
          cardPadding: EdgeInsets.all(16),
          graphPadding: EdgeInsets.all(16),
          elevation: 1,
          useBoldShadows: false,
        );
      case ThemeType.simple:
        return const ThemeStyle(
          cardBorderRadius: 8,
          buttonBorderRadius: 8,
          graphBarWidth: 20,
          graphLineWidth: 1,
          cardPadding: EdgeInsets.all(16),
          graphPadding: EdgeInsets.all(16),
          elevation: 0,
          useBoldShadows: false,
        );
    }
  }

  /// ポップテーマ
  static ThemeData _getPopTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF9800),
        primary: const Color(0xFFFF9800),
        secondary: const Color(0xFF1E3A5F),
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF212121),
        onBackground: const Color(0xFF212121),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      textTheme: GoogleFonts.notoSansJpTextTheme(
        ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF212121),
              displayColor: const Color(0xFF212121),
            ),
      ).copyWith(
        displayLarge: GoogleFonts.notoSansJp(
          fontSize: 64,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFF9800),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF9800),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// エレガントテーマ
  static ThemeData _getElegantTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E3A5F),
        primary: const Color(0xFF1E3A5F),
        secondary: const Color(0xFF757575),
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF212121),
        onBackground: const Color(0xFF212121),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      textTheme: GoogleFonts.notoSansJpTextTheme(
        ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF212121),
              displayColor: const Color(0xFF212121),
            ),
      ).copyWith(
        displayLarge: GoogleFonts.notoSansJp(
          fontSize: 64,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1E3A5F),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// フォーマルテーマ
  static ThemeData _getFormalTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF37474F),
        primary: const Color(0xFF37474F),
        secondary: const Color(0xFF757575),
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF212121),
        onBackground: const Color(0xFF212121),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      textTheme: GoogleFonts.notoSansJpTextTheme(
        ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF212121),
              displayColor: const Color(0xFF212121),
            ),
      ).copyWith(
        displayLarge: GoogleFonts.notoSansJp(
          fontSize: 64,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF37474F),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF37474F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1,
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// シンプルテーマ
  static ThemeData _getSimpleTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        primary: Colors.black,
        secondary: const Color(0xFF757575),
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      textTheme: GoogleFonts.notoSansJpTextTheme(
        ThemeData.light().textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
      ).copyWith(
        displayLarge: GoogleFonts.notoSansJp(
          fontSize: 64,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// テーマ名を取得
  static String getThemeName(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.pop:
        return 'ポップ';
      case ThemeType.elegant:
        return 'エレガント';
      case ThemeType.formal:
        return 'フォーマル';
      case ThemeType.simple:
        return 'シンプル';
    }
  }
}
