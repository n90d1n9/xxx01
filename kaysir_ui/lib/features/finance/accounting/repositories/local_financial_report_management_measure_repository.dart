import 'dart:async';

import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/financial_report_management_measure.dart';
import 'financial_report_management_measure_repository.dart';

abstract class FinancialReportManagementMeasureSnapshotStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> snapshot);
}

class LocalDbFinancialReportManagementMeasureSnapshotStore
    implements FinancialReportManagementMeasureSnapshotStore {
  static const defaultStorageKey =
      'accounting.financial_report_management_measures.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbFinancialReportManagementMeasureSnapshotStore({
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

class LocalFinancialReportManagementMeasureRepository
    extends InMemoryFinancialReportManagementMeasureRepository
    implements HydratableFinancialReportManagementMeasureRepository {
  final FinancialReportManagementMeasureSnapshotStore store;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _dirtyDuringHydrate = false;

  LocalFinancialReportManagementMeasureRepository({
    required this.store,
    super.measuresByPeriod,
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
  void upsertMeasure({
    required String periodKey,
    required FinancialReportManagementMeasure measure,
  }) {
    super.upsertMeasure(periodKey: periodKey, measure: measure);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void appendAuditEvent(FinancialReportManagementMeasureAuditEvent event) {
    super.appendAuditEvent(event);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void replaceMeasures({
    required String periodKey,
    required List<FinancialReportManagementMeasure> measures,
  }) {
    super.replaceMeasures(periodKey: periodKey, measures: measures);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void removeMeasure({required String periodKey, required String measureId}) {
    super.removeMeasure(periodKey: periodKey, measureId: measureId);
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

    final FinancialReportManagementMeasureRepositorySnapshot snapshot;
    try {
      snapshot = FinancialReportManagementMeasureRepositorySnapshot.fromJson(
        data,
      );
    } catch (_) {
      return;
    }

    if (_dirtyDuringHydrate) {
      await _queuePersist();
      return;
    }

    replaceAll(snapshot.measuresByPeriod, auditEvents: snapshot.auditEvents);
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    return _persistFuture = pending.then((_) {
      return store.write(
        FinancialReportManagementMeasureRepositorySnapshot(
          measuresByPeriod: loadMeasures(),
          auditEvents: loadAuditEvents(),
        ).toJson(),
      );
    });
  }
}

class FinancialReportManagementMeasureRepositorySnapshot {
  final Map<String, List<FinancialReportManagementMeasure>> measuresByPeriod;
  final List<FinancialReportManagementMeasureAuditEvent> auditEvents;

  const FinancialReportManagementMeasureRepositorySnapshot({
    required this.measuresByPeriod,
    this.auditEvents = const [],
  });

  factory FinancialReportManagementMeasureRepositorySnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    final measuresByPeriod = <String, List<FinancialReportManagementMeasure>>{};
    final rawPeriods = json['measuresByPeriod'];
    if (rawPeriods is Map) {
      for (final entry in rawPeriods.entries) {
        final measures = <FinancialReportManagementMeasure>[];
        final rawMeasures = entry.value;
        if (rawMeasures is Iterable) {
          for (final rawMeasure in rawMeasures) {
            final value = _asJsonMap(rawMeasure);
            if (value != null) {
              measures.add(FinancialReportManagementMeasure.fromJson(value));
            }
          }
        }
        measuresByPeriod[entry.key.toString()] = measures;
      }
    }

    final auditEvents = <FinancialReportManagementMeasureAuditEvent>[];
    final rawEvents = json['auditEvents'];
    if (rawEvents is Iterable) {
      for (final rawEvent in rawEvents) {
        final value = _asJsonMap(rawEvent);
        if (value != null) {
          auditEvents.add(
            FinancialReportManagementMeasureAuditEvent.fromJson(value),
          );
        }
      }
    }

    return FinancialReportManagementMeasureRepositorySnapshot(
      measuresByPeriod: measuresByPeriod,
      auditEvents: auditEvents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'measuresByPeriod': measuresByPeriod.map(
        (key, value) =>
            MapEntry(key, value.map((item) => item.toJson()).toList()),
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
