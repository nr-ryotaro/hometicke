import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/done_item.dart';
import '../services/category_service.dart';
import 'badge_provider.dart';

final doneBoxProvider = FutureProvider<Box<DoneItem>>((ref) async {
  try {
    // Hiveはmain.dartで初期化済み
    final box = await Hive.openBox<DoneItem>('done_items');
    
    // 既存データのマイグレーション（categoryがnullの場合にデフォルト値を設定）
    try {
      for (var item in box.values) {
        // categoryがnullまたは空の場合にデフォルト値を設定
        if (item.category.isEmpty) {
          item.category = Category.uncategorized;
          await item.save();
        }
      }
    } catch (e) {
      // マイグレーションエラーは無視
    }
    
    return box;
  } catch (e) {
    // エラー時は再スロー
    rethrow;
  }
});

final doneListProvider = StreamProvider<List<DoneItem>>((ref) async* {
  try {
    final box = await ref.watch(doneBoxProvider.future);
    yield box.values.toList();
    
    // Boxの変更を監視
    yield* box.watch().map((event) => box.values.toList());
  } catch (e) {
    yield <DoneItem>[];
  }
});

final todayDoneCountProvider = Provider<int>((ref) {
  final doneList = ref.watch(doneListProvider).value ?? [];
  return doneList.where((item) => item.isToday()).length;
});

final todayDoneListProvider = Provider<List<DoneItem>>((ref) {
  final doneList = ref.watch(doneListProvider).value ?? [];
  return doneList.where((item) => item.isToday()).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
});

final doneControllerProvider = Provider<DoneController>((ref) {
  return DoneController(ref);
});

// 統計用プロバイダー
final totalDoneCountProvider = Provider<int>((ref) {
  try {
    final doneListAsync = ref.watch(doneListProvider);
    if (doneListAsync.isLoading || doneListAsync.hasError) {
      return 0;
    }
    final doneList = doneListAsync.value ?? [];
    return doneList.length;
  } catch (e) {
    return 0;
  }
});

final weeklyDoneCountProvider = Provider<int>((ref) {
  try {
    final doneListAsync = ref.watch(doneListProvider);
    if (doneListAsync.isLoading || doneListAsync.hasError) {
      return 0;
    }
    final doneList = doneListAsync.value ?? [];
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    
    return doneList.where((item) {
      try {
        return item.createdAt.isAfter(weekStart.subtract(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).length;
  } catch (e) {
    return 0;
  }
});

final streakProvider = Provider<int>((ref) {
  try {
    final doneListAsync = ref.watch(doneListProvider);
    if (doneListAsync.isLoading || doneListAsync.hasError) {
      return 0;
    }
    final doneList = doneListAsync.value ?? [];
    if (doneList.isEmpty) return 0;
    
    // 日付ごとにグループ化
    final dates = <DateTime>{};
    for (var item in doneList) {
      try {
        final date = DateTime(
          item.createdAt.year,
          item.createdAt.month,
          item.createdAt.day,
        );
        dates.add(date);
      } catch (e) {
        continue;
      }
    }
    
    if (dates.isEmpty) return 0;
    
    // 日付をソート
    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));
    
    // 連続日数を計算
    int streak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    for (int i = 0; i < sortedDates.length; i++) {
      final expectedDate = todayDate.subtract(Duration(days: i));
      final date = DateTime(
        sortedDates[i].year,
        sortedDates[i].month,
        sortedDates[i].day,
      );
      
      if (date.isAtSameMomentAs(expectedDate)) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  } catch (e) {
    return 0;
  }
});

final weeklyStatsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  try {
    final doneListAsync = ref.watch(doneListProvider);
    if (doneListAsync.isLoading || doneListAsync.hasError) {
      return [];
    }
    final doneList = doneListAsync.value ?? [];
    final now = DateTime.now();
    final stats = <Map<String, dynamic>>[];
    
    // 直近7日間のデータを取得
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));
      
      final count = doneList.where((item) {
        try {
          return item.createdAt.isAfter(dateStart) && 
                 item.createdAt.isBefore(dateEnd);
        } catch (e) {
          return false;
        }
      }).length;
      
      stats.add({
        'date': dateStart,
        'count': count,
        'label': _getDayLabel(date),
      });
    }
    
    return stats;
  } catch (e) {
    return [];
  }
});

