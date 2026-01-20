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

  @HiveField(3)
  String? _category;

  DoneItem({
    required this.id,
    required this.text,
    required this.createdAt,
    String? category,
  }) : _category = category ?? 'Uncategorized';

  String get category => _category ?? 'Uncategorized';
  
  set category(String value) {
    _category = value;
  }

  bool isToday() {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }
}
