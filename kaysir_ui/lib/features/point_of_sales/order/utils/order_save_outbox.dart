import 'order_payload_envelope.dart';
import 'order_save_outbox_activity.dart';
import 'order_save_outbox_error_copy.dart';

enum POSOrderSaveOutboxStatus { pending, sending, sent, failed }

class POSOrderSaveOutboxEntry {
  final POSOrderPayloadEnvelope envelope;
  final POSOrderSaveOutboxStatus status;
  final int attempts;
  final DateTime queuedAt;
  final DateTime? lastAttemptAt;
  final DateTime? sentAt;
  final String? lastError;

  const POSOrderSaveOutboxEntry({
    required this.envelope,
    required this.status,
    required this.queuedAt,
    this.attempts = 0,
    this.lastAttemptAt,
    this.sentAt,
    this.lastError,
  });

  String get idempotencyKey => envelope.idempotencyKey;

  bool get canSend => status == POSOrderSaveOutboxStatus.pending;

  bool get canRetry => status == POSOrderSaveOutboxStatus.failed;

  bool get isTerminal => status == POSOrderSaveOutboxStatus.sent;

  POSOrderSaveOutboxEntry copyWith({
    POSOrderPayloadEnvelope? envelope,
    POSOrderSaveOutboxStatus? status,
    int? attempts,
    DateTime? queuedAt,
    DateTime? lastAttemptAt,
    bool clearLastAttemptAt = false,
    DateTime? sentAt,
    bool clearSentAt = false,
    String? lastError,
    bool clearLastError = false,
  }) {
    return POSOrderSaveOutboxEntry(
      envelope: envelope ?? this.envelope,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      queuedAt: queuedAt ?? this.queuedAt,
      lastAttemptAt:
          clearLastAttemptAt ? null : lastAttemptAt ?? this.lastAttemptAt,
      sentAt: clearSentAt ? null : sentAt ?? this.sentAt,
      lastError: clearLastError ? null : lastError ?? this.lastError,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'idempotencyKey': idempotencyKey,
      'status': status.name,
      'attempts': attempts,
      'queuedAt': queuedAt.toIso8601String(),
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'lastError': lastError,
      'envelope': envelope.toJson(),
    };
  }
}

class POSOrderSaveOutbox {
  static const activityLimit = 50;

  final List<POSOrderSaveOutboxEntry> entries;
  final List<POSOrderSaveOutboxActivity> activity;

  POSOrderSaveOutbox([
    Iterable<POSOrderSaveOutboxEntry> entries = const [],
    Iterable<POSOrderSaveOutboxActivity> activity = const [],
  ]) : entries = List.unmodifiable(entries),
       activity = List.unmodifiable(activity);

  const POSOrderSaveOutbox.empty() : entries = const [], activity = const [];

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  int get pendingCount => countByStatus(POSOrderSaveOutboxStatus.pending);

  int get sendingCount => countByStatus(POSOrderSaveOutboxStatus.sending);

  int get sentCount => countByStatus(POSOrderSaveOutboxStatus.sent);

  int get failedCount => countByStatus(POSOrderSaveOutboxStatus.failed);

  bool get hasUnsentWork => pendingCount + sendingCount + failedCount > 0;

  List<POSOrderSaveOutboxEntry> get pendingEntries {
    return _entriesWithStatus(POSOrderSaveOutboxStatus.pending);
  }

  List<POSOrderSaveOutboxEntry> get failedEntries {
    return _entriesWithStatus(POSOrderSaveOutboxStatus.failed);
  }

  List<POSOrderSaveOutboxEntry> get sentEntries {
    return _entriesWithStatus(POSOrderSaveOutboxStatus.sent);
  }

  POSOrderSaveOutboxEntry? get nextPendingEntry {
    for (final entry in entries) {
      if (entry.status == POSOrderSaveOutboxStatus.pending) {
        return entry;
      }
    }

    return null;
  }

