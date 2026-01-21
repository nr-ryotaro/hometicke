import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/badge.dart';
import '../models/done_item.dart';
import '../services/badge_service.dart';
import '../services/category_service.dart';

final badgeBoxProvider = FutureProvider<Box<Badge>>((ref) async {
  try {
    // Hiveはmain.dartで初期化済み
    final box = await Hive.openBox<Badge>('badges');
    
    // 初期バッジを作成（まだ獲得していない状態）
    await _initializeBadges(box);
    
    return box;
  } catch (e) {
    // エラー時は空のBoxを返す（後で再試行可能）
    rethrow;
  }
});

Future<void> _initializeBadges(Box<Badge> box) async {
  final categories = [
    Category.work,
    Category.growth,
    Category.hobby,
    Category.health,
    Category.life,
  ];
  final ranks = [3, 7, 30, 100];

  for (final category in categories) {
    for (final rank in ranks) {
      final badgeId = '${category}_$rank';
      if (!box.containsKey(badgeId)) {
        final badge = Badge(
          id: badgeId,
          category: category,
          rank: rank,
          isEarned: false,
        );
        await box.put(badgeId, badge);
      }
    }
  }
}

final badgeListProvider = StreamProvider<List<Badge>>((ref) async* {
  try {
    final boxAsync = ref.watch(badgeBoxProvider);
    if (boxAsync.isLoading) {
      yield <Badge>[];
      return;
    }
    if (boxAsync.hasError) {
      yield <Badge>[];
      return;
    }
    final box = boxAsync.value!;
    yield box.values.toList();
    
    yield* box.watch().map((event) {
      try {
        return box.values.toList();
      } catch (e) {
        return <Badge>[];
      }
    });
  } catch (e) {
    yield <Badge>[];
  }
});

final badgeByCategoryProvider = Provider.family<List<Badge>, String>((ref, category) {
  final badgeList = ref.watch(badgeListProvider).value ?? [];
  return badgeList.where((badge) => badge.category == category).toList()
    ..sort((a, b) => a.rank.compareTo(b.rank));
});

final badgeControllerProvider = Provider<BadgeController>((ref) {
  return BadgeController(ref);
});

class BadgeController {
  final Ref ref;

  BadgeController(this.ref);

  /// Doneリストからバッジを計算して更新
  Future<void> updateBadgesFromDoneList(List<DoneItem> doneList) async {
    try {
      final box = await ref.read(badgeBoxProvider.future);
      final categories = [
        Category.work,
        Category.growth,
        Category.hobby,
        Category.health,
        Category.life,
      ];

      for (final category in categories) {
        final streakDays = BadgeService.calculateStreakDays(category, doneList);
        final earnedRanks = BadgeService.checkAndAwardBadges(category, streakDays);

        for (final rank in BadgeService.badgeRanks) {
          final badgeId = '${category}_$rank';
          final existingBadge = box.get(badgeId);

          if (existingBadge != null) {
            final isEarned = earnedRanks.contains(rank);
            final shouldUpdate = existingBadge.isEarned != isEarned ||
                (isEarned && existingBadge.earnedDate == null);

            if (shouldUpdate) {
              final updatedBadge = Badge(
                id: badgeId,
                category: category,
                rank: rank,
                isEarned: isEarned,
                earnedDate: isEarned && existingBadge.earnedDate == null
                    ? DateTime.now()
                    : existingBadge.earnedDate,
              );
              await box.put(badgeId, updatedBadge);
            }
          }
        }
      }
    } catch (e) {
      // エラーハンドリング
    }
  }

  /// 特定のバッジを手動で獲得済みにする
  Future<void> awardBadge(String badgeId) async {
    try {
      final box = await ref.read(badgeBoxProvider.future);
      final badge = box.get(badgeId);
      if (badge != null && !badge.isEarned) {
        final updatedBadge = Badge(
          id: badge.id,
          category: badge.category,
          rank: badge.rank,
          isEarned: true,
          earnedDate: DateTime.now(),
        );
        await box.put(badgeId, updatedBadge);
      }
    } catch (e) {
      // エラーハンドリング
    }
  }
}
