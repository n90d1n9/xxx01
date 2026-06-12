import 'billing_invoice_issue_command.dart';

enum BillingInvoiceIssueOutboxStatus { queued, syncing, synced, failed }

class BillingInvoiceIssueOutboxEntry {
  static const _unset = Object();

  final String idempotencyKey;
  final String tenantId;
  final String draftFingerprint;
  final BillingInvoiceIssueOutboxStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int attemptCount;
  final String? remoteInvoiceId;
  final String? lastError;
  final Map<String, Object?> payload;

  BillingInvoiceIssueOutboxEntry({
    required this.idempotencyKey,
    required this.tenantId,
    required this.draftFingerprint,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.attemptCount,
    this.remoteInvoiceId,
    this.lastError,
    Map<String, Object?> payload = const {},
  }) : payload = _deeplyUnmodifiableMap(payload);

  factory BillingInvoiceIssueOutboxEntry.fromCommand(
    BillingInvoiceIssueCommand command, {
    DateTime? createdAt,
  }) {
    final resolvedCreatedAt = createdAt ?? DateTime.now();

    return BillingInvoiceIssueOutboxEntry(
      idempotencyKey: command.idempotencyKey,
      tenantId: command.tenantId,
      draftFingerprint: command.draftFingerprint,
      status: BillingInvoiceIssueOutboxStatus.queued,
      createdAt: resolvedCreatedAt,
      updatedAt: resolvedCreatedAt,
      attemptCount: 0,
      payload: command.toPayload(),
    );
  }

  factory BillingInvoiceIssueOutboxEntry.fromRecord(
    Map<String, Object?> record,
  ) {
    return BillingInvoiceIssueOutboxEntry(
      idempotencyKey: _requiredString(record, 'idempotencyKey'),
      tenantId: _requiredString(record, 'tenantId'),
      draftFingerprint: _requiredString(record, 'draftFingerprint'),
      status: _statusFromName(_requiredString(record, 'status')),
      createdAt: _requiredDate(record, 'createdAt'),
      updatedAt: _requiredDate(record, 'updatedAt'),
      attemptCount: (record['attemptCount'] as num?)?.toInt() ?? 0,
      remoteInvoiceId: record['remoteInvoiceId'] as String?,
      lastError: record['lastError'] as String?,
      payload: _stringObjectMap(record['payload']),
    );
  }

  bool get canRetry {
    return status == BillingInvoiceIssueOutboxStatus.queued ||
        status == BillingInvoiceIssueOutboxStatus.failed;
  }

  bool get isTerminal => status == BillingInvoiceIssueOutboxStatus.synced;

  BillingInvoiceIssueOutboxEntry markSyncing({DateTime? updatedAt}) {
    return copyWith(
      status: BillingInvoiceIssueOutboxStatus.syncing,
      updatedAt: updatedAt ?? DateTime.now(),
      attemptCount: attemptCount + 1,
      lastError: null,
    );
  }

  BillingInvoiceIssueOutboxEntry markSynced({
    required String remoteInvoiceId,
    DateTime? updatedAt,
  }) {
    return copyWith(
      status: BillingInvoiceIssueOutboxStatus.synced,
      updatedAt: updatedAt ?? DateTime.now(),
      remoteInvoiceId: remoteInvoiceId,
      lastError: null,
    );
  }

  BillingInvoiceIssueOutboxEntry markFailed({
    required Object error,
    DateTime? updatedAt,
  }) {
    return copyWith(
      status: BillingInvoiceIssueOutboxStatus.failed,
      updatedAt: updatedAt ?? DateTime.now(),
      lastError: error.toString(),
    );
  }

  BillingInvoiceIssueOutboxEntry copyWith({
    String? idempotencyKey,
    String? tenantId,
    String? draftFingerprint,
    BillingInvoiceIssueOutboxStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? attemptCount,
    Object? remoteInvoiceId = _unset,
    Object? lastError = _unset,
    Map<String, Object?>? payload,
  }) {
    return BillingInvoiceIssueOutboxEntry(
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      tenantId: tenantId ?? this.tenantId,
      draftFingerprint: draftFingerprint ?? this.draftFingerprint,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attemptCount: attemptCount ?? this.attemptCount,
      remoteInvoiceId:
          identical(remoteInvoiceId, _unset)
              ? this.remoteInvoiceId
              : remoteInvoiceId as String?,
      lastError:
          identical(lastError, _unset) ? this.lastError : lastError as String?,
      payload: payload ?? this.payload,
    );
  }

  Map<String, Object?> toRecord() {
    return Map.unmodifiable({
      'idempotencyKey': idempotencyKey,
      'tenantId': tenantId,
      'draftFingerprint': draftFingerprint,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'attemptCount': attemptCount,
      'remoteInvoiceId': remoteInvoiceId,
      'lastError': lastError,
      'payload': payload,
    });
  }
}

Map<String, Object?> _deeplyUnmodifiableMap(Map<String, Object?> value) {
  return Map.unmodifiable(
    value.map((key, item) => MapEntry(key, _deeplyUnmodifiable(item))),
  );
}

Object? _deeplyUnmodifiable(Object? value) {
  if (value is Map) {
    return Map<String, Object?>.unmodifiable(
      value.map(
        (key, item) => MapEntry(key.toString(), _deeplyUnmodifiable(item)),
      ),
    );
  }
  if (value is Iterable) {
    return List<Object?>.unmodifiable(value.map(_deeplyUnmodifiable));
  }

  return value;
}

String _requiredString(Map<String, Object?> record, String key) {
  final value = record[key] as String?;
  if (value == null || value.trim().isEmpty) {
    throw StateError('Billing invoice issue outbox record $key is required.');
  }

  return value;
}

DateTime _requiredDate(Map<String, Object?> record, String key) {
  final value = record[key];
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.parse(value);
  }

  throw StateError('Billing invoice issue outbox record $key is required.');
}

BillingInvoiceIssueOutboxStatus _statusFromName(String name) {
  return BillingInvoiceIssueOutboxStatus.values.firstWhere(
    (status) => status.name == name,
    orElse:
        () => throw StateError('Unknown invoice issue outbox status $name.'),
  );
}

Map<String, Object?> _stringObjectMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  return const {};
}
