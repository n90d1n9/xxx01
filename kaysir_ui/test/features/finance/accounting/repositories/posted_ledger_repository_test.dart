import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/repositories/local_posted_ledger_repository.dart';
import 'package:kaysir/features/finance/accounting/repositories/posted_ledger_repository.dart';

void main() {
  group('InMemoryPostedLedgerRepository', () {
    test('loads saved postings defensively', () {
      final repository = InMemoryPostedLedgerRepository();
      final posting = _posting('posting-1');

      repository.appendPosting(posting);
      final loaded = repository.loadPostings();

      expect(loaded.single, posting);
      expect(() => loaded.add(_posting('posting-2')), throwsUnsupportedError);
    });
  });

  group('LocalPostedLedgerRepository', () {
    test('hydrates postings from a snapshot store', () async {
      final posting = _posting('posting-1');
      final store = _MemorySnapshotStore(
        snapshot: PostedLedgerRepositorySnapshot(postings: [posting]).toJson(),
      );
      final repository = LocalPostedLedgerRepository(store: store);

      await repository.hydrate();

      expect(repository.loadPostings().single.id, 'posting-1');
      expect(
        repository.loadPostings().single.source,
        JournalSource.periodClose,
      );
    });

    test('persists postings as a snapshot', () async {
      final posting = _posting('posting-1');
      final store = _MemorySnapshotStore();
      final repository = LocalPostedLedgerRepository(store: store);

      repository.appendPosting(posting);
      await repository.persist();

      final persisted = PostedLedgerRepositorySnapshot.fromJson(
        store.snapshot!,
      );
      expect(persisted.postings.single.reference, 'CLOSE-20260131');
      expect(persisted.postings.single.lines.single.accountName, 'Cash');
    });

    test(
      'keeps newer in-memory postings when hydration completes late',
      () async {
        final stored = _posting('stored');
        final newer = _posting('newer');
        final store = _MemorySnapshotStore(
          snapshot: PostedLedgerRepositorySnapshot(postings: [stored]).toJson(),
          readDelay: const Duration(milliseconds: 1),
        );
        final repository = LocalPostedLedgerRepository(store: store);

        final hydration = repository.hydrate();
        repository.appendPosting(newer);
        await hydration;
        await repository.persist();

        expect(repository.loadPostings().map((posting) => posting.id), [
          'newer',
        ]);
        expect(
          PostedLedgerRepositorySnapshot.fromJson(
            store.snapshot!,
          ).postings.single.id,
          'newer',
        );
      },
    );
  });

  group('LedgerPosting JSON', () {
    test('round-trips postings and lines', () {
      final posting = _posting('posting-1');

      final decoded = LedgerPosting.fromJson(posting.toJson());

      expect(decoded.id, 'posting-1');
      expect(decoded.source, JournalSource.periodClose);
      expect(decoded.lines.single.side, JournalSide.debit);
      expect(decoded.lines.single.signedAmount, 500);
    });
  });
}

class _MemorySnapshotStore implements PostedLedgerSnapshotStore {
  Map<String, dynamic>? snapshot;
  final Duration? readDelay;

  _MemorySnapshotStore({this.snapshot, this.readDelay});

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

LedgerPosting _posting(String id) {
  return LedgerPosting(
    id: id,
    journalId: 'period-close-20260131',
    entryDate: DateTime(2026, 1, 31),
    postedAt: DateTime(2026, 2, 1, 9),
    reference: 'CLOSE-20260131',
    description: 'Close nominal accounts',
    source: JournalSource.periodClose,
    lines: const [
      LedgerPostingLine(
        id: 'posting-1-1',
        accountId: 'cash',
        accountName: 'Cash',
        side: JournalSide.debit,
        amount: 500,
      ),
    ],
  );
}
