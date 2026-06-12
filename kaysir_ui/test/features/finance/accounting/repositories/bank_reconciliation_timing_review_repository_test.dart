import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/repositories/bank_reconciliation_timing_review_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_bank_reconciliation_timing_review_repository.dart';

void main() {
  group('InMemoryBankReconciliationTimingReviewRepository', () {
    test('loads current period reviews defensively', () {
      final repository = InMemoryBankReconciliationTimingReviewRepository();
      repository.saveReview(periodKey: '202601', review: _review('REV-001'));

      final loaded = repository.loadReviews('202601');

      expect(loaded.keys, ['REV-001']);
      expect(
        () => loaded['REV-002'] = _review('REV-002'),
        throwsUnsupportedError,
      );
    });

    test('removes reviews without touching other periods', () {
      final repository = InMemoryBankReconciliationTimingReviewRepository();
      repository.saveReview(periodKey: '202601', review: _review('REV-001'));
      repository.saveReview(periodKey: '202602', review: _review('REV-001'));

      repository.removeReview(periodKey: '202601', reference: 'REV-001');

      expect(repository.loadReviews('202601'), isEmpty);
      expect(repository.loadReviews('202602').keys, ['REV-001']);
    });
  });

  group('LocalBankReconciliationTimingReviewRepository', () {
    test('hydrates period review evidence from a snapshot store', () async {
      final store = _MemoryTimingReviewSnapshotStore(
        snapshot:
            BankReconciliationTimingReviewRepositorySnapshot(
              reviewsByPeriod: {
                '202601': {'REV-001': _review('REV-001', owner: 'Controller')},
              },
            ).toJson(),
      );
      final repository = LocalBankReconciliationTimingReviewRepository(
        store: store,
      );

      await repository.hydrate();

      expect(repository.loadReviews('202601').keys, ['REV-001']);
      expect(repository.loadReviews('202601')['REV-001']?.owner, 'Controller');
    });

    test('persists saved and removed period reviews', () async {
      final store = _MemoryTimingReviewSnapshotStore();
      final repository = LocalBankReconciliationTimingReviewRepository(
        store: store,
      );

      repository.saveReview(periodKey: '202601', review: _review('REV-001'));
      await repository.persist();

      var persisted = BankReconciliationTimingReviewRepositorySnapshot.fromJson(
        store.snapshot!,
      );
      expect(persisted.reviewsByPeriod['202601']?.keys, ['REV-001']);

      repository.removeReview(periodKey: '202601', reference: 'REV-001');
      await repository.persist();

      persisted = BankReconciliationTimingReviewRepositorySnapshot.fromJson(
        store.snapshot!,
      );
      expect(persisted.reviewsByPeriod, isEmpty);
    });

    test(
      'keeps newer in-memory reviews when hydration completes late',
      () async {
        final store = _MemoryTimingReviewSnapshotStore(
          snapshot:
              BankReconciliationTimingReviewRepositorySnapshot(
                reviewsByPeriod: {
                  '202601': {'OLD': _review('OLD')},
                },
              ).toJson(),
          readDelay: const Duration(milliseconds: 1),
        );
        final repository = LocalBankReconciliationTimingReviewRepository(
          store: store,
        );

        final hydration = repository.hydrate();
        repository.saveReview(periodKey: '202601', review: _review('NEW'));
        await hydration;
        await repository.persist();

        expect(repository.loadReviews('202601').keys, ['NEW']);
        expect(
          BankReconciliationTimingReviewRepositorySnapshot.fromJson(
            store.snapshot!,
          ).reviewsByPeriod['202601']?.keys,
          ['NEW'],
        );
      },
    );
  });

  group('BankReconciliationTimingReview JSON', () {
    test('round-trips persisted review evidence', () {
      final review = _review(
        'REV-001',
        status: BankReconciliationTimingReviewStatus.adjusted,
        owner: 'Treasury',
        note: 'Adjustment posted to cash ledger.',
      );

      final decoded = BankReconciliationTimingReview.fromJson(review.toJson());

      expect(decoded.reference, 'REV-001');
      expect(decoded.status, BankReconciliationTimingReviewStatus.adjusted);
      expect(decoded.owner, 'Treasury');
      expect(decoded.note, 'Adjustment posted to cash ledger.');
      expect(decoded.reviewedAt, DateTime(2026, 2, 1, 9));
    });
  });
}

class _MemoryTimingReviewSnapshotStore
    implements BankReconciliationTimingReviewSnapshotStore {
  Map<String, dynamic>? snapshot;
  final Duration? readDelay;

  _MemoryTimingReviewSnapshotStore({this.snapshot, this.readDelay});

  @override
  Future<Map<String, dynamic>?> read() async {
    final delay = readDelay;
    if (delay != null) {
      await Future<void>.delayed(delay);
    }
    return snapshot;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    this.snapshot = snapshot;
  }
}

BankReconciliationTimingReview _review(
  String reference, {
  BankReconciliationTimingReviewStatus status =
      BankReconciliationTimingReviewStatus.inReview,
  String owner = 'Controller',
  String note = 'Waiting for clearing evidence.',
}) {
  return BankReconciliationTimingReview(
    reference: reference,
    status: status,
    owner: owner,
    note: note,
    reviewedAt: DateTime(2026, 2, 1, 9),
  );
}
