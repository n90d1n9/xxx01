import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_bank_reconciliation_timing_review_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_bank_statement_repository.dart';
import 'package:kaysir/features/finance/accounting/states/bank_reconciliation_provider.dart';

void main() {
  group('BankStatementLineNotifier', () {
    test('hydrates from repository and persists explicit mutations', () async {
      final stored = _line('stored');
      final store = _MemorySnapshotStore(
        snapshot: BankStatementRepositorySnapshot(lines: [stored]).toJson(),
      );
      final repository = LocalBankStatementRepository(store: store);
      final notifier = BankStatementLineNotifier(repository: repository);
      addTearDown(notifier.dispose);

      await repository.hydrate();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.map((line) => line.id), ['stored']);

      notifier.addLine(_line('manual'));
      await repository.persist();

      expect(notifier.state.map((line) => line.id), ['stored', 'manual']);
      expect(
        BankStatementRepositorySnapshot.fromJson(
          store.snapshot!,
        ).lines.map((line) => line.id),
        ['stored', 'manual'],
      );

      notifier.removeLine('manual');
      await repository.persist();

      expect(notifier.state.map((line) => line.id), ['stored']);
      expect(
        BankStatementRepositorySnapshot.fromJson(
          store.snapshot!,
        ).lines.map((line) => line.id),
        ['stored'],
      );

      notifier.clear();
      await repository.persist();

      expect(notifier.state, isEmpty);
      expect(
        BankStatementRepositorySnapshot.fromJson(store.snapshot!).lines,
        isEmpty,
      );
    });
  });

  group('BankReconciliationTimingReviewsNotifier', () {
    test('hydrates and persists reviews for the selected period', () async {
      final store = _TimingReviewSnapshotStore(
        snapshot:
            BankReconciliationTimingReviewRepositorySnapshot(
              reviewsByPeriod: {
                '20260101-20260131': {
                  'STORED': _review('STORED', owner: 'Controller'),
                },
              },
            ).toJson(),
      );
      final repository = LocalBankReconciliationTimingReviewRepository(
        store: store,
      );
      final notifier = BankReconciliationTimingReviewsNotifier(
        repository: repository,
        periodKey: '20260101-20260131',
      );
      addTearDown(notifier.dispose);

      await repository.hydrate();
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.keys, ['STORED']);

      notifier.saveReview(_review('MANUAL', owner: 'Treasury'));
      await repository.persist();

      expect(notifier.state.keys, ['MANUAL', 'STORED']);
      expect(
        BankReconciliationTimingReviewRepositorySnapshot.fromJson(
          store.snapshot!,
        ).reviewsByPeriod['20260101-20260131']?.keys,
        ['MANUAL', 'STORED'],
      );

      notifier.clearReview('MANUAL');
      await repository.persist();

      expect(notifier.state.keys, ['STORED']);
      expect(
        BankReconciliationTimingReviewRepositorySnapshot.fromJson(
          store.snapshot!,
        ).reviewsByPeriod['20260101-20260131']?.keys,
        ['STORED'],
      );
    });
  });
}

class _MemorySnapshotStore implements BankStatementSnapshotStore {
  Map<String, dynamic>? snapshot;

  _MemorySnapshotStore({this.snapshot});

  @override
  Future<Map<String, dynamic>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    this.snapshot = snapshot;
  }
}

class _TimingReviewSnapshotStore
    implements BankReconciliationTimingReviewSnapshotStore {
  Map<String, dynamic>? snapshot;

  _TimingReviewSnapshotStore({this.snapshot});

  @override
  Future<Map<String, dynamic>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, dynamic> snapshot) async {
    this.snapshot = snapshot;
  }
}

BankStatementLine _line(String id) {
  return BankStatementLine(
    id: id,
    date: DateTime(2026, 1, 5),
    description: 'Bank movement',
    amount: 1200,
    reference: 'BNK-001',
  );
}

BankReconciliationTimingReview _review(String reference, {String? owner}) {
  return BankReconciliationTimingReview(
    reference: reference,
    status: BankReconciliationTimingReviewStatus.inReview,
    owner: owner ?? 'Controller',
    note: 'Waiting for clearing evidence.',
    reviewedAt: DateTime(2026, 2, 1, 9),
  );
}