  POSOrderSaveOutbox enqueue(
    POSOrderPayloadEnvelope envelope, {
    DateTime? queuedAt,
  }) {
    if (contains(envelope.idempotencyKey)) return this;
    final timestamp = queuedAt ?? DateTime.now();

    return POSOrderSaveOutbox([
      ...entries,
      POSOrderSaveOutboxEntry(
        envelope: envelope,
        status: POSOrderSaveOutboxStatus.pending,
        queuedAt: timestamp,
      ),
    ], activity)._appendActivity(
      POSOrderSaveOutboxActivity(
        type: POSOrderSaveOutboxActivityType.queued,
        occurredAt: timestamp,
        idempotencyKey: envelope.idempotencyKey,
        orderId: _payloadOrderId(envelope),
      ),
    );
  }

  POSOrderSaveOutbox markSending(
    String idempotencyKey, {
    DateTime? attemptedAt,
  }) {
    final entry = entryFor(idempotencyKey);
    final timestamp = attemptedAt ?? DateTime.now();
    final next = _replace(idempotencyKey, (entry) {
      if (!entry.canSend) return entry;

      return entry.copyWith(
        status: POSOrderSaveOutboxStatus.sending,
        attempts: entry.attempts + 1,
        lastAttemptAt: timestamp,
        clearLastError: true,
        clearSentAt: true,
      );
    });
    if (identical(next, this)) return this;

    return next._appendActivity(
      POSOrderSaveOutboxActivity(
        type: POSOrderSaveOutboxActivityType.sending,
        occurredAt: timestamp,
        idempotencyKey: idempotencyKey,
        orderId: _entryOrderId(entry),
      ),
    );
  }

  POSOrderSaveOutbox markSent(String idempotencyKey, {DateTime? sentAt}) {
    final entry = entryFor(idempotencyKey);
    final timestamp = sentAt ?? DateTime.now();
    final next = _replace(idempotencyKey, (entry) {
      if (entry.status == POSOrderSaveOutboxStatus.sent) return entry;

      return entry.copyWith(
        status: POSOrderSaveOutboxStatus.sent,
        sentAt: timestamp,
        clearLastError: true,
      );
    });
    if (identical(next, this)) return this;

    return next._appendActivity(
      POSOrderSaveOutboxActivity(
        type: POSOrderSaveOutboxActivityType.sent,
        occurredAt: timestamp,
        idempotencyKey: idempotencyKey,
        orderId: _entryOrderId(entry),
      ),
    );
  }

  POSOrderSaveOutbox markFailed(
    String idempotencyKey,
    Object error, {
    DateTime? failedAt,
  }) {
    final entry = entryFor(idempotencyKey);
    final timestamp = failedAt ?? DateTime.now();
    final errorMessage = friendlyPOSOrderSaveFailureMessage(error);
    final next = _replace(idempotencyKey, (entry) {
      if (entry.status == POSOrderSaveOutboxStatus.sent) return entry;

      return entry.copyWith(
        status: POSOrderSaveOutboxStatus.failed,
        lastAttemptAt: timestamp,
        lastError: errorMessage,
        clearSentAt: true,
      );
    });
    if (identical(next, this)) return this;

    return next._appendActivity(
      POSOrderSaveOutboxActivity(
        type: POSOrderSaveOutboxActivityType.failed,
        occurredAt: timestamp,
        idempotencyKey: idempotencyKey,
        orderId: _entryOrderId(entry),
        message: errorMessage,
      ),
    );
  }

  POSOrderSaveOutbox retryFailed(String idempotencyKey, {DateTime? retriedAt}) {
    return retryFailedEntries([idempotencyKey], retriedAt: retriedAt);
  }

