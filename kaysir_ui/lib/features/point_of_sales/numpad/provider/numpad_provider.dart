import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class NumpadNotifier extends StateNotifier<String> {
  NumpadNotifier() : super('');

  void append(String value) {
    state += value;
  }

  void clear() {
    state = '';
  }

  void backspace() {
    if (state.isNotEmpty) {
      state = state.substring(0, state.length - 1);
    }
  }
}

final numpadProvider = StateNotifierProvider<NumpadNotifier, String>((ref) {
  return NumpadNotifier();
});
