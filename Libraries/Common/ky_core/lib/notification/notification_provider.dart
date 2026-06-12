import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../websocket/websocket_services.dart';
import '../websocket/ws_provider.dart';
import 'models/notification_message.dart';
import 'models/notification_state.dart';
import 'notification_service.dart';

// Client ID provider for notifications
final notificationClientIdProvider = Provider<String>((ref) {
  return const Uuid().v4(); // Generates a random UUID
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final clientId = ref.watch(notificationClientIdProvider);
      final wsService = ref.watch(
        webSocketServiceProvider('notification/$clientId'),
      );
      final service = ref.read(notificationServiceProvider);
      return NotificationNotifier(ref, service, wsService);
    });

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _notificationService;
  final WebSocketService _wsService;
  StreamSubscription? _messageSubscription;

  NotificationNotifier(Ref ref, this._notificationService, this._wsService)
    : super(const NotificationState()) {
    _setupMessageListener();
  }

  void _setupMessageListener() {
    _messageSubscription = _wsService.messageStream.listen((message) {
      try {
        final jsonData = jsonDecode(message.toString());
        final notificationMessage = NotificationMessage.fromJson(jsonData);

        final updatedMessages = [notificationMessage, ...state.messages];
        final trimmedMessages = updatedMessages.length > 100
            ? updatedMessages.take(100).toList()
            : updatedMessages;

        state = state.copyWith(messages: trimmedMessages);

        // Trigger notification based on message type
        _notificationService.handleNotification(notificationMessage);
      } catch (e) {
        debugPrint('Error parsing message: $e');
        state = state.copyWith(error: 'Error parsing message: $e');
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
