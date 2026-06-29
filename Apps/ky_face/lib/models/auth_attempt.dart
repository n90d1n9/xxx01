class AuthAttempt {
  final String id;
  final DateTime timestamp;
  final bool success;
  final String method; // 'face', 'biometric', 'fallback'
  final String? failureReason;
  final String deviceId;
  final Map<String, dynamic> metadata;

  AuthAttempt({
    required this.id,
    required this.timestamp,
    required this.success,
    required this.method,
    this.failureReason,
    required this.deviceId,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'success': success,
    'method': method,
    'failureReason': failureReason,
    'deviceId': deviceId,
    'metadata': metadata,
  };

  factory AuthAttempt.fromJson(Map<String, dynamic> json) => AuthAttempt(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    success: json['success'],
    method: json['method'],
    failureReason: json['failureReason'],
    deviceId: json['deviceId'],
    metadata: json['metadata'] ?? {},
  );
}
