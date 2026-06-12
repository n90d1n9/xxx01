import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../network/network_checker.dart';

enum ConnectionStatus { connecting, connected, disconnected, error, failed }

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  final String _wsUrl;
  final Duration reconnectDelay;
  final Duration reconnectMaxDelay;
  final double reconnectBackoffFactor;
  final double reconnectJitterPct;
  final int maxReconnectAttempts;
  int _reconnectAttempts = 0;
  final bool waitForOnline;
  final NetworkChecker? networkChecker;
  StreamSubscription<bool>? _networkSubscription;
  bool _manualClose = false;

  // Stream emits raw JSON data (Map<String, dynamic>)
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  // Raw message stream
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  WebSocketService({
    required String wsUrl,
    this.reconnectDelay = const Duration(seconds: 5),
    this.reconnectMaxDelay = const Duration(seconds: 30),
    this.reconnectBackoffFactor = 2.0,
    this.reconnectJitterPct = 0.2,
    this.maxReconnectAttempts = 5,
    this.waitForOnline = true,
    this.networkChecker,
  }) : _wsUrl = wsUrl;

  Future<void> connect() async {
    if (_isConnecting || _channel != null) return;

    _isConnecting = true;
    _manualClose = false;
    _connectionStatusController.add(ConnectionStatus.connecting);

    try {
      debugPrint('[WebSocketService] Connecting to: $_wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _connectionStatusController.add(ConnectionStatus.connected);
      _reconnectAttempts = 0;

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      _isConnecting = false;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final parsedMessage = json.decode(message as String);

      debugPrint('[WebSocketService] Received message: ${message.toString()}');

      if (parsedMessage is Map<String, dynamic>) {
        _messageController.add(parsedMessage);
      } else {
        _handleError('Invalid message format');
      }
    } catch (e) {
      _handleError('Message parsing error: $e');
    }
  }

  void _handleError(dynamic error) {
    _connectionStatusController.add(ConnectionStatus.error);
    debugPrint('WebSocket error: $error');
    _handleDisconnect();
  }

  void _handleDisconnect() {
    _channel?.sink.close();
    _channel = null;
    _connectionStatusController.add(ConnectionStatus.disconnected);

    if (_manualClose) {
      return;
    }

    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnectTimer?.cancel();
      if (waitForOnline && networkChecker != null) {
        _networkSubscription?.cancel();
        _networkSubscription = networkChecker!
            .onStatusChange()
            .where((online) => online)
            .take(1)
            .listen((_) {
              _reconnectAttempts++;
              connect();
            });
      } else {
        final delay = _nextReconnectDelay();
        _reconnectTimer = Timer(delay, () {
          _reconnectAttempts++;
          connect();
        });
      }
    } else {
      _connectionStatusController.add(ConnectionStatus.failed);
    }
  }

  Future<void> send(Map<String, dynamic> message) async {
    if (_channel == null) {
      throw WebSocketNotConnectedException();
    }

    try {
      _channel!.sink.add(json.encode(message));
    } catch (e) {
      _handleError('Failed to send message: $e');
      rethrow;
    }
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionStatusController.close();
  }

  void disconnect({bool manual = true}) {
    _manualClose = manual;
    _reconnectTimer?.cancel();
    _networkSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnecting = false;
  }

  Duration _nextReconnectDelay() {
    final baseMs = reconnectDelay.inMilliseconds;
    final maxMs = reconnectMaxDelay.inMilliseconds;
    final powFactor = pow(reconnectBackoffFactor, _reconnectAttempts).toDouble();
    var delayMs = (baseMs * powFactor).toInt();
    if (delayMs > maxMs) delayMs = maxMs;
    final jitter = 1 +
        ((Random().nextDouble() * 2 - 1) *
            reconnectJitterPct.clamp(0.0, 1.0));
    final adjusted = (delayMs * jitter).toInt();
    return Duration(milliseconds: adjusted > maxMs ? maxMs : adjusted);
  }
}

class WebSocketNotConnectedException implements Exception {
  @override
  String toString() => 'WebSocket is not connected';
}
