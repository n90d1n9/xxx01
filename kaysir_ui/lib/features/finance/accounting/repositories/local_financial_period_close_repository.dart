import 'dart:async';

import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/financial_period_close.dart';
import '../models/financial_period_close_audit.dart';
import 'financial_period_close_repository.dart';

abstract class FinancialPeriodCloseSnapshotStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> snapshot);
}

class LocalDbFinancialPeriodCloseSnapshotStore
    implements FinancialPeriodCloseSnapshotStore {
  static const defaultStorageKey =
      'accounting.financial_period_close.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbFinancialPeriodCloseSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'your-secure-password',
  });

  @override
  Future<Map<String, dynamic>?> read() async {
    await _ensureInitialized();
    final stored = await LocalDBService.getPreference(key: storageKey);
    if (stored == null) {
      return null;
    }
    if (stored is Map<String, dynamic>) {
      return stored;
    }
    if (stored is Map) {
      return Map<String, dynamic>.from(stored);
    }
    return null;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    await _ensureInitialized();
    await LocalDBService.savePreference(key: storageKey, value: snapshot);
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= LocalDBService.initialize(
      encryptionPassword: encryptionPassword,
    ).then((_) {});
  }
}

class LocalFinancialPeriodCloseRepository
    extends InMemoryFinancialPeriodCloseRepository
    implements HydratableFinancialPeriodCloseRepository {
  final FinancialPeriodCloseSnapshotStore store;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _dirtyDuringHydrate = false;

  LocalFinancialPeriodCloseRepository({
    required this.store,
    super.records,
    super.auditEvents,
  });

  @override
  Future<void> hydrate() {
    return _hydrateFuture ??= _hydrateFromStore();
  }

  @override
  Future<void> persist() {
    return _queuePersist();
  }

  @override
  void upsertRecord(FinancialPeriodCloseRecord record) {
    super.upsertRecord(record);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void appendAuditEvent(FinancialPeriodCloseAuditEvent event) {
    super.appendAuditEvent(event);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void clear() {
    super.clear();
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  Future<void> _hydrateFromStore() async {
    final Map<String, dynamic>? data;
    try {
      data = await store.read();
    } catch (_) {
      return;
    }

    if (data == null) {
      return;
    }

    final FinancialPeriodCloseRepositorySnapshot snapshot;
    try {
      snapshot = FinancialPeriodCloseRepositorySnapshot.fromJson(data);
    } catch (_) {
      return;
    }

    if (_dirtyDuringHydrate) {
      await _queuePersist();
      return;
    }

    replaceAll(records: snapshot.records, auditEvents: snapshot.auditEvents);
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    return _persistFuture = pending.then((_) {
      return store.write(
        FinancialPeriodCloseRepositorySnapshot(
          records: loadRecords(),
          auditEvents: loadAuditEvents(),
        ).toJson(),
      );
    });
  }
}

class FinancialPeriodCloseRepositorySnapshot {
  final Map<String, FinancialPeriodCloseRecord> records;
  final List<FinancialPeriodCloseAuditEvent> auditEvents;

  const FinancialPeriodCloseRepositorySnapshot({
    required this.records,
    required this.auditEvents,
  });

  factory FinancialPeriodCloseRepositorySnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    final records = <String, FinancialPeriodCloseRecord>{};
    final rawRecords = json['records'];
    if (rawRecords is Map) {
      for (final entry in rawRecords.entries) {
        final value = _asJsonMap(entry.value);
        if (value != null) {
          final record = FinancialPeriodCloseRecord.fromJson(value);
          records[entry.key.toString()] = record;
        }
      }
    }

    final auditEvents = <FinancialPeriodCloseAuditEvent>[];
    final rawEvents = json['auditEvents'];
    if (rawEvents is Iterable) {
      for (final rawEvent in rawEvents) {
        final value = _asJsonMap(rawEvent);
        if (value != null) {
          auditEvents.add(FinancialPeriodCloseAuditEvent.fromJson(value));
        }
      }
    }

    return FinancialPeriodCloseRepositorySnapshot(
      records: records,
      auditEvents: auditEvents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'records': records.map((key, value) => MapEntry(key, value.toJson())),
      'auditEvents': auditEvents.map((event) => event.toJson()).toList(),
    };
  }
}

Map<String, dynamic>? _asJsonMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
