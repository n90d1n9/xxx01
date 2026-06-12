import 'dart:async';

import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/financial_report_release_distribution.dart';
import 'financial_report_release_distribution_repository.dart';

abstract class FinancialReportReleaseDistributionSnapshotStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> snapshot);
}

class LocalDbFinancialReportReleaseDistributionSnapshotStore
    implements FinancialReportReleaseDistributionSnapshotStore {
  static const defaultStorageKey =
      'accounting.financial_report_release_distribution.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbFinancialReportReleaseDistributionSnapshotStore({
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

class LocalFinancialReportReleaseDistributionRepository
    extends InMemoryFinancialReportReleaseDistributionRepository
    implements HydratableFinancialReportReleaseDistributionRepository {
  final FinancialReportReleaseDistributionSnapshotStore store;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _dirtyDuringHydrate = false;

  LocalFinancialReportReleaseDistributionRepository({
    required this.store,
    super.resolutionsByPeriod,
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
  void upsertResolution({
    required String periodKey,
    required FinancialReportReleaseDistributionResolution resolution,
  }) {
    super.upsertResolution(periodKey: periodKey, resolution: resolution);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void appendAuditEvent(FinancialReportReleaseDistributionAuditEvent event) {
    super.appendAuditEvent(event);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void removeResolution({
    required String periodKey,
    required String recipientId,
  }) {
    super.removeResolution(periodKey: periodKey, recipientId: recipientId);
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

    final FinancialReportReleaseDistributionRepositorySnapshot snapshot;
    try {
      snapshot = FinancialReportReleaseDistributionRepositorySnapshot.fromJson(
        data,
      );
    } catch (_) {
      return;
    }

    if (_dirtyDuringHydrate) {
      await _queuePersist();
      return;
    }

    replaceAll(snapshot.resolutionsByPeriod, auditEvents: snapshot.auditEvents);
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    return _persistFuture = pending.then((_) {
      return store.write(
        FinancialReportReleaseDistributionRepositorySnapshot(
          resolutionsByPeriod: loadResolutions(),
          auditEvents: loadAuditEvents(),
        ).toJson(),
      );
    });
  }
}

class FinancialReportReleaseDistributionRepositorySnapshot {
  final Map<String, List<FinancialReportReleaseDistributionResolution>>
  resolutionsByPeriod;
  final List<FinancialReportReleaseDistributionAuditEvent> auditEvents;

  const FinancialReportReleaseDistributionRepositorySnapshot({
    required this.resolutionsByPeriod,
    this.auditEvents = const [],
  });

  factory FinancialReportReleaseDistributionRepositorySnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    final resolutionsByPeriod =
        <String, List<FinancialReportReleaseDistributionResolution>>{};
    final rawPeriods = json['resolutionsByPeriod'];
    if (rawPeriods is Map) {
      for (final entry in rawPeriods.entries) {
        final resolutions = <FinancialReportReleaseDistributionResolution>[];
        final rawResolutions = entry.value;
        if (rawResolutions is Iterable) {
          for (final rawResolution in rawResolutions) {
            final value = _asJsonMap(rawResolution);
            if (value != null) {
              resolutions.add(
                FinancialReportReleaseDistributionResolution.fromJson(value),
              );
            }
          }
        }
        resolutionsByPeriod[entry.key.toString()] = resolutions;
      }
    }

    final auditEvents = <FinancialReportReleaseDistributionAuditEvent>[];
    final rawEvents = json['auditEvents'];
    if (rawEvents is Iterable) {
      for (final rawEvent in rawEvents) {
        final value = _asJsonMap(rawEvent);
        if (value != null) {
          auditEvents.add(
            FinancialReportReleaseDistributionAuditEvent.fromJson(value),
          );
        }
      }
    }

    return FinancialReportReleaseDistributionRepositorySnapshot(
      resolutionsByPeriod: resolutionsByPeriod,
      auditEvents: auditEvents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'resolutionsByPeriod': resolutionsByPeriod.map(
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
