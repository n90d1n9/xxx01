enum POSOrderSaveOutboxActivityType {
  queued,
  sending,
  sent,
  failed,
  retried,
  removed,
  clearedSent,
}

class POSOrderSaveOutboxActivity {
  final POSOrderSaveOutboxActivityType type;
  final DateTime occurredAt;
  final String? idempotencyKey;
  final String? orderId;
  final String? message;
  final int? count;

  const POSOrderSaveOutboxActivity({
    required this.type,
    required this.occurredAt,
    this.idempotencyKey,
    this.orderId,
    this.message,
    this.count,
  });

  Map<String, Object?> toJson() {
    return {
      'type': type.name,
      'occurredAt': occurredAt.toIso8601String(),
      'idempotencyKey': idempotencyKey,
      'orderId': orderId,
      'message': message,
      'count': count,
    };
  }

  factory POSOrderSaveOutboxActivity.fromJson(Map<String, Object?> json) {
    return POSOrderSaveOutboxActivity(
      type: _decodeType(_requiredString(json, 'type')),
      occurredAt: DateTime.parse(_requiredString(json, 'occurredAt')),
      idempotencyKey: _optionalString(json, 'idempotencyKey'),
      orderId: _optionalString(json, 'orderId'),
      message: _optionalString(json, 'message'),
      count: _optionalInt(json, 'count'),
    );
  }

  static POSOrderSaveOutboxActivityType _decodeType(String typeName) {
    for (final type in POSOrderSaveOutboxActivityType.values) {
      if (type.name == typeName) return type;
    }

    throw FormatException('Unsupported outbox activity type "$typeName".');
  }
}

String _requiredString(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value is String && value.trim().isNotEmpty) return value;

  throw FormatException('Missing required string field "$field".');
}

String? _optionalString(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is String) return value;

  throw FormatException('Field "$field" must be a string.');
}

int? _optionalInt(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is int) return value;

  throw FormatException('Field "$field" must be an integer.');
}
