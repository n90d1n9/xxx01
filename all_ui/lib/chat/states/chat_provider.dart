import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/message.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState());

  void sendMessage(String roomId, Message message) {
    // Implementation for sending message
  }

  void startTyping(String roomId) {
    // Implementation for starting typing indicator
  }

  void stopTyping(String roomId) {
    // Implementation for stopping typing indicator
  }

  void addReaction(
    String roomId,
    String messageId,
    String emoji,
    String userId,
  ) {
    // Implementation for adding reaction
  }

  void deleteMessage(String roomId, String messageId) {
    // Implementation for deleting message
  }

  void toggleMute(String roomId) {
    // Implementation for toggling mute
  }

  void clearChat(String roomId) {
    // Implementation for clearing chat
  }
}

class ChatState {
  // Chat state properties
}
