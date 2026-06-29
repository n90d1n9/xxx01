enum SystemMessageType {
  info,
  userJoin,
  userLeave,
  nodeUpdate,
  edgeUpdate,
  workflowUpdate,
}

class SystemMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final SystemMessageType type;

  SystemMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
  };

  factory SystemMessage.fromJson(Map<String, dynamic> json) {
    return SystemMessage(
      id: json['id'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
      type: _parseSystemMessageType(json['type']),
    );
  }

  static SystemMessageType _parseSystemMessageType(dynamic value) {
    if (value is SystemMessageType) return value;
    final stringValue = value.toString();
    return SystemMessageType.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => SystemMessageType.info,
    );
  }
}
