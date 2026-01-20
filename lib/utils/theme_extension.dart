import 'package:flutter/material.dart';
import '../theme/theme_manager.dart';

/// テーマ拡張メソッド
extension ThemeExtension on BuildContext {
  /// 現在のテーマタイプを取得
  ThemeType get currentThemeType {
    final theme = Theme.of(this);
    // テーマから判定（簡易版）
    if (theme.colorScheme.primary == const Color(0xFFFF9800)) {
      return ThemeType.pop;
    } else if (theme.colorScheme.primary == const Color(0xFFE3F2FD)) {
      return ThemeType.elegant;
    } else if (theme.colorScheme.primary == const Color(0xFF1A237E)) {
      return ThemeType.formal;
    } else {
      return ThemeType.simple;
    }
  }

  /// テーマスタイルを取得
  ThemeStyle get themeStyle {
    return ThemeManager.getThemeStyle(currentThemeType);
  }
}
