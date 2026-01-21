import 'package:flutter/material.dart';
import '../models/done_item.dart';
import '../services/category_service.dart';

class BadgeService {
  static const List<int> badgeRanks = [3, 7, 30, 100];

  /// カテゴリごとの連続日数を計算
  static int calculateStreakDays(String category, List<DoneItem> doneList) {
    if (doneList.isEmpty) return 0;

    // カテゴリでフィルタリング
    final categoryItems = doneList
        .where((item) => item.category == category)
        .toList();

    if (categoryItems.isEmpty) return 0;

    // 日付ごとにグループ化
    final Map<String, List<DoneItem>> itemsByDate = {};
    for (final item in categoryItems) {
      final dateKey = _getDateKey(item.createdAt);
      itemsByDate.putIfAbsent(dateKey, () => []).add(item);
    }

    // 日付をソート
    final sortedDates = itemsByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    if (sortedDates.isEmpty) return 0;

    // 連続日数を計算
    int streak = 0;
    final now = DateTime.now();
    DateTime? expectedDate = DateTime(now.year, now.month, now.day);

    for (final dateKey in sortedDates) {
      final date = _parseDateKey(dateKey);
      if (date == null) continue;

      // 今日または昨日から連続しているかチェック
      if (streak == 0) {
        // 最初の日付が今日または昨日でない場合は連続していない
        if (expectedDate == null) break;
        final daysDiff = expectedDate.difference(date).inDays;
        if (daysDiff > 1) break;
        if (daysDiff == 0 || daysDiff == 1) {
          streak = 1;
          expectedDate = date.subtract(const Duration(days: 1));
        }
      } else {
        // 連続しているかチェック
        if (expectedDate == null) break;
        final daysDiff = expectedDate.difference(date).inDays;
        if (daysDiff == 0) {
          streak++;
          expectedDate = date.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
    }

    return streak;
  }

  /// バッジ獲得条件をチェック
  static List<int> checkAndAwardBadges(String category, int streakDays) {
    final earnedRanks = <int>[];
    for (final rank in badgeRanks) {
      if (streakDays >= rank) {
        earnedRanks.add(rank);
      }
    }
    return earnedRanks;
  }

  /// バッジアイコンを取得
  static IconData getBadgeIcon(String category, int rank) {
    switch (category) {
      case 'Work':
        return Icons.business_center;
      case 'Growth':
        return Icons.school;
      case 'Hobby':
        // ランクに応じて異なるアイコン
        switch (rank) {
          case 3:
            return Icons.music_note;
          case 7:
            return Icons.camera_alt;
          case 30:
            return Icons.directions_bike;
          case 100:
            return Icons.star;
          default:
            return Icons.music_note;
        }
      case 'Health':
        return Icons.fitness_center;
      case 'Life':
        return Icons.home;
      default:
        return Icons.star;
    }
  }

  /// バッジの色を取得
  static Color getBadgeColor(String category, int rank, bool isEarned) {
    final baseColor = Color(AsyncCategoryService.getCategoryColor(category));
    if (!isEarned) {
      return baseColor.withOpacity(0.3);
    }
    
    // ランクに応じて色の濃さを調整
    switch (rank) {
      case 3:
        return baseColor.withOpacity(0.6);
      case 7:
        return baseColor.withOpacity(0.8);
      case 30:
        return baseColor;
      case 100:
        return baseColor;
      default:
        return baseColor;
    }
  }

  /// バッジのサイズを取得
  static double getBadgeSize(int rank) {
    switch (rank) {
      case 3:
        return 40.0;
      case 7:
        return 48.0;
      case 30:
        return 56.0;
      case 100:
        return 64.0;
      default:
        return 40.0;
    }
  }

  static String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime? _parseDateKey(String key) {
    try {
      final parts = key.split('-');
      if (parts.length != 3) return null;
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (e) {
      return null;
    }
  }
}
