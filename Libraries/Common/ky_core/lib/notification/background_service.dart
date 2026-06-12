import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../websocket/websocket_services.dart';
import 'notification_service.dart';

class BackgroundNotificationService {
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'notification_service',
        initialNotificationTitle: 'Notification Service',
        initialNotificationContent: 'Running in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final serverUrl = prefs.getString('server_url');
    final userId = prefs.getString('user_id');

    if (serverUrl == null || userId == null) {
      service.stopSelf();
      return;
    }

    final webSocketService = WebSocketService(wsUrl: serverUrl);
    final notificationService = NotificationService();

    await notificationService.initialize();

    // Connect to WebSocket
    await webSocketService.connect();

    // Listen for notifications
    webSocketService.messageStream.listen((message) async {
      final messageType = message['type'] as String?;
      if (messageType != 'CONNECTED' && messageType != 'PONG') {
        await notificationService.showNotification(
          title: message['title'] ?? 'Notification',
          body: message['body'] ?? 'New message received',
        );
      }
    });

    // Listen for connection changes
    webSocketService.connectionStatus.listen((status) {
      final isConnected = status == ConnectionStatus.connected;
      service.invoke('update_connection_status', {'connected': isConnected});
    });

    // Handle service commands
    service.on('stop_service').listen((event) {
      webSocketService.dispose();
      service.stopSelf();
    });

    service.on('update_config').listen((event) async {
      final data = event?['data'] as Map<String, dynamic>?;
      if (data != null) {
        final newServerUrl = data['serverUrl'] as String?;
        final newUserId = data['userId'] as String?;

        if (newServerUrl != null && newUserId != null) {
          webSocketService.dispose();
          await Future.delayed(Duration(seconds: 2));
          final newWebSocketService = WebSocketService(wsUrl: newServerUrl);
          await newWebSocketService.connect();
        }
      }
    });

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    // Keep service alive
    Timer.periodic(Duration(seconds: 30), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: "Notification Service Running",
            content: "Listening for notifications...",
          );
        }
      }

      service.invoke('update_status', {
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stop_service');
  }

  static Future<void> updateConfig(String serverUrl, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', serverUrl);
    await prefs.setString('user_id', userId);

    final service = FlutterBackgroundService();
    service.invoke('update_config', {
      'data': {
        'serverUrl': serverUrl,
        'userId': userId,
      }
    });
  }
}
