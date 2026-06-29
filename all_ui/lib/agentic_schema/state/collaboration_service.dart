import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../model/collaboration_event.dart';
import '../service/websocket_channel.dart';

class CollaborationService {
  WebSocketChannel? _channel;
  final String workflowId;
  final StreamController<CollaborationEvent> _eventController;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  final String _userId;
  final String _userName;
  final String _token;

  CollaborationService(
    this.workflowId,
    this._userId,
    this._userName,
    this._token,
  ) : _eventController = StreamController<CollaborationEvent>.broadcast();

  Stream<CollaborationEvent> get events => _eventController.stream;

  bool get isConnected => _channel?.isConnected == true;

  Future<void> connect({Map<String, String>? headers}) async {
    try {
      await _disconnect(); // Clean up any existing connection

      final uri = Uri.parse('ws://localhost:8080/collaboration/$workflowId');

      _channel = WebSocketChannel();

      // Set up message listener before connecting
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      await _channel!.connect(uri, headers: headers);

      // Send authentication after successful connection
      _sendAuth();

      // Start heartbeat
      _startHeartbeat();
      _reconnectAttempts = 0;

      debugPrint('Collaboration service connected for workflow: $workflowId');
    } catch (e) {
      debugPrint('Failed to connect: $e');
      _handleError(e);
    }
  }

  void _sendAuth() {
    _send({
      'type': 'auth',
      'userId': _userId,
      'userName': _userName,
      'token': _token,
      'workflowId': workflowId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final String messageStr;
      if (message is String) {
        messageStr = message;
      } else if (message is List<int>) {
        messageStr = utf8.decode(message);
      } else {
        throw FormatException(
          'Unsupported message type: ${message.runtimeType}',
        );
      }

      final data = json.decode(messageStr) as Map<String, dynamic>;

      // Handle ping-pong
      if (data['type'] == 'ping') {
        _send({'type': 'pong'});
        return;
      }

      // Handle pong
      if (data['type'] == 'pong') {
        return; // Heartbeat acknowledged
      }

      final event = CollaborationEvent.fromJson(data);
      _eventController.add(event);
    } catch (e) {
      debugPrint('Error parsing message: $e, message: $message');
      _eventController.addError(e);
    }
  }

  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _eventController.addError(error);
    _attemptReconnect();
  }

  void _handleDisconnect() {
    debugPrint('WebSocket disconnected');
    _stopHeartbeat();
    _attemptReconnect();
  }

  void _attemptReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _eventController.addError(Exception('Max reconnection attempts reached'));
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      debugPrint(
        'Attempting reconnection $_reconnectAttempts/$maxReconnectAttempts',
      );
      connect();
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (isConnected) {
        _send({
          'type': 'ping',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _send(Map<String, dynamic> data) {
    if (_channel?.isConnected == true) {
      try {
        _channel!.sink.add(data);
      } catch (e) {
        debugPrint('Error sending message: $e');
        _handleError(e);
      }
    }
  }

  // Public API methods
  void sendEvent(CollaborationEvent event) {
    final eventData = event.toJson();
    eventData['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    eventData['userId'] = _userId;
    _send(eventData);
  }

  void sendChatMessage(String message, {String? replyToId, String? threadId}) {
    _send({
      'type': 'chatMessage',
      'message': message,
      'replyToId': replyToId,
      'threadId': threadId,
      'userId': _userId,
      'userName': _userName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void updateCursor(Offset position, {String? nodeId}) {
    _send({
      'type': 'cursorMoved',
      'position': {'x': position.dx, 'y': position.dy},
      'nodeId': nodeId,
      'userId': _userId,
      'userName': _userName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void updateSelection(List<String> nodeIds) {
    _send({
      'type': 'selectionChanged',
      'nodeIds': nodeIds,
      'userId': _userId,
      'userName': _userName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void nodeUpdated(String nodeId, Map<String, dynamic> changes) {
    _send({
      'type': 'nodeUpdated',
      'nodeId': nodeId,
      'changes': changes,
      'userId': _userId,
      'userName': _userName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void edgeUpdated(String edgeId, Map<String, dynamic> changes) {
    _send({
      'type': 'edgeUpdated',
      'edgeId': edgeId,
      'changes': changes,
      'userId': _userId,
      'userName': _userName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void userJoined() {
    _send({
      'type': 'userJoined',
      'userId': _userId,
      'userName': _userName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void userLeft() {
    _send({
      'type': 'userLeft',
      'userId': _userId,
      'userName': _userName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _disconnect() async {
    _stopHeartbeat();
    _reconnectTimer?.cancel();

    if (_channel != null) {
      await _channel!.close(1000, 'Normal closure');
      _channel = null;
    }
  }

  Future<void> disconnect() async {
    userLeft(); // Notify other users
    await _disconnect();
    await _eventController.close();
  }
}
