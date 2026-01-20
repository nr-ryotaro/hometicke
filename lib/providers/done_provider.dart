import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/done_item.dart';

final doneBoxProvider = FutureProvider<Box<DoneItem>>((ref) async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(DoneItemAdapter());
  }
  return await Hive.openBox<DoneItem>('done_items');
});

final doneListProvider = StreamProvider<List<DoneItem>>((ref) async* {
  final box = await ref.watch(doneBoxProvider.future);
  yield box.values.toList();
  
  // Boxの変更を監視
  yield* box.watch().map((event) => box.values.toList());
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
    );
    await box.add(item);
  }

  Future<void> deleteDone(String id) async {
    final box = await ref.read(doneBoxProvider.future);
    final item = box.values.firstWhere((item) => item.id == id);
    await item.delete();
  }
}
