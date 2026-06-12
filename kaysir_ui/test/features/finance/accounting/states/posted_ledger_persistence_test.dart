import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/repositories/posted_ledger_repository.dart';
import 'package:kaysir/features/finance/accounting/states/accounting_core_provider.dart';

void main() {
  group('PostedLedgerNotifier persistence', () {
    test('hydrates and writes postings through repository', () {
      final repository = InMemoryPostedLedgerRepository(
        postings: [_posting('seeded')],
      );

      final notifier = PostedLedgerNotifier(repository: repository);
      final next = _posting('next');
      notifier.addPosting(next);

      expect(notifier.state.map((posting) => posting.id), ['seeded', 'next']);
      expect(repository.loadPostings().map((posting) => posting.id), [
        'seeded',
        'next',
      ]);
    });

    test('clears postings through repository', () {
      final repository = InMemoryPostedLedgerRepository(
        postings: [_posting('seeded')],
      );
      final notifier = PostedLedgerNotifier(repository: repository);

      notifier.clear();

      expect(notifier.state, isEmpty);
      expect(repository.loadPostings(), isEmpty);
    });
  });
}

LedgerPosting _posting(String id) {
  return LedgerPosting(
    id: id,
    journalId: 'journal-$id',
    entryDate: DateTime(2026, 1, 31),
    postedAt: DateTime(2026, 2, 1, 9),
    reference: 'REF-$id',
    description: 'Posted ledger test',
    source: JournalSource.manualAdjustment,
    lines: const [
      LedgerPostingLine(
        id: 'line-1',
        accountId: 'cash',
        accountName: 'Cash',
        side: JournalSide.debit,
        amount: 100,
      ),
      LedgerPostingLine(
        id: 'line-2',
        accountId: 'revenue',
        accountName: 'Revenue',
        side: JournalSide.credit,
        amount: 100,
      ),
    ],
  );
}
