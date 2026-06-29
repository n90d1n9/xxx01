import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../model/chat_message.dart';
import '../model/collaboration_event.dart';
import '../model/collaborative_user.dart';
import '../model/system_message.dart';
import '../schema/common/position.dart';
import '../schema/workflow/workflow_edge.dart';
import '../schema/workflow/workflow_node.dart';
import 'collaboration_service.dart';
import 'collaboration_state.dart';
import 'cursor_provider.dart';
import 'workflow/workflow_provider.dart';

final collaborationProvider =
    StateNotifierProvider.family<
      CollaborationNotifier,
      CollaborationState,
      String
    >((ref, workflowId) {
      return CollaborationNotifier(workflowId, ref);
    });

class CollaborationNotifier extends StateNotifier<CollaborationState> {
  final String workflowId;
  final Ref ref;
  CollaborationService? _service;
  StreamSubscription<CollaborationEvent>? _eventSubscription;
  Timer? _userCleanupTimer;
  Timer? _cursorBroadcastTimer;
  Offset? _lastCursorPosition;
  List<String>? _lastSelectedNodeIds;

  CollaborationNotifier(this.workflowId, this.ref)
    : super(CollaborationState.initial(workflowId));

  Future<void> connect({
    required String userId,
    required String userName,
    required String token,
    String email = '',
    Map<String, String>? headers,
    Duration connectionTimeout = const Duration(seconds: 10),
  }) async {
    if (state.connectionStatus == ConnectionStatus.connecting) {
      return; // Already connecting
    }

    state = state.copyWith(
      connectionStatus: ConnectionStatus.connecting,
      error: null,
    );

    try {
      final service = CollaborationService(workflowId, userId, userName, token);
      await service.connect(headers: headers).timeout(connectionTimeout);

      _service = service;

      // Generate user color and create current user
      final color = _generateUserColor(userId);
      final currentUser = CollaborativeUser(
        id: userId,
        name: userName,
        email: email,
        color: color,
        lastSeen: DateTime.now(),
        isActive: true,
        cursorPosition: null,
        selectedNodeIds: null,
      );

      // Set up event subscription
      _eventSubscription = service.events.listen(
        _handleEvent,
        onError: _handleConnectionError,
        onDone: _handleConnectionClosed,
      );

      // Start timers
      _startUserCleanupTimer();
      _startCursorBroadcastTimer();

      // Send user joined event
      service.userJoined();

      state = state.copyWith(
        connectionStatus: ConnectionStatus.connected,
        currentUser: currentUser,
        users: {userId: currentUser},
        lastActivity: DateTime.now(),
        error: null,
      );

      debugPrint('Collaboration connected for workflow: $workflowId');
    } catch (e, stackTrace) {
      _handleConnectionError(e, stackTrace);
      rethrow;
    }
  }

  void _handleEvent(CollaborationEvent event) {
    try {
      // Update last activity timestamp
      state = state.copyWith(lastActivity: DateTime.now());

      switch (event.type) {
        case CollaborationEventType.userJoined:
          _handleUserJoined(event);
          break;
        case CollaborationEventType.userLeft:
          _handleUserLeft(event);
          break;
        case CollaborationEventType.cursorMoved:
          _handleCursorMoved(event);
          break;
        case CollaborationEventType.selectionChanged:
          _handleSelectionChanged(event);
          break;
        case CollaborationEventType.chatMessage:
          _handleChatMessage(event);
          break;
        case CollaborationEventType.nodeAdded:
          _handleNodeAdded(event);
          break;
        case CollaborationEventType.nodeUpdated:
          _handleNodeUpdated(event);
          break;
        case CollaborationEventType.nodeDeleted:
          _handleNodeDeleted(event);
          break;
        case CollaborationEventType.nodeMoved:
          _handleNodeMoved(event);
          break;
        case CollaborationEventType.edgeAdded:
          _handleEdgeAdded(event);
          break;
        case CollaborationEventType.edgeUpdated:
          _handleEdgeUpdated(event);
          break;
        case CollaborationEventType.edgeDeleted:
          _handleEdgeDeleted(event);
          break;
        case CollaborationEventType.workflowModified:
          _handleWorkflowModified(event);
          break;
        default:
          _handleUnknownEvent(event);
      }

      // Add to event history with limit
      final updatedEvents = [...state.events, event];
      if (updatedEvents.length > 1000) {
        updatedEvents.removeRange(0, updatedEvents.length - 1000);
      }

      state = state.copyWith(events: updatedEvents);
    } catch (e, stackTrace) {
      debugPrint('Error handling collaboration event: $e\n$stackTrace');
      state = state.copyWith(error: 'Event handling error: ${e.toString()}');
    }
  }

