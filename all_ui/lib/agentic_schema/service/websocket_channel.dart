// web_socket_channel.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A platform-agnostic WebSocket channel implementation
class WebSocketChannel {
  final StreamController<dynamic> _incomingController;
  final StreamController<dynamic> _outgoingController;
  WebSocket? _webSocket;
  bool _isConnected = false;

  Stream<dynamic> get stream => _incomingController.stream;
  StreamSink<dynamic> get sink => _outgoingController.sink;

  WebSocketChannel()
    : _incomingController = StreamController<dynamic>.broadcast(),
      _outgoingController = StreamController<dynamic>() {
    _setupOutgoingListener();
  }

  void _setupOutgoingListener() {
    _outgoingController.stream.listen((data) {
      if (_isConnected && _webSocket != null) {
        try {
          final message = data is String ? data : json.encode(data);
          _webSocket!.add(message);
        } catch (e) {
          _incomingController.addError(e);
        }
      }
    });
  }

  /// Connect to a WebSocket server
  Future<void> connect(Uri uri, {Map<String, String>? headers}) async {
    try {
      final request = await HttpClient().openUrl('GET', uri);

      // Add custom headers if provided
      headers?.forEach((key, value) {
        request.headers.add(key, value);
      });

      final response = await request.close();

      if (response.statusCode != HttpStatus.switchingProtocols) {
        throw WebSocketChannelException(
          'Failed to connect: ${response.statusCode}',
          response.statusCode,
        );
      }

      final socket = await response.detachSocket();
      _webSocket = WebSocket.fromUpgradedSocket(
        socket,
        protocol: 'collaboration-v1',
      );

      _webSocket!.listen(
        _handleIncomingMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: true,
      );

      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  void _handleIncomingMessage(dynamic message) {
    _incomingController.add(message);
  }

  void _handleError(Object error, StackTrace stackTrace) {
    _incomingController.addError(error, stackTrace);
  }

  void _handleDone() {
    _isConnected = false;
    _incomingController.close();
  }

  /// Close the WebSocket connection
  Future<void> close([int? code, String? reason]) async {
    _outgoingController.close();
    await _webSocket?.close(code, reason);
    _isConnected = false;
    await _incomingController.close();
  }

  bool get isConnected =>
      _isConnected && _webSocket?.readyState == WebSocket.open;
}

class WebSocketChannelException implements Exception {
  final String message;
  final int? statusCode;

  WebSocketChannelException(this.message, [this.statusCode]);

  @override
  String toString() =>
      'WebSocketChannelException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
