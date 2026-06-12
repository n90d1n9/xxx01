import 'order_payload_envelope.dart';
import 'order_save_outbox.dart';
import 'order_save_outbox_activity.dart';
import 'order_save_outbox_error_copy.dart';

const posOrderSaveOutboxSchemaVersion = 'kaysir.pos.order_outbox.v1';

class POSOrderSaveOutboxCodec {
  const POSOrderSaveOutboxCodec();

  Map<String, Object?> encode(
    POSOrderSaveOutbox outbox, {
    DateTime? encodedAt,
  }) {
    return {
      'schemaVersion': posOrderSaveOutboxSchemaVersion,
      'encodedAt': (encodedAt ?? DateTime.now()).toIso8601String(),
      'entryCount': outbox.entries.length,
      'entries': outbox.entries.map((entry) => entry.toJson()).toList(),
      'activityCount': outbox.activity.length,
      'activity': outbox.activity.map((event) => event.toJson()).toList(),
    };
  }

  POSOrderSaveOutbox decode(
    Map<String, Object?> json, {
    bool resetInFlight = true,
  }) {
    final schemaVersion = _requiredString(json, 'schemaVersion');
    if (schemaVersion != posOrderSaveOutboxSchemaVersion) {
      throw FormatException(
        'Unsupported POS order save outbox schema "$schemaVersion".',
      );
    }

    final entries = _requiredList(json, 'entries')
        .map((entry) => _decodeEntry(entry, resetInFlight: resetInFlight))
        .toList(growable: false);
    final activity = _optionalList(
      json,
      'activity',
    ).map(_decodeActivity).toList(growable: false);

    final entryCount = json['entryCount'];
    if (entryCount is int && entryCount != entries.length) {
      throw FormatException(
        'Outbox entryCount $entryCount does not match ${entries.length}.',
      );
    }

    final activityCount = json['activityCount'];
    if (activityCount is int && activityCount != activity.length) {
      throw FormatException(
        'Outbox activityCount $activityCount does not match ${activity.length}.',
      );
    }

    return POSOrderSaveOutbox(entries, activity);
  }

  POSOrderSaveOutboxEntry _decodeEntry(
    Object? value, {
    required bool resetInFlight,
  }) {
    if (value is! Map) {
      throw const FormatException('Outbox entry must be a map.');
    }

    final json = _jsonMap(value, 'entry');
    final envelope = POSOrderPayloadEnvelope.fromJson(
      _requiredMap(json, 'envelope'),
    );
    final entryKey = _optionalString(json, 'idempotencyKey');
    if (entryKey != null && entryKey != envelope.idempotencyKey) {
      throw FormatException(
        'Outbox entry key "$entryKey" does not match its envelope key.',
      );
    }

    var status = _decodeStatus(_requiredString(json, 'status'));
    if (resetInFlight && status == POSOrderSaveOutboxStatus.sending) {
      status = POSOrderSaveOutboxStatus.pending;
    }

    final attempts = _optionalInt(json, 'attempts') ?? 0;
    if (attempts < 0) {
      throw const FormatException('Outbox entry attempts cannot be negative.');
    }

    return POSOrderSaveOutboxEntry(
      envelope: envelope,
      status: status,
      attempts: attempts,
      queuedAt: _requiredDateTime(json, 'queuedAt'),
      lastAttemptAt: _optionalDateTime(json, 'lastAttemptAt'),
      sentAt: _optionalDateTime(json, 'sentAt'),
      lastError: _sanitizeSaveError(_optionalString(json, 'lastError')),
    );
  }

  POSOrderSaveOutboxStatus _decodeStatus(String statusName) {
    for (final status in POSOrderSaveOutboxStatus.values) {
      if (status.name == statusName) return status;
    }

    throw FormatException('Unsupported outbox status "$statusName".');
  }

  POSOrderSaveOutboxActivity _decodeActivity(Object? value) {
    if (value is! Map) {
      throw const FormatException('Outbox activity must be a map.');
    }

    final activity = POSOrderSaveOutboxActivity.fromJson(
      _jsonMap(value, 'activity'),
    );
    if (activity.type != POSOrderSaveOutboxActivityType.failed) {
      return activity;
    }

    return POSOrderSaveOutboxActivity(
      type: activity.type,
      occurredAt: activity.occurredAt,
      idempotencyKey: activity.idempotencyKey,
      orderId: activity.orderId,
      message: _sanitizeSaveError(activity.message),
      count: activity.count,
    );
  }
}

String? _sanitizeSaveError(String? error) {
  if (error == null || error.trim().isEmpty) return null;
  return friendlyPOSOrderSaveFailureMessage(error);
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

DateTime _requiredDateTime(Map<String, Object?> json, String field) {
  return DateTime.parse(_requiredString(json, field));
}

DateTime? _optionalDateTime(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is String && value.trim().isNotEmpty) return DateTime.parse(value);

  throw FormatException('Field "$field" must be an ISO date string.');
}

List<Object?> _requiredList(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value is List) return List<Object?>.unmodifiable(value);

  throw FormatException('Missing required list field "$field".');
}

List<Object?> _optionalList(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value == null) return const [];
  if (value is List) return List<Object?>.unmodifiable(value);

  throw FormatException('Field "$field" must be a list.');
}

Map<String, Object?> _requiredMap(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value is Map) return _jsonMap(value, field);

  throw FormatException('Missing required map field "$field".');
}

Map<String, Object?> _jsonMap(Map<Object?, Object?> value, String field) {
  return Map<String, Object?>.unmodifiable(
    value.map((key, value) {
      if (key is! String) {
        throw FormatException('Map field "$field" contains a non-string key.');
      }

      return MapEntry(key, _jsonValue(value));
    }),
  );
}

Object? _jsonValue(Object? value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is List) {
    return List<Object?>.unmodifiable(value.map(_jsonValue));
  }
  if (value is Map) {
    return _jsonMap(value, 'entry');
  }

  return value.toString();
}
