import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final typingUsersProvider =
    StateNotifierProvider.family<TypingNotifier, List<String>, String>((
      ref,
      roomId,
    ) {
      return TypingNotifier(roomId);
    });

class TypingNotifier extends StateNotifier<List<String>> {
  final String roomId;

  TypingNotifier(this.roomId) : super([]);

  void startTyping(String userId) {
    if (!state.contains(userId)) {
      state = [...state, userId];
    }
  }

  void stopTyping(String userId) {
    state = state.where((id) => id != userId).toList();
  }
}

class TypingUsersNotifier extends StateNotifier<List<String>> {
  final String roomId;

  TypingUsersNotifier(this.roomId) : super([]);
}
