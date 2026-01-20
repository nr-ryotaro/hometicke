import 'package:hive/hive.dart';

part 'done_item.g.dart';

@HiveType(typeId: 0)
class DoneItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final DateTime createdAt;

  DoneItem({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  bool isToday() {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }
}
