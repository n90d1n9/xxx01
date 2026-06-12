import '../models/order.dart';
import 'order_payload_mapper.dart';

const posOrderPayloadSchemaVersion = 'kaysir.pos.order.v1';
const defaultPOSOrderPayloadSource = 'kaysir_ui.point_of_sales';

extension POSOrderPayloadEnvelopeMapper on Order {
  POSOrderPayloadEnvelope toPOSPayloadEnvelope({
    DateTime? preparedAt,
    String source = defaultPOSOrderPayloadSource,
  }) {
    return buildPOSOrderPayloadEnvelope(
      this,
      preparedAt: preparedAt,
      source: source,
    );
  }
}

class POSOrderPayloadEnvelope {
  final String schemaVersion;
  final String idempotencyKey;
  final String source;
  final DateTime preparedAt;
  final Map<String, Object?> payload;

  const POSOrderPayloadEnvelope({
    required this.schemaVersion,
    required this.idempotencyKey,
    required this.source,
    required this.preparedAt,
    required this.payload,
  });

  factory POSOrderPayloadEnvelope.fromJson(Map<String, Object?> json) {
    return POSOrderPayloadEnvelope(
      schemaVersion: _requiredString(json, 'schemaVersion'),
      idempotencyKey: _requiredString(json, 'idempotencyKey'),
      source: _requiredString(json, 'source'),
      preparedAt: DateTime.parse(_requiredString(json, 'preparedAt')),
      payload: _requiredMap(json, 'payload'),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'idempotencyKey': idempotencyKey,
      'source': source,
      'preparedAt': preparedAt.toIso8601String(),
      'payload': payload,
    };
  }
}

POSOrderPayloadEnvelope buildPOSOrderPayloadEnvelope(
  Order order, {
  DateTime? preparedAt,
  String source = defaultPOSOrderPayloadSource,
}) {
  return POSOrderPayloadEnvelope(
    schemaVersion: posOrderPayloadSchemaVersion,
    idempotencyKey: posOrderPayloadIdempotencyKey(order),
    source: source,
    preparedAt: preparedAt ?? DateTime.now(),
    payload: order.toPOSPayload(),
  );
}

String posOrderPayloadIdempotencyKey(Order order) {
  return [
    'pos-order',
    order.id.trim(),
    order.status.trim(),
    order.createdAt.toUtc().toIso8601String(),
  ].join(':');
}

String _requiredString(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value is String && value.trim().isNotEmpty) return value;

  throw FormatException('Missing required string field "$field".');
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
    return _jsonMap(value, 'payload');
  }

  return value.toString();
}
