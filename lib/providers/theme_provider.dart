import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_manager.dart';

final themeTypeProvider = StateNotifierProvider<ThemeTypeNotifier, ThemeType>((ref) {
  return ThemeTypeNotifier();
});

class ThemeTypeNotifier extends StateNotifier<ThemeType> {
  ThemeTypeNotifier() : super(ThemeManager.currentTheme) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    await ThemeManager.loadTheme();
    state = ThemeManager.currentTheme;
  }

  Future<void> changeTheme(ThemeType themeType) async {
    await ThemeManager.saveTheme(themeType);
    state = themeType;
  }
}
