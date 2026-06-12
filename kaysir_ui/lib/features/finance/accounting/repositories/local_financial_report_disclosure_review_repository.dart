import 'dart:async';

import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/financial_report_disclosure_review.dart';
import 'financial_report_disclosure_review_repository.dart';

abstract class FinancialReportDisclosureReviewSnapshotStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> snapshot);
}

class LocalDbFinancialReportDisclosureReviewSnapshotStore
    implements FinancialReportDisclosureReviewSnapshotStore {
  static const defaultStorageKey =
      'accounting.financial_report_disclosure_reviews.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbFinancialReportDisclosureReviewSnapshotStore({
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

class LocalFinancialReportDisclosureReviewRepository
    extends InMemoryFinancialReportDisclosureReviewRepository
    implements HydratableFinancialReportDisclosureReviewRepository {
  final FinancialReportDisclosureReviewSnapshotStore store;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _dirtyDuringHydrate = false;

  LocalFinancialReportDisclosureReviewRepository({
    required this.store,
    super.resolutionsByPeriod,
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
    required FinancialReportDisclosureResolution resolution,
  }) {
    super.upsertResolution(periodKey: periodKey, resolution: resolution);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void removeResolution({
    required String periodKey,
    required String requirementId,
  }) {
    super.removeResolution(periodKey: periodKey, requirementId: requirementId);
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

    final FinancialReportDisclosureReviewRepositorySnapshot snapshot;
    try {
      snapshot = FinancialReportDisclosureReviewRepositorySnapshot.fromJson(
        data,
      );
    } catch (_) {
      return;
    }

    if (_dirtyDuringHydrate) {
      await _queuePersist();
      return;
    }

    replaceAll(snapshot.resolutionsByPeriod);
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    return _persistFuture = pending.then((_) {
      return store.write(
        FinancialReportDisclosureReviewRepositorySnapshot(
          resolutionsByPeriod: loadResolutions(),
        ).toJson(),
      );
    });
  }
}

class FinancialReportDisclosureReviewRepositorySnapshot {
  final Map<String, List<FinancialReportDisclosureResolution>>
  resolutionsByPeriod;

  const FinancialReportDisclosureReviewRepositorySnapshot({
    required this.resolutionsByPeriod,
  });

  factory FinancialReportDisclosureReviewRepositorySnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    final resolutionsByPeriod =
        <String, List<FinancialReportDisclosureResolution>>{};
    final rawPeriods = json['resolutionsByPeriod'];
    if (rawPeriods is Map) {
      for (final entry in rawPeriods.entries) {
        final resolutions = <FinancialReportDisclosureResolution>[];
        final rawResolutions = entry.value;
        if (rawResolutions is Iterable) {
          for (final rawResolution in rawResolutions) {
            final value = _asJsonMap(rawResolution);
            if (value != null) {
              resolutions.add(
                FinancialReportDisclosureResolution.fromJson(value),
              );
            }
          }
        }
        resolutionsByPeriod[entry.key.toString()] = resolutions;
      }
    }

    return FinancialReportDisclosureReviewRepositorySnapshot(
      resolutionsByPeriod: resolutionsByPeriod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'resolutionsByPeriod': resolutionsByPeriod.map(
        (key, value) =>
            MapEntry(key, value.map((item) => item.toJson()).toList()),
      ),
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
