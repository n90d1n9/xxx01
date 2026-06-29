// pubspec.yaml dependencies:
// flutter_riverpod: ^2.4.9
// web_socket_channel: ^2.4.0
// freezed_annotation: ^2.4.1

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
//import 'package:web_socket_channel/status.dart' as status;

// Data Models
class FlashAd {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final Color backgroundColor;
  final Color textColor;
  final int displayDurationMs;
  final DateTime timestamp;
  final String type; // 'flash', 'banner', 'popup'

  const FlashAd({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    this.backgroundColor = const Color(0xFF6C5CE7),
    this.textColor = Colors.white,
    this.displayDurationMs = 5000,
    required this.timestamp,
    this.type = 'flash',
  });

  factory FlashAd.fromJson(Map<String, dynamic> json) {
    return FlashAd(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'],
      backgroundColor: Color(
        int.parse(json['backgroundColor'] ?? '0xFF6C5CE7'),
      ),
      textColor: Color(int.parse(json['textColor'] ?? '0xFFFFFFFF')),
      displayDurationMs: json['displayDurationMs'] ?? 5000,
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      type: json['type'] ?? 'flash',
    );
  }
}

enum FlashAdState { hidden, showing, animatingIn, animatingOut }

class FlashAdDisplayState {
  final FlashAd? currentAd;
  final FlashAdState state;
  final bool isConnected;
  final String? error;

  const FlashAdDisplayState({
    this.currentAd,
    this.state = FlashAdState.hidden,
    this.isConnected = false,
    this.error,
  });

  FlashAdDisplayState copyWith({
    FlashAd? currentAd,
    FlashAdState? state,
    bool? isConnected,
    String? error,
  }) {
    return FlashAdDisplayState(
      currentAd: currentAd ?? this.currentAd,
      state: state ?? this.state,
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
    );
  }
}

// WebSocket Service
class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  final String _wsUrl;
  final Duration reconnectDelay;
  final int maxReconnectAttempts;
  int _reconnectAttempts = 0;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  Stream<FlashAd> get adStream =>
      messageStream.map((msg) => FlashAd.fromJson(msg)).handleError((e) {
        // Optionally handle parsing errors here
      });

  WebSocketService({
    required String wsUrl,
    this.reconnectDelay = const Duration(seconds: 5),
    this.maxReconnectAttempts = 5,
  }) : _wsUrl = wsUrl;

  Future<void> connect() async {
    if (_isConnecting || _channel != null) return;

    _isConnecting = true;
    _connectionStatusController.add(ConnectionStatus.connecting);

    try {
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
      print('[WebSocketService] Received message: ' + message.toString());
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
    print('WebSocket error: $error');
    _handleDisconnect();
  }

  void _handleDisconnect() {
    _channel?.sink.close();
    _channel = null;
    _connectionStatusController.add(ConnectionStatus.disconnected);

    if (_reconnectAttempts < maxReconnectAttempts) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(reconnectDelay, () {
        _reconnectAttempts++;
        connect();
      });
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
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _messageController.close();
    _connectionStatusController.close();
  }
}

enum ConnectionStatus { connecting, connected, disconnected, error, failed }

// ... (rest of the code remains the same)
class WebSocketNotConnectedException implements Exception {
  @override
  String toString() => 'WebSocket is not connected';
}

// Riverpod provider
final webSocketServiceProvider = Provider(
  (ref) => WebSocketService(wsUrl: 'ws://localhost:8111/ws/flash-ad'),
);

// Connection status provider
final wsConnectionStatusProvider = StreamProvider((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.connectionStatus;
});

// Messages stream provider
final wsMessagesProvider = StreamProvider((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return wsService.messageStream;
});
// Riverpod Providers
/* final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService('ws://localhost:8111/ws/flash-ad');

  ref.onDispose(() {
    service.disconnect();
  });

  return service;
}); */

final flashAdProvider =
    StateNotifierProvider<FlashAdNotifier, FlashAdDisplayState>((ref) {
      final webSocketService = ref.watch(webSocketServiceProvider);
      return FlashAdNotifier(webSocketService);
    });