  void _handleUserJoined(CollaborationEvent event) {
    final userData = event.data['user'] ?? event.data;
    final user = CollaborativeUser.fromJson(userData);
    final updatedUsers = Map<String, CollaborativeUser>.from(state.users);
    updatedUsers[user.id] = user;

    state = state.copyWith(users: updatedUsers);
    _addSystemMessage('${user.name} joined the collaboration');
  }

  void _handleUserLeft(CollaborationEvent event) {
    final userId = event.data['userId'] as String? ?? event.userId;
    final updatedUsers = Map<String, CollaborativeUser>.from(state.users);
    final user = updatedUsers.remove(userId);

    state = state.copyWith(users: updatedUsers);

    if (user != null) {
      _addSystemMessage('${user.name} left the collaboration');
    }
  }

  void _handleCursorMoved(CollaborationEvent event) {
    final positionData = event.data['position'] as Map<String, dynamic>?;
    if (positionData == null) return;

    final position = Offset(
      (positionData['x'] as num?)?.toDouble() ?? 0,
      (positionData['y'] as num?)?.toDouble() ?? 0,
    );

    final nodeId = event.data['nodeId'] as String?;

    _updateUser(
      event.userId,
      (user) =>
          user.copyWith(cursorPosition: position, lastSeen: DateTime.now()),
    );
  }

  void _handleSelectionChanged(CollaborationEvent event) {
    final nodeIds = List<String>.from(event.data['nodeIds'] ?? []);

    _updateUser(
      event.userId,
      (user) =>
          user.copyWith(selectedNodeIds: nodeIds, lastSeen: DateTime.now()),
    );
  }

  void _handleChatMessage(CollaborationEvent event) {
    try {
      final messageData = event.data['message'] ?? event.data;
      final message = ChatMessage.fromJson(messageData);
      final updatedMessages = [...state.messages, message];

      if (updatedMessages.length > 100) {
        updatedMessages.removeRange(0, updatedMessages.length - 100);
      }

      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      debugPrint('Error parsing chat message: $e');
    }
  }

  void _handleNodeAdded(CollaborationEvent event) {
    final nodeData = event.data['node'] ?? event.data;
    final node = WorkflowNode.fromJson(nodeData);

    ref.read(workflowProvider.notifier).applyExternalChange(() {
      ref.read(workflowProvider.notifier).addNodeDirect(node);
    });

    _addSystemMessage(
      '${event.userName} added ${node.type.displayName} node',
      type: SystemMessageType.nodeUpdate,
    );
  }

  void _handleNodeUpdated(CollaborationEvent event) {
    final nodeId = event.data['nodeId'] as String?;
    final changes = event.data['changes'] as Map<String, dynamic>?;

    if (nodeId != null && changes != null) {
      ref.read(workflowProvider.notifier).applyExternalChange(() {
        ref.read(workflowProvider.notifier).applyNodeChanges(nodeId, changes);
      });

      _addSystemMessage(
        '${event.userName} updated node',
        type: SystemMessageType.nodeUpdate,
      );
    }
  }

