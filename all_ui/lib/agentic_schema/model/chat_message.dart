import 'system_message.dart';

class ChatMessage {
  final String id;
  final String userId;
  final String userName;
  final String message; // This is the actual message content
  final DateTime timestamp;
  final String? replyToId;
  final ChatMessageType? type;
  final SystemMessageType? systemType;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    this.replyToId,
    this.type,
    this.systemType,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'replyToId': replyToId,
    'type': type?.name,
    'systemType': systemType?.name,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      replyToId: json['replyToId'],
      type: json['type'] != null ? _parseChatMessageType(json['type']) : null,
      systemType: json['systemType'] != null
          ? _parseSystemMessageType(json['systemType'])
          : null,
    );
  }

  static ChatMessageType _parseChatMessageType(dynamic value) {
    if (value is ChatMessageType) return value;
    final stringValue = value.toString();
    return ChatMessageType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => ChatMessageType.user,
    );
  }

  static SystemMessageType _parseSystemMessageType(dynamic value) {
    if (value is SystemMessageType) return value;
    final stringValue = value.toString();
    return SystemMessageType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => SystemMessageType.info,
    );
  }
}

enum ChatMessageType { user, system }
