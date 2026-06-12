import 'dart:async';

import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/financial_report_release_archive.dart';
import 'financial_report_release_archive_repository.dart';

abstract class FinancialReportReleaseArchiveSnapshotStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> snapshot);
}

class LocalDbFinancialReportReleaseArchiveSnapshotStore
    implements FinancialReportReleaseArchiveSnapshotStore {
  static const defaultStorageKey =
      'accounting.financial_report_release_archive.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbFinancialReportReleaseArchiveSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'your-secure-password',
  });

  @override
  Future<Map<String, dynamic>?> read() async {
    final stored = await _tryRead();
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
    try {
      await _ensureInitialized();
      await LocalDBService.savePreference(key: storageKey, value: snapshot);
    } catch (_) {
      return;
    }
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= LocalDBService.initialize(
      encryptionPassword: encryptionPassword,
    ).then((_) {}).catchError((_) {});
  }

  Future<Object?> _tryRead() async {
    try {
      await _ensureInitialized();
      return LocalDBService.getPreference(key: storageKey);
    } catch (_) {
      return null;
    }
  }
}

class LocalFinancialReportReleaseArchiveRepository
    extends InMemoryFinancialReportReleaseArchiveRepository
    implements HydratableFinancialReportReleaseArchiveRepository {
  final FinancialReportReleaseArchiveSnapshotStore store;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _dirtyDuringHydrate = false;

  LocalFinancialReportReleaseArchiveRepository({
    required this.store,
    super.recordsByPeriod,
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
  void upsertRecord(FinancialReportReleaseArchiveRecord record) {
    super.upsertRecord(record);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void appendAuditEvent(FinancialReportReleaseArchiveAuditEvent event) {
    super.appendAuditEvent(event);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void removeRecord(String periodKey) {
    super.removeRecord(periodKey);
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

    final FinancialReportReleaseArchiveRepositorySnapshot snapshot;
    try {
      snapshot = FinancialReportReleaseArchiveRepositorySnapshot.fromJson(data);
    } catch (_) {
      return;
    }

    if (_dirtyDuringHydrate) {
      await _queuePersist();
      return;
    }

    replaceAll(snapshot.recordsByPeriod, auditEvents: snapshot.auditEvents);
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    return _persistFuture = pending.then((_) {
      return store.write(
        FinancialReportReleaseArchiveRepositorySnapshot(
          recordsByPeriod: loadRecords(),
          auditEvents: loadAuditEvents(),
        ).toJson(),
      );
    });
  }
}

class FinancialReportReleaseArchiveRepositorySnapshot {
  final Map<String, FinancialReportReleaseArchiveRecord> recordsByPeriod;
  final List<FinancialReportReleaseArchiveAuditEvent> auditEvents;

  const FinancialReportReleaseArchiveRepositorySnapshot({
    required this.recordsByPeriod,
    this.auditEvents = const [],
  });

  factory FinancialReportReleaseArchiveRepositorySnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    final recordsByPeriod = <String, FinancialReportReleaseArchiveRecord>{};
    final rawPeriods = json['recordsByPeriod'];
    if (rawPeriods is Map) {
      for (final entry in rawPeriods.entries) {
        final value = _asJsonMap(entry.value);
        if (value != null) {
          recordsByPeriod[entry.key.toString()] =
              FinancialReportReleaseArchiveRecord.fromJson(value);
        }
      }
    }

    final auditEvents = <FinancialReportReleaseArchiveAuditEvent>[];
    final rawEvents = json['auditEvents'];
    if (rawEvents is Iterable) {
      for (final rawEvent in rawEvents) {
        final value = _asJsonMap(rawEvent);
        if (value != null) {
          auditEvents.add(
            FinancialReportReleaseArchiveAuditEvent.fromJson(value),
          );
        }
      }
    }

    return FinancialReportReleaseArchiveRepositorySnapshot(
      recordsByPeriod: recordsByPeriod,
      auditEvents: auditEvents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'recordsByPeriod': recordsByPeriod.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
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
