import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationIndexProvider = StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});

class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0);

  void changeTab(int index) {
    state = index;
  }
}
