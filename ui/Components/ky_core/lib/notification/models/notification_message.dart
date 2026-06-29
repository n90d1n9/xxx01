import '../../websocket/websocket_services.dart';

class NotificationMessage {
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final ConnectionStatus status;
  final bool isBroadcast;
  final String? body;

  NotificationMessage({
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.body,
    required this.timestamp,
    ConnectionStatus? status,
    this.isBroadcast = false,
  }) : status = ConnectionStatus.disconnected;

  factory NotificationMessage.fromJson(Map<String, dynamic> json) {
    return NotificationMessage(
      type: json['type'] ?? 'info',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      data: json['data'],
      isBroadcast: json['isBroadcast'] ?? false,
      body: json['body'],
      timestamp: json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  bool get isConnected => status == ConnectionStatus.connected;
  bool get isConnecting => status == ConnectionStatus.connecting;
  bool get hasError => status == ConnectionStatus.error;
}
