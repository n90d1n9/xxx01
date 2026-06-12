import 'dart:async';

import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/bank_reconciliation_timing_review.dart';
import 'bank_reconciliation_timing_review_repository.dart';

abstract class BankReconciliationTimingReviewSnapshotStore {
  Future<Map<String, dynamic>?> read();

  Future<void> write(Map<String, dynamic> snapshot);
}

class LocalDbBankReconciliationTimingReviewSnapshotStore
    implements BankReconciliationTimingReviewSnapshotStore {
  static const defaultStorageKey =
      'accounting.bank_reconciliation_timing_reviews.snapshot.v1';

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  LocalDbBankReconciliationTimingReviewSnapshotStore({
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

class LocalBankReconciliationTimingReviewRepository
    extends InMemoryBankReconciliationTimingReviewRepository
    implements HydratableBankReconciliationTimingReviewRepository {
  final BankReconciliationTimingReviewSnapshotStore store;
  Future<void>? _hydrateFuture;
  Future<void>? _persistFuture;
  bool _dirtyDuringHydrate = false;

  LocalBankReconciliationTimingReviewRepository({
    required this.store,
    super.reviewsByPeriod,
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
  void saveReview({
    required String periodKey,
    required BankReconciliationTimingReview review,
  }) {
    super.saveReview(periodKey: periodKey, review: review);
    _dirtyDuringHydrate = true;
    unawaited(_queuePersist());
  }

  @override
  void removeReview({required String periodKey, required String reference}) {
    super.removeReview(periodKey: periodKey, reference: reference);
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

    final BankReconciliationTimingReviewRepositorySnapshot snapshot;
    try {
      snapshot = BankReconciliationTimingReviewRepositorySnapshot.fromJson(
        data,
      );
    } catch (_) {
      return;
    }

    if (_dirtyDuringHydrate) {
      await _queuePersist();
      return;
    }

    replaceAll(snapshot.reviewsByPeriod);
  }

  Future<void> _queuePersist() {
    final pending = _persistFuture?.catchError((_) {}) ?? Future<void>.value();
    return _persistFuture = pending.then((_) {
      return store.write(
        BankReconciliationTimingReviewRepositorySnapshot(
          reviewsByPeriod: loadReviewsByPeriod(),
        ).toJson(),
      );
    });
  }
}

class BankReconciliationTimingReviewRepositorySnapshot {
  final Map<String, Map<String, BankReconciliationTimingReview>>
  reviewsByPeriod;

  const BankReconciliationTimingReviewRepositorySnapshot({
    required this.reviewsByPeriod,
  });

  factory BankReconciliationTimingReviewRepositorySnapshot.fromJson(
    Map<String, dynamic> json,
  ) {
    final reviewsByPeriod =
        <String, Map<String, BankReconciliationTimingReview>>{};
    final rawPeriods = json['reviewsByPeriod'];
    if (rawPeriods is Map) {
      for (final entry in rawPeriods.entries) {
        final reviews = <String, BankReconciliationTimingReview>{};
        final rawReviews = entry.value;
        if (rawReviews is Iterable) {
          for (final rawReview in rawReviews) {
            final value = _asJsonMap(rawReview);
            if (value == null) {
              continue;
            }
            try {
              final review = BankReconciliationTimingReview.fromJson(value);
              reviews[review.reference] = review;
            } catch (_) {
              continue;
            }
          }
        }
        reviewsByPeriod[entry.key.toString()] = reviews;
      }
    }

    return BankReconciliationTimingReviewRepositorySnapshot(
      reviewsByPeriod: reviewsByPeriod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': 1,
      'reviewsByPeriod': reviewsByPeriod.map(
        (periodKey, reviews) => MapEntry(
          periodKey,
          reviews.values.map((review) => review.toJson()).toList(),
        ),
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
