// Collaboration Service (Mock WebSocket)
import 'dart:async';

import 'package:flutter/material.dart';

class CollaborationService {
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  bool _connected = false;
  Timer? _heartbeatTimer;

  Future<void> connect(String projectId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _connected = true;

    // Simulate heartbeat
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_connected) {
        _messageController.add({
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });

    _messageController.add({
      'type': 'connected',
      'projectId': projectId,
      'userId': userId,
    });
  }

  void sendUpdate(String componentId, Map<String, dynamic> changes) {
    if (!_connected) return;

    _messageController.add({
      'type': 'component_update',
      'componentId': componentId,
      'changes': changes,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendCursorPosition(String userId, Offset position) {
    if (!_connected) return;

    _messageController.add({
      'type': 'cursor_move',
      'userId': userId,
      'position': {'x': position.dx, 'y': position.dy},
    });
  }

  Future<void> disconnect() async {
    _connected = false;
    _heartbeatTimer?.cancel();
    _messageController.add({'type': 'disconnected'});
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    _messageController.close();
  }
}