String _getDayLabel(DateTime date) {
  final weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  return '${date.month}/${date.day}(${weekdays[date.weekday - 1]})';
}

final doneByDateProvider = Provider.family<List<DoneItem>, DateTime>((ref, date) {
  try {
    final doneListAsync = ref.watch(doneListProvider);
    if (doneListAsync.isLoading || doneListAsync.hasError) {
      return [];
    }
    final doneList = doneListAsync.value ?? [];
    final dateStart = DateTime(date.year, date.month, date.day);
    final dateEnd = dateStart.add(const Duration(days: 1));
    
    return doneList.where((item) {
      try {
        return item.createdAt.isAfter(dateStart) && 
               item.createdAt.isBefore(dateEnd);
      } catch (e) {
        return false;
      }
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  } catch (e) {
    return [];
  }
});

final datesWithDoneProvider = Provider<Set<DateTime>>((ref) {
  try {
    final doneListAsync = ref.watch(doneListProvider);
    if (doneListAsync.isLoading || doneListAsync.hasError) {
      return <DateTime>{};
    }
    final doneList = doneListAsync.value ?? [];
    final dates = <DateTime>{};
    
    for (var item in doneList) {
      try {
        final date = DateTime(
          item.createdAt.year,
          item.createdAt.month,
          item.createdAt.day,
        );
        dates.add(date);
      } catch (e) {
        continue;
      }
    }
    
    return dates;
  } catch (e) {
    return <DateTime>{};
  }
});

class DoneController {
  final Ref ref;

  DoneController(this.ref);

  Future<void> addDone(String text) async {
    if (text.trim().isEmpty) return;
    
    final box = await ref.read(doneBoxProvider.future);
    final item = DoneItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      createdAt: DateTime.now(),
      category: Category.uncategorized, // 初期値は未分類
    );
    await box.add(item);
    
    // 非同期でカテゴリー判定を実行（バックグラウンド処理）
    _classifyCategoryAsync(item.id, text.trim());
    
    // バッジを更新（非同期）
    _updateBadgesAsync();
  }

  /// バッジを非同期で更新
  Future<void> _updateBadgesAsync() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final doneList = ref.read(doneListProvider).value ?? [];
      final badgeController = ref.read(badgeControllerProvider);
      await badgeController.updateBadgesFromDoneList(doneList);
    } catch (e) {
      // エラーハンドリング
    }
  }


  /// 非同期でカテゴリー判定を行い、DBを更新
  Future<void> _classifyCategoryAsync(String id, String text) async {
    try {
      // 少し遅延させて、UIの反応を妨げないようにする
      await Future.delayed(const Duration(milliseconds: 300));
      
      // カテゴリー判定を実行
      final category = await AsyncCategoryService.classifyAsync(text);
      
      // DBを更新
      final box = await ref.read(doneBoxProvider.future);
      final item = box.values.firstWhere((item) => item.id == id);
      if (item.category != category) {
        item.category = category;
        await item.save();
      }
    } catch (e) {
      // エラーが発生してもユーザー体験に影響しないよう、サイレントに処理
      // 必要に応じてログ出力
    }
  }

  /// カテゴリーを手動で更新
  Future<void> updateCategory(String id, String category) async {
    try {
      final box = await ref.read(doneBoxProvider.future);
      final item = box.values.firstWhere((item) => item.id == id);
      item.category = category;
      await item.save();
    } catch (e) {
      // エラーハンドリング
    }
  }

  Future<void> deleteDone(String id) async {
    final box = await ref.read(doneBoxProvider.future);
    final item = box.values.firstWhere((item) => item.id == id);
    await item.delete();
  }

  /// 今日のDoneを一括削除
  Future<void> deleteTodayDone() async {
    try {
      final box = await ref.read(doneBoxProvider.future);
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final itemsToDelete = box.values.where((item) {
        return item.createdAt.isAfter(todayStart) &&
               item.createdAt.isBefore(todayEnd);
      }).toList();

      for (var item in itemsToDelete) {
        await item.delete();
      }
    } catch (e) {
      // エラーハンドリング
    }
  }

  /// すべてのDoneを削除（完全初期化）
  Future<void> deleteAllDone() async {
    try {
      final box = await ref.read(doneBoxProvider.future);
      await box.clear();
    } catch (e) {
      // エラーハンドリング
    }
  }
}