  void _handleNodeDeleted(CollaborationEvent event) {
    final nodeId = event.data['nodeId'] as String?;

    if (nodeId != null) {
      ref.read(workflowProvider.notifier).applyExternalChange(() {
        ref.read(workflowProvider.notifier).deleteNodeDirect(nodeId);
      });

      _addSystemMessage(
        '${event.userName} deleted node',
        type: SystemMessageType.nodeUpdate,
      );
    }
  }

  void _handleNodeMoved(CollaborationEvent event) {
    final nodeId = event.data['nodeId'] as String?;
    final positionData = event.data['position'] as Map<String, dynamic>?;

    if (nodeId != null && positionData != null) {
      final position = Position(
        x: (positionData['x'] as num).toDouble(),
        y: (positionData['y'] as num).toDouble(),
      );

      ref.read(workflowProvider.notifier).applyExternalChange(() {
        ref.read(workflowProvider.notifier).moveNodeDirect(nodeId, position);
      });
    }
  }

  void _handleEdgeAdded(CollaborationEvent event) {
    final edgeData = event.data['edge'] ?? event.data;
    final edge = WorkflowEdge.fromJson(edgeData);

    ref.read(workflowProvider.notifier).applyExternalChange(() {
      ref.read(workflowProvider.notifier).addEdgeDirect(edge);
    });

    _addSystemMessage(
      '${event.userName} added connection',
      type: SystemMessageType.edgeUpdate,
    );
  }

  void _handleEdgeUpdated(CollaborationEvent event) {
    final edgeId = event.data['edgeId'] as String?;
    final changes = event.data['changes'] as Map<String, dynamic>?;

    if (edgeId != null && changes != null) {
      ref.read(workflowProvider.notifier).applyExternalChange(() {
        ref.read(workflowProvider.notifier).applyEdgeChanges(edgeId, changes);
      });

      _addSystemMessage(
        '${event.userName} updated connection',
        type: SystemMessageType.edgeUpdate,
      );
    }
  }

  void _handleEdgeDeleted(CollaborationEvent event) {
    final edgeId = event.data['edgeId'] as String?;

    if (edgeId != null) {
      ref.read(workflowProvider.notifier).applyExternalChange(() {
        ref.read(workflowProvider.notifier).deleteEdgeDirect(edgeId);
      });

      _addSystemMessage(
        '${event.userName} deleted connection',
        type: SystemMessageType.edgeUpdate,
      );
    }
  }

  void _handleWorkflowModified(CollaborationEvent event) {
    final modification = event.data['modification'] as String?;
    if (modification != null) {
      _addSystemMessage(
        '${event.userName} $modification',
        type: SystemMessageType.workflowUpdate,
      );
    }
  }

  void _handleUnknownEvent(CollaborationEvent event) {
    debugPrint('Unknown collaboration event type: ${event.type}');
  }

  void _updateUser(
    String userId,
    CollaborativeUser Function(CollaborativeUser) update,
  ) {
    final updatedUsers = Map<String, CollaborativeUser>.from(state.users);
    final existingUser = updatedUsers[userId];

    if (existingUser != null) {
      updatedUsers[userId] = update(existingUser);
      state = state.copyWith(users: updatedUsers);
    }
  }

  void _addSystemMessage(
    String text, {
    SystemMessageType type = SystemMessageType.info,
  }) {
    final message = ChatMessage(
      id: 'system_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'system', // Use 'system' as userId
      userName: 'System', // Use 'System' as userName
      message: text, // Use text as the message content
      timestamp: DateTime.now(),
      replyToId: null,
    );

    final updatedMessages = [...state.messages, message];
    if (updatedMessages.length > 100) {
      updatedMessages.removeRange(0, updatedMessages.length - 100);
    }

    state = state.copyWith(messages: updatedMessages);
  }

  void _handleConnectionError(Object error, [StackTrace? stackTrace]) {
    debugPrint('Collaboration connection error: $error\n$stackTrace');

    state = state.copyWith(
      connectionStatus: ConnectionStatus.disconnected,
      error: error.toString(),
    );

    if (state.wasConnected) {
      _scheduleReconnection();
    }
  }