  POSOrderSaveOutbox retryFailedEntries(
    Iterable<String> idempotencyKeys, {
    DateTime? retriedAt,
  }) {
    final keys = idempotencyKeys.toSet();
    if (keys.isEmpty) return this;

    final timestamp = retriedAt ?? DateTime.now();
    final retriedEntries = entries
        .where((entry) => keys.contains(entry.idempotencyKey) && entry.canRetry)
        .toList(growable: false);
    if (retriedEntries.isEmpty) return this;

    var changed = false;
    final nextEntries =
        entries.map((entry) {
          if (!keys.contains(entry.idempotencyKey) || !entry.canRetry) {
            return entry;
          }

          changed = true;
          return entry.copyWith(
            status: POSOrderSaveOutboxStatus.pending,
            clearLastError: true,
            clearSentAt: true,
          );
        }).toList();

    if (!changed) return this;
    return POSOrderSaveOutbox(nextEntries, activity)._appendActivities(
      retriedEntries.map((entry) {
        return POSOrderSaveOutboxActivity(
          type: POSOrderSaveOutboxActivityType.retried,
          occurredAt: timestamp,
          idempotencyKey: entry.idempotencyKey,
          orderId: _entryOrderId(entry),
        );
      }),
    );
  }

  POSOrderSaveOutbox retryAllFailed({DateTime? retriedAt}) {
    return retryFailedEntries(
      failedEntries.map((entry) => entry.idempotencyKey),
      retriedAt: retriedAt,
    );
  }

  POSOrderSaveOutbox remove(String idempotencyKey, {DateTime? removedAt}) {
    final entry = entryFor(idempotencyKey);
    if (entry == null) return this;

    return POSOrderSaveOutbox(
      entries.where((entry) => entry.idempotencyKey != idempotencyKey),
      activity,
    )._appendActivity(
      POSOrderSaveOutboxActivity(
        type: POSOrderSaveOutboxActivityType.removed,
        occurredAt: removedAt ?? DateTime.now(),
        idempotencyKey: idempotencyKey,
        orderId: _entryOrderId(entry),
      ),
    );
  }

  POSOrderSaveOutbox clearSent({DateTime? clearedAt}) {
    final sentCount = this.sentCount;
    if (sentCount == 0) return this;

    return POSOrderSaveOutbox(
      entries.where((entry) => entry.status != POSOrderSaveOutboxStatus.sent),
      activity,
    )._appendActivity(
      POSOrderSaveOutboxActivity(
        type: POSOrderSaveOutboxActivityType.clearedSent,
        occurredAt: clearedAt ?? DateTime.now(),
        count: sentCount,
      ),
    );
  }

  POSOrderSaveOutboxEntry? entryFor(String idempotencyKey) {
    for (final entry in entries) {
      if (entry.idempotencyKey == idempotencyKey) return entry;
    }

    return null;
  }

  bool contains(String idempotencyKey) => entryFor(idempotencyKey) != null;

  int countByStatus(POSOrderSaveOutboxStatus status) {
    return entries.where((entry) => entry.status == status).length;
  }

  List<POSOrderSaveOutboxEntry> _entriesWithStatus(
    POSOrderSaveOutboxStatus status,
  ) {
    return List.unmodifiable(entries.where((entry) => entry.status == status));
  }

  POSOrderSaveOutbox _replace(
    String idempotencyKey,
    POSOrderSaveOutboxEntry Function(POSOrderSaveOutboxEntry entry) update,
  ) {
    var changed = false;
    final nextEntries =
        entries.map((entry) {
          if (entry.idempotencyKey != idempotencyKey) return entry;

          final nextEntry = update(entry);
          if (!identical(nextEntry, entry)) changed = true;
          return nextEntry;
        }).toList();

    if (!changed) return this;
    return POSOrderSaveOutbox(nextEntries, activity);
  }

  POSOrderSaveOutbox _appendActivity(POSOrderSaveOutboxActivity event) {
    return _appendActivities([event]);
  }

  POSOrderSaveOutbox _appendActivities(
    Iterable<POSOrderSaveOutboxActivity> events,
  ) {
    final nextActivity = [...activity, ...events];
    final start =
        nextActivity.length > activityLimit
            ? nextActivity.length - activityLimit
            : 0;

    return POSOrderSaveOutbox(entries, nextActivity.skip(start));
  }
}

String? _entryOrderId(POSOrderSaveOutboxEntry? entry) {
  if (entry == null) return null;
  return _payloadOrderId(entry.envelope);
}

String? _payloadOrderId(POSOrderPayloadEnvelope envelope) {
  final value = envelope.payload['id'];
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}
