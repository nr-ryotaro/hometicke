import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/letter_settings.dart';
import '../services/ai_letter_service.dart';
import '../providers/done_provider.dart';
import '../providers/theme_provider.dart';

final letterSettingsProvider = StateNotifierProvider<LetterSettingsNotifier, LetterSettings>((ref) {
  return LetterSettingsNotifier();
});

class LetterSettingsNotifier extends StateNotifier<LetterSettings> {
  LetterSettingsNotifier() : super(LetterSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hour = prefs.getInt('letter_notification_hour') ?? 22;
      final minute = prefs.getInt('letter_notification_minute') ?? 0;
      final lastShownTimestamp = prefs.getInt('letter_last_shown_date');
      DateTime? lastShownDate;
      if (lastShownTimestamp != null) {
        lastShownDate = DateTime.fromMillisecondsSinceEpoch(lastShownTimestamp);
      }
      state = LetterSettings(
        notificationHour: hour,
        notificationMinute: minute,
        lastShownDate: lastShownDate,
      );
    } catch (e) {
      state = LetterSettings();
    }
  }

  Future<void> updateNotificationTime(int hour, int minute) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('letter_notification_hour', hour);
      await prefs.setInt('letter_notification_minute', minute);
      state = state.copyWith(
        notificationHour: hour,
        notificationMinute: minute,
      );
    } catch (e) {
      // エラーハンドリング
    }
  }

  Future<void> updateLastShownDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('letter_last_shown_date', date.millisecondsSinceEpoch);
      state = state.copyWith(lastShownDate: date);
    } catch (e) {
      // エラーハンドリング
    }
  }
}

final letterControllerProvider = Provider<LetterController>((ref) {
  return LetterController(ref);
});

class LetterController {
  final Ref ref;

  LetterController(this.ref);

  /// 今日のDoneリストからレターを生成
  Future<String> generateTodayLetter() async {
    try {
      final doneList = ref.read(todayDoneListProvider);
      final themeType = ref.read(themeTypeProvider);
      return await AILetterService.generateLetter(doneList, themeType);
    } catch (e) {
      return 'レターの生成に失敗しました。';
    }
  }

  /// レターを表示すべきかチェック
  bool shouldShowLetter() {
    final settings = ref.read(letterSettingsProvider);
    final todayCount = ref.read(todayDoneCountProvider);
    return AILetterService.shouldShowLetter(settings.lastShownDate, todayCount);
  }

  /// レター表示を記録
  Future<void> markLetterAsShown() async {
    final notifier = ref.read(letterSettingsProvider.notifier);
    await notifier.updateLastShownDate(DateTime.now());
  }
}
