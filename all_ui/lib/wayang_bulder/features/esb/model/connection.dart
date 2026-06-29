class Connection {
  final String id;
  final String fromId;
  final String toId;
  final String? label;
  final String? condition;

  Connection({
    required this.id,
    required this.fromId,
    required this.toId,
    this.label,
    this.condition,
  });

  Connection copyWith({
    String? id,
    String? fromId,
    String? toId,
    String? label,
    String? condition,
  }) {
    return Connection(
      id: id ?? this.id,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      label: label ?? this.label,
      condition: condition ?? this.condition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromId': fromId,
      'toId': toId,
      'label': label,
      'condition': condition,
    };
  }

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'],
      fromId: json['fromId'],
      toId: json['toId'],
      label: json['label'],
      condition: json['condition'],
    );
  }
}
