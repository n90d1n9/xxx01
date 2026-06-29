import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/attachment.dart';
import '../models/location.dart';
import '../models/message.dart';
import '../models/message_reaction.dart';
import '../models/voice_note.dart';

final messagesProvider =
    StateNotifierProvider.family<MessagesNotifier, List<Message>, String>((
      ref,
      roomId,
    ) {
      return MessagesNotifier(roomId);
    });

class MessagesNotifier extends StateNotifier<List<Message>> {
  final String roomId;

  MessagesNotifier(this.roomId) : super(_mockMessages);

  static final List<Message> _mockMessages = [
    Message(
      id: '1',
      senderId: 'user1',
      senderName: 'John Doe',
      content: 'Hey everyone! How\'s the project going? 🚀',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      isMe: false,
      status: MessageStatus.read,
      reactions: [
        MessageReaction(
          emoji: '👍',
          userId: 'me',
          userName: 'Me',
          timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 50)),
        ),
      ],
    ),
    Message(
      id: '2',
      senderId: 'me',
      senderName: 'Me',
      content: 'Going great! Just finished the UI mockups. Check them out! ✨',
      timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
      isMe: true,
      status: MessageStatus.read,
      attachments: [
        Attachment(
          id: 'att1',
          name: 'mockup.png',
          url: 'https://via.placeholder.com/300x200',
          type: AttachmentType.image,
        ),
      ],
    ),
    Message(
      id: '3',
      senderId: 'user2',
      senderName: 'Sarah',
      content: 'Looks amazing! 🎉 Love the color scheme',
      timestamp: DateTime.now().subtract(Duration(minutes: 45)),
      isMe: false,
      status: MessageStatus.delivered,
      replyToId: '2',
      reactions: [
        MessageReaction(
          emoji: '❤️',
          userId: 'me',
          userName: 'Me',
          timestamp: DateTime.now().subtract(Duration(minutes: 40)),
        ),
        MessageReaction(
          emoji: '🔥',
          userId: 'user1',
          userName: 'John Doe',
          timestamp: DateTime.now().subtract(Duration(minutes: 35)),
        ),
      ],
    ),
    Message(
      id: '4',
      senderId: 'user1',
      senderName: 'John Doe',
      content: '',
      timestamp: DateTime.now().subtract(Duration(minutes: 20)),
      isMe: false,
      type: MessageType.voice,
      voiceNote: VoiceNote(
        url: 'voice_note.mp3',
        duration: Duration(seconds: 15),
        waveform: [0.2, 0.5, 0.8, 0.3, 0.9, 0.1, 0.6, 0.4, 0.7, 0.2],
      ),
    ),
    Message(
      id: '5',
      senderId: 'me',
      senderName: 'Me',
      content: 'Let me share the meeting location 📍',
      timestamp: DateTime.now().subtract(Duration(minutes: 10)),
      isMe: true,
      type: MessageType.location,
      location: Location(
        latitude: 37.7749,
        longitude: -122.4194,
        address: '123 Main St, San Francisco, CA',
        name: 'Conference Room A',
      ),
    ),
  ];

  void sendMessage(Message message) {
    state = [...state, message];
  }

  void deleteMessage(String messageId) {
    state = state.where((message) => message.id != messageId).toList();
  }

  void editMessage(String messageId, String newContent) {
    state =
        state.map((message) {
          if (message.id == messageId) {
            return message.copyWith(
              content: newContent,
              isEdited: true,
              editedAt: DateTime.now(),
            );
          }
          return message;
        }).toList();
  }

  void addReaction(String messageId, MessageReaction reaction) {
    state =
        state.map((message) {
          if (message.id == messageId) {
            final reactions = List<MessageReaction>.from(message.reactions);
            // Remove existing reaction from same user
            reactions.removeWhere(
              (r) => r.userId == reaction.userId && r.emoji == reaction.emoji,
            );
            reactions.add(reaction);
            return message.copyWith(reactions: reactions);
          }
          return message;
        }).toList();
  }

  void removeReaction(String messageId, String userId, String emoji) {
    state =
        state.map((message) {
          if (message.id == messageId) {
            final reactions =
                message.reactions
                    .where((r) => !(r.userId == userId && r.emoji == emoji))
                    .toList();
            return message.copyWith(reactions: reactions);
          }
          return message;
        }).toList();
  }

  void toggleStar(String messageId) {
    state =
        state.map((message) {
          if (message.id == messageId) {
            return message.copyWith(isStarred: !message.isStarred);
          }
          return message;
        }).toList();
  }

  void forwardMessage(String messageId, String targetRoomId) {
    final message = state.firstWhere((m) => m.id == messageId);
    final forwardedMessage = message.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isForwarded: true,
      timestamp: DateTime.now(),
    );
    // In a real app, this would forward to another room
    state = [...state, forwardedMessage];
  }
}
