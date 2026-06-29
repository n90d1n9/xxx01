class DocumentChange {
  final String userId;
  final String changeType;
  final int offset;
  final String? data;
  final DateTime timestamp;
  DocumentChange({
    required this.userId,
    required this.changeType,
    required this.offset,
    this.data,
    required this.timestamp,
  });
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'changeType': changeType,
    'offset': offset,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };
  factory DocumentChange.fromJson(Map<String, dynamic> json) => DocumentChange(
    userId: json['userId'],
    changeType: json['changeType'],
    offset: json['offset'],
    data: json['data'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
