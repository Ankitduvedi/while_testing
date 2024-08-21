import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier to manage the state
class IndexNotifier extends StateNotifier<int> {
  IndexNotifier() : super(0);

  // Function to set the currentIndex
  void setCurrentIndex(int newIndex) {
    state = newIndex;
  }
}

final indexProvider = StateNotifierProvider<IndexNotifier, int>((ref) {
  return IndexNotifier();
});