class FlashAdNotifier extends StateNotifier<FlashAdDisplayState> {
  final WebSocketService _webSocketService;
  StreamSubscription? _adSubscription;
  StreamSubscription? _connectionSubscription;
  Timer? _hideTimer;

  FlashAdNotifier(this._webSocketService) : super(const FlashAdDisplayState()) {
    _initialize();
  }

  void _initialize() async {
    await _webSocketService.connect();

    _connectionSubscription = _webSocketService.connectionStatus.listen((
      status,
    ) {
      state = state.copyWith(isConnected: status == ConnectionStatus.connected);
    });

    _adSubscription = _webSocketService.adStream.listen((ad) {
      _showAd(ad);
    });
  }

  void _showAd(FlashAd ad) {
    _hideTimer?.cancel();

    print('[FlashAdNotifier] Showing ad: ' + ad.title);

    state = state.copyWith(
      currentAd: ad,
      state: FlashAdState.animatingIn,
      error: null,
    );

    // Simulate animation delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        state = state.copyWith(state: FlashAdState.showing);

        // Auto hide after specified duration
        _hideTimer = Timer(Duration(milliseconds: ad.displayDurationMs), () {
          hideAd();
        });
      }
    });
  }

  void hideAd() {
    if (state.state == FlashAdState.showing ||
        state.state == FlashAdState.animatingIn) {
      state = state.copyWith(state: FlashAdState.animatingOut);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          state = state.copyWith(currentAd: null, state: FlashAdState.hidden);
        }
      });
    }
  }

  void reconnect() async {
    state = state.copyWith(error: null);
    await _webSocketService.connect();
  }

  @override
  void dispose() {
    _adSubscription?.cancel();
    _connectionSubscription?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }
}

// Main Widget
class FlashAdOverlay extends ConsumerWidget {
  const FlashAdOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adState = ref.watch(flashAdProvider);

    return Stack(
      children: [
        // Connection Status Indicator
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: _ConnectionIndicator(isConnected: adState.isConnected),
        ),

        // Flash Ad Display
        if (adState.currentAd != null && adState.state != FlashAdState.hidden)
          _FlashAdWidget(
            ad: adState.currentAd!,
            state: adState.state,
            onDismiss: () => ref.read(flashAdProvider.notifier).hideAd(),
          ),
      ],
    );
  }
}

class _ConnectionIndicator extends StatelessWidget {
  final bool isConnected;

  const _ConnectionIndicator({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Live' : 'Offline',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashAdWidget extends StatelessWidget {
  final FlashAd ad;
  final FlashAdState state;
  final VoidCallback onDismiss;

  const _FlashAdWidget({
    required this.ad,
    required this.state,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isVisible =
        state == FlashAdState.showing || state == FlashAdState.animatingIn;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : const Offset(0, -1),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isVisible ? 1.0 : 0.0,
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ad.backgroundColor,
                      ad.backgroundColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ad.backgroundColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Animated background pattern
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomPaint(
                          painter: _BackgroundPatternPainter(
                            ad.backgroundColor,
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ad.title,
                                      style: TextStyle(
                                        color: ad.textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ad.message,
                                      style: TextStyle(
                                        color: ad.textColor.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Close button
                              GestureDetector(
                                onTap: onDismiss,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: ad.textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (ad.imageUrl != null) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                ad.imageUrl!,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 100,
                                    color: Colors.white.withOpacity(0.1),
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: ad.textColor.withOpacity(0.5),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  final Color baseColor;

  _BackgroundPatternPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 1;

    for (int i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i + 10, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Usage Example
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Flash Ads Demo',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flash Ads Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          // Your main app content
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Your App Content Here', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                Text(
                  'Flash ads will appear from WebSocket events',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Flash ad overlay
          const FlashAdOverlay(),
        ],
      ),
    );
  }
}

void main(List<String> args) {
  runApp(ProviderScope(child: MyApp()));
}
