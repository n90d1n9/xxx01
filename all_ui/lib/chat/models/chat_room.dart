import 'chart_theme.dart';

enum RoomType { personal, group, channel, bot }

class ChatRoom {
  final String id;
  final String name;
  final String? avatar;
  final String lastMessage;
  final DateTime lastActivity;
  final int unreadCount;
  final bool isGroup;
  final bool isMuted;
  final bool isPinned;
  final bool isArchived;
  final bool isOnline;
  final DateTime? lastSeen;
  final List<String> participants;
  final String? description;
  final List<String> admins;
  final RoomType type;
  final ChatTheme theme;

  ChatRoom({
    required this.id,
    required this.name,
    this.avatar,
    required this.lastMessage,
    required this.lastActivity,
    this.unreadCount = 0,
    this.isGroup = false,
    this.isMuted = false,
    this.isPinned = false,
    this.isArchived = false,
    this.isOnline = false,
    this.lastSeen,
    this.participants = const [],
    this.description,
    this.admins = const [],
    this.type = RoomType.personal,
    this.theme = ChatTheme.default_,
  });

  ChatRoom copyWith({
    String? id,
    String? name,
    String? avatar,
    String? lastMessage,
    DateTime? lastActivity,
    int? unreadCount,
    bool? isGroup,
    bool? isMuted,
    bool? isPinned,
    bool? isArchived,
    bool? isOnline,
    DateTime? lastSeen,
    List<String>? participants,
    String? description,
    List<String>? admins,
    RoomType? type,
    ChatTheme? theme,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      lastMessage: lastMessage ?? this.lastMessage,
      lastActivity: lastActivity ?? this.lastActivity,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      isMuted: isMuted ?? this.isMuted,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      participants: participants ?? this.participants,
      description: description ?? this.description,
      admins: admins ?? this.admins,
      type: type ?? this.type,
      theme: theme ?? this.theme,
    );
  }
}