  void _handleConnectionClosed() {
    debugPrint('Collaboration connection closed');

    state = state.copyWith(connectionStatus: ConnectionStatus.disconnected);

    if (state.wasConnected) {
      _scheduleReconnection();
    }
  }

  void _scheduleReconnection() {
    if (state.connectionStatus == ConnectionStatus.reconnecting) return;

    state = state.copyWith(connectionStatus: ConnectionStatus.reconnecting);

    Future.delayed(const Duration(seconds: 3), () {
      if (state.connectionStatus == ConnectionStatus.reconnecting) {
        _reconnect();
      }
    });
  }

  Future<void> _reconnect() async {
    if (_service == null || state.currentUser == null) return;

    try {
      final currentUser = state.currentUser!;
      await connect(
        userId: currentUser.id,
        userName: currentUser.name,
        token: '', // Token should be stored securely
        email: currentUser.email,
      );
    } catch (e) {
      final delay = Duration(seconds: 5 * (state.reconnectionAttempts + 1));
      Future.delayed(delay, _reconnect);

      state = state.copyWith(
        reconnectionAttempts: state.reconnectionAttempts + 1,
      );
    }
  }

  void _startUserCleanupTimer() {
    _userCleanupTimer?.cancel();
    _userCleanupTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _cleanupInactiveUsers();
    });
  }

  void _startCursorBroadcastTimer() {
    _cursorBroadcastTimer?.cancel();
    _cursorBroadcastTimer = Timer.periodic(const Duration(milliseconds: 100), (
      _,
    ) {
      _broadcastCursorIfNeeded();
    });
  }

  void _cleanupInactiveUsers() {
    final now = DateTime.now();
    final threshold = now.subtract(const Duration(minutes: 2));

    final activeUsers = state.users.values.where((user) {
      return user.lastSeen.isAfter(threshold) ||
          user.id == state.currentUser?.id;
    }).toList();

    if (activeUsers.length != state.users.length) {
      final updatedUsers = {for (var user in activeUsers) user.id: user};
      state = state.copyWith(users: updatedUsers);
    }
  }

  void _broadcastCursorIfNeeded() {
    final workflowState = ref.read(workflowProvider);
    final currentCursor = ref.read(cursorPositionProvider);
    final currentSelection = workflowState.selectedNodes
        .map((n) => n.id)
        .toList();

    // Broadcast cursor if changed
    if (currentCursor != _lastCursorPosition) {
      _lastCursorPosition = currentCursor;
      if (currentCursor != null && _service?.isConnected == true) {
        _service!.updateCursor(currentCursor);
      }
    }

    // Broadcast selection if changed
    if (!_listEquals(currentSelection, _lastSelectedNodeIds)) {
      _lastSelectedNodeIds = currentSelection;
      if (_service?.isConnected == true) {
        _service!.updateSelection(currentSelection);
      }
    }
  }

  bool _listEquals(List<String>? a, List<String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Public API methods
  void sendChatMessage(String text, {String? replyToId, String? threadId}) {
    if (_service?.isConnected == true) {
      _service!.sendChatMessage(text, replyToId: replyToId, threadId: threadId);
    }
  }

  void updateCursor(Offset position, {String? nodeId}) {
    _lastCursorPosition = position;
    if (_service?.isConnected == true) {
      _service!.updateCursor(position, nodeId: nodeId);
    }
  }

  void updateSelection(List<String> nodeIds) {
    _lastSelectedNodeIds = nodeIds;
    if (_service?.isConnected == true) {
      _service!.updateSelection(nodeIds);
    }
  }

  // Workflow collaboration methods
  void notifyNodeAdded(WorkflowNode node) {
    if (_service?.isConnected == true) {
      _service!.sendEvent(
        CollaborationEvent(
          id: const Uuid().v4(),
          type: CollaborationEventType.nodeAdded,
          userId: state.currentUser?.id ?? '',
          userName: state.currentUser?.name ?? '',
          timestamp: DateTime.now(),
          data: {'node': node.toJson()},
        ),
      );
    }
  }

  void notifyNodeUpdated(String nodeId, Map<String, dynamic> changes) {
    if (_service?.isConnected == true) {
      _service!.sendEvent(
        CollaborationEvent(
          id: const Uuid().v4(),
          type: CollaborationEventType.nodeUpdated,
          userId: state.currentUser?.id ?? '',
          userName: state.currentUser?.name ?? '',
          timestamp: DateTime.now(),
          data: {'nodeId': nodeId, 'changes': changes},
        ),
      );
    }
  }

  void notifyNodeDeleted(String nodeId) {
    if (_service?.isConnected == true) {
      _service!.sendEvent(
        CollaborationEvent(
          id: const Uuid().v4(),
          type: CollaborationEventType.nodeDeleted,
          userId: state.currentUser?.id ?? '',
          userName: state.currentUser?.name ?? '',
          timestamp: DateTime.now(),
          data: {'nodeId': nodeId},
        ),
      );
    }
  }

  void notifyNodeMoved(String nodeId, Position position) {
    if (_service?.isConnected == true) {
      _service!.sendEvent(
        CollaborationEvent(
          id: const Uuid().v4(),
          type: CollaborationEventType.nodeMoved,
          userId: state.currentUser?.id ?? '',
          userName: state.currentUser?.name ?? '',
          timestamp: DateTime.now(),
          data: {
            'nodeId': nodeId,
            'position': {'x': position.x, 'y': position.y},
          },
        ),
      );
    }
  }

  void notifyEdgeAdded(WorkflowEdge edge) {
    if (_service?.isConnected == true) {
      _service!.sendEvent(
        CollaborationEvent(
          id: const Uuid().v4(),
          type: CollaborationEventType.edgeAdded,
          userId: state.currentUser?.id ?? '',
          userName: state.currentUser?.name ?? '',
          timestamp: DateTime.now(),
          data: {'edge': edge.toJson()},
        ),
      );
    }
  }

  void notifyEdgeUpdated(String edgeId, Map<String, dynamic> changes) {
    if (_service?.isConnected == true) {
      _service!.sendEvent(
        CollaborationEvent(
          id: const Uuid().v4(),
          type: CollaborationEventType.edgeUpdated,
          userId: state.currentUser?.id ?? '',
          userName: state.currentUser?.name ?? '',
          timestamp: DateTime.now(),
          data: {'edgeId': edgeId, 'changes': changes},
        ),
      );
    }
  }

  void notifyEdgeDeleted(String edgeId) {
    if (_service?.isConnected == true) {
      _service!.sendEvent(
        CollaborationEvent(
          id: const Uuid().v4(),
          type: CollaborationEventType.edgeDeleted,
          userId: state.currentUser?.id ?? '',
          userName: state.currentUser?.name ?? '',
          timestamp: DateTime.now(),
          data: {'edgeId': edgeId},
        ),
      );
    }
  }

  void notifyWorkflowModified(String modification) {
    if (_service?.isConnected == true) {
      _service!.sendEvent(
        CollaborationEvent(
          id: const Uuid().v4(),
          type: CollaborationEventType.workflowModified,
          userId: state.currentUser?.id ?? '',
          userName: state.currentUser?.name ?? '',
          timestamp: DateTime.now(),
          data: {'modification': modification},
        ),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }

  void disconnect() {
    _eventSubscription?.cancel();
    _eventSubscription = null;

    _userCleanupTimer?.cancel();
    _userCleanupTimer = null;

    _cursorBroadcastTimer?.cancel();
    _cursorBroadcastTimer = null;

    _service?.disconnect();
    _service = null;

    state = CollaborationState.initial(workflowId);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  Color _generateUserColor(String userId) {
    final colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
      Colors.cyan.shade400,
      Colors.amber.shade400,
    ];

    final hash = userId.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
