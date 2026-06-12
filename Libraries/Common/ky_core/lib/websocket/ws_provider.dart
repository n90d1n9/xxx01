// lib/providers/websocket_providers.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../config/app_config_provider.dart';
import 'websocket_services.dart';

// This is the core provider family for creating and managing a WebSocketService.
// It takes a `path` as a parameter and uses the dynamic `appConfigProvider` to build the URL.
final webSocketServiceProvider = Provider.autoDispose
    .family<WebSocketService, String>((ref, path) {
      // 1. Get the current AppConfig from the provider.
      // This provider will be re-created if the config changes.
      final config = ref.watch(appConfigProvider);

      // 2. Build the full WebSocket URL dynamically using the config's wsBaseUrl.
      final wsUrl = '${config.networkConfig.webSocketUrl}/ws/$path';

      debugPrint('[WebSocketProvider] Creating service for path: $path');
      debugPrint('[WebSocketProvider] WebSocket URL: $wsUrl');

      // 3. Create the WebSocketService instance with the dynamic URL.
      final service = WebSocketService(wsUrl: wsUrl);

      // 4. Connect the service.
      // Your WebSocketService handles its own connection and reconnection.
      service.connect();

      // 5. Add a dispose hook to automatically close the WebSocket.
      ref.onDispose(() => service.dispose());

      return service;
    });

// Connection status provider
// This provider watches the WebSocketService and exposes its connection status stream.
final wsConnectionStatusProvider = StreamProvider.autoDispose
    .family<ConnectionStatus, String>((ref, path) {
      // Watch the WebSocketService provider for the given path.
      final wsService = ref.watch(webSocketServiceProvider(path));
      // Expose the connectionStatus stream from the service.
      return wsService.connectionStatus;
    });

// Messages stream provider
// This provider watches the WebSocketService and exposes its message stream.
final wsMessagesProvider = StreamProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, path) {
      // Watch the WebSocketService provider for the given path.
      final wsService = ref.watch(webSocketServiceProvider(path));
      // Expose the message stream from the service.
      return wsService.messageStream;
    });
