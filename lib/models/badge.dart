import 'package:hive/hive.dart';

part 'badge.g.dart';

@HiveType(typeId: 1)
class Badge extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final int rank; // 3, 7, 30, 100

  @HiveField(3)
  final DateTime? earnedDate;

  @HiveField(4)
  final bool isEarned;

  Badge({
    required this.id,
    required this.category,
    required this.rank,
    this.earnedDate,
    this.isEarned = false,
  });

  String get rankName {
    switch (rank) {
      case 3:
        return '3日';
      case 7:
        return '7日';
      case 30:
        return '30日';
      case 100:
        return '100日';
      default:
        return '$rank日';
    }
  }
}
