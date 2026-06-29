import '../model/chat_message.dart';
import '../model/collaboration_event.dart';
import '../model/collaborative_user.dart';
import '../model/system_message.dart';

enum ConnectionStatus { disconnected, connecting, connected, reconnecting }

class CollaborationState {
  final bool isConnected;
  final CollaborativeUser? currentUser;
  final Map<String, CollaborativeUser> users;
  final List<ChatMessage> messages;
  final List<CollaborationEvent> events;
  final String? error;
  final bool isReconnecting;
  final Map<String, dynamic> permissions;
  final String workflowId;
  final ConnectionStatus connectionStatus;
  final DateTime lastActivity;
  final int reconnectionAttempts;
  final List<SystemMessage> systemMessages;

  CollaborationState({
    this.isConnected = false,
    this.currentUser,
    required this.users,
    this.messages = const [],
    this.events = const [],
    this.error,
    this.isReconnecting = false,
    this.permissions = const {},
    required this.workflowId,
    required this.connectionStatus,
    this.systemMessages = const [],
    required this.lastActivity,
    required this.reconnectionAttempts,
  });

  bool get isConnecting => connectionStatus == ConnectionStatus.connecting;

  bool get wasConnected => connectionStatus != ConnectionStatus.disconnected;

  factory CollaborationState.initial(String workflowId) {
    return CollaborationState(
      workflowId: workflowId,
      connectionStatus: ConnectionStatus.disconnected,
      users: const {},
      messages: const [],
      systemMessages: const [],
      events: const [],
      lastActivity: DateTime.now(),
      reconnectionAttempts: 0,
    );
  }
  CollaborationState copyWith({
    bool? isConnected,
    CollaborativeUser? currentUser,
    Map<String, CollaborativeUser>? users,
    List<ChatMessage>? messages,
    List<CollaborationEvent>? events,
    String? error,
    bool? isReconnecting,
    Map<String, dynamic>? permissions,
    ConnectionStatus? connectionStatus,
    DateTime? lastActivity,
    int? reconnectionAttempts,
    List<SystemMessage>? systemMessages,
  }) {
    return CollaborationState(
      workflowId: workflowId,
      isConnected: isConnected ?? this.isConnected,
      currentUser: currentUser ?? this.currentUser,
      users: users ?? this.users,
      messages: messages ?? this.messages,
      events: events ?? this.events,
      error: error ?? this.error,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      permissions: permissions ?? this.permissions,
      systemMessages: systemMessages ?? this.systemMessages,
      connectionStatus: connectionStatus ?? this.connectionStatus,

      lastActivity: lastActivity ?? this.lastActivity,
      reconnectionAttempts: reconnectionAttempts ?? this.reconnectionAttempts,
    );
  }
}
