class Alert {
  final String id;
  final String title;
  final String message;
  final String severity;
  final DateTime timestamp;
  final bool isRead;
  final String? endpointId; // Optional reference to related endpoint

  Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    required this.isRead,
    this.endpointId,
  });

  // Create from API response
  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'low',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      isRead: json['isRead'] ?? false,
      endpointId: json['endpointId'],
    );
  }

  // Create copy with updated values
  Alert copyWith({
    String? id,
    String? title,
    String? message,
    String? severity,
    DateTime? timestamp,
    bool? isRead,
    String? endpointId,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      endpointId: endpointId ?? this.endpointId,
    );
  }
}
