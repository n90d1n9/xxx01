import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/chart_theme.dart';
import '../models/chat_room.dart';

final chatThemeProvider = StateProvider<ChatTheme>((ref) => ChatTheme.default_);

final searchQueryProvider = StateProvider<String>((ref) => '');

final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, List<ChatRoom>>((ref) {
      return ChatRoomsNotifier();
    });

final selectedRoomProvider = StateProvider<ChatRoom?>((ref) => null);

// Enhanced State Notifiers
class ChatRoomsNotifier extends StateNotifier<List<ChatRoom>> {
  ChatRoomsNotifier() : super(_mockRooms);

  static final List<ChatRoom> _mockRooms = [
    ChatRoom(
      id: '1',
      name: 'Design Team',
      avatar: 'https://via.placeholder.com/50',
      lastMessage: 'Let\'s review the new mockups 🎨',
      lastActivity: DateTime.now().subtract(Duration(minutes: 5)),
      unreadCount: 3,
      isGroup: true,
      isOnline: true,
      isPinned: true,
      participants: ['user1', 'user2', 'user3'],
      type: RoomType.group,
      theme: ChatTheme.ocean,
      description: 'Design team collaboration space',
      admins: ['user1'],
    ),
    ChatRoom(
      id: '2',
      name: 'Sarah Johnson',
      avatar: 'https://via.placeholder.com/50',
      lastMessage: 'Thanks for the update! 😊',
      lastActivity: DateTime.now().subtract(Duration(hours: 2)),
      unreadCount: 0,
      isGroup: false,
      isOnline: true,
      lastSeen: DateTime.now().subtract(Duration(minutes: 30)),
      participants: ['user1'],
      type: RoomType.personal,
      theme: ChatTheme.sunset,
    ),
    ChatRoom(
      id: '3',
      name: 'Project Alpha',
      avatar: 'https://via.placeholder.com/50',
      lastMessage: 'Meeting at 3 PM today 📅',
      lastActivity: DateTime.now().subtract(Duration(hours: 4)),
      unreadCount: 1,
      isGroup: true,
      isOnline: false,
      participants: ['user1', 'user2', 'user3', 'user4'],
      type: RoomType.group,
      theme: ChatTheme.forest,
      description: 'Project Alpha development team',
      admins: ['user1', 'user2'],
    ),
    ChatRoom(
      id: '4',
      name: 'Tech News Bot',
      avatar: 'https://via.placeholder.com/50',
      lastMessage: 'Latest tech updates available 🤖',
      lastActivity: DateTime.now().subtract(Duration(hours: 6)),
      unreadCount: 5,
      isGroup: false,
      isOnline: true,
      participants: ['bot1'],
      type: RoomType.bot,
      theme: ChatTheme.default_,
    ),
  ];

  void addRoom(ChatRoom room) {
    state = [room, ...state];
  }

  void updateRoom(ChatRoom updatedRoom) {
    state =
        state.map((room) {
          return room.id == updatedRoom.id ? updatedRoom : room;
        }).toList();
  }

  void togglePin(String roomId) {
    state =
        state.map((room) {
          if (room.id == roomId) {
            return room.copyWith(isPinned: !room.isPinned);
          }
          return room;
        }).toList();
  }

  void toggleMute(String roomId) {
    state =
        state.map((room) {
          if (room.id == roomId) {
            return room.copyWith(isMuted: !room.isMuted);
          }
          return room;
        }).toList();
  }

  void archiveRoom(String roomId) {
    state =
        state.map((room) {
          if (room.id == roomId) {
            return room.copyWith(isArchived: true);
          }
          return room;
        }).toList();
  }

  void updateLastMessage(String roomId, String message) {
    state =
        state.map((room) {
          if (room.id == roomId) {
            return room.copyWith(
              lastMessage: message,
              lastActivity: DateTime.now(),
            );
          }
          return room;
        }).toList();
  }

  List<ChatRoom> get pinnedRooms =>
      state.where((room) => room.isPinned && !room.isArchived).toList();
  List<ChatRoom> get unpinnedRooms =>
      state.where((room) => !room.isPinned && !room.isArchived).toList();
  List<ChatRoom> get archivedRooms =>
      state.where((room) => room.isArchived).toList();
}
