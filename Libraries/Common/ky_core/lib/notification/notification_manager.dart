import 'dart:async';

import '../websocket/websocket_services.dart';
import 'background_service.dart';
import 'models/notification_message.dart';
import 'notification_service.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  WebSocketService? _webSocketService;
  final NotificationService _notificationService = NotificationService();

  StreamSubscription? _messageSubscription;
  StreamSubscription? _connectionSubscription;

  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  final StreamController<NotificationMessage> _notificationController =
      StreamController<NotificationMessage>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  Stream<NotificationMessage> get notifications =>
      _notificationController.stream;

  Future<void> initialize(String serverUrl, String userId) async {
    await _notificationService.initialize();
    await BackgroundNotificationService.initialize();

    // Save config for background service
    await BackgroundNotificationService.updateConfig(serverUrl, userId);

    // Connect WebSocket for foreground
    _webSocketService = WebSocketService(wsUrl: serverUrl);
    await _webSocketService!.connect();

    // Listen to messages
    _messageSubscription = _webSocketService!.messageStream.listen((message) {
      // Convert Map to NotificationMessage or handle as needed
      _notificationController.add(NotificationMessage(
        type: message['type'] ?? 'info',
        title: message['title'] ?? 'Notification',
        message: message['message'] ?? '',
        body: message['body'],
        timestamp: DateTime.now(),
      ));
    });

    // Listen to connection status
    _connectionSubscription =
        _webSocketService!.connectionStatus.listen((status) {
      final isConnected = status == ConnectionStatus.connected;
      _connectionStatusController.add(isConnected);
    });
  }

  Future<void> startBackgroundService() async {
    await BackgroundNotificationService.startService();
  }

  Future<void> stopBackgroundService() async {
    await BackgroundNotificationService.stopService();
  }

  void dispose() {
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _webSocketService?.dispose();
    _connectionStatusController.close();
    _notificationController.close();
  }
}
