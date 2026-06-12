import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_filter.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/states/gl/filter_provider.dart';
import 'package:kaysir/features/finance/accounting/states/gl/ledger_provider.dart';

void main() {
  group('filteredLedgerProvider', () {
    test('searches transaction IDs, journal IDs, accounts, and categories', () {
      final container = ProviderContainer(
        overrides: [
          combinedLedgerProvider.overrideWithValue([
            _trx(
              id: 'trx-001',
              journalId: 'JE-MISSING-1',
              account: '1000 Cash',
              category: 'Asset',
            ),
            _trx(
              id: 'trx-002',
              journalId: 'JE-OTHER-1',
              account: '6100 Professional fees',
              category: 'Expense',
            ),
          ]),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container
            .read(
              filteredLedgerProvider(
                const LedgerFilter(searchTerm: 'JE-MISSING-1'),
              ),
            )
            .map((transaction) => transaction.id),
        ['trx-001'],
      );
      expect(
        container
            .read(
              filteredLedgerProvider(const LedgerFilter(searchTerm: '6100')),
            )
            .map((transaction) => transaction.id),
        ['trx-002'],
      );
      expect(
        container
            .read(
              filteredLedgerProvider(const LedgerFilter(searchTerm: 'expense')),
            )
            .map((transaction) => transaction.id),
        ['trx-002'],
      );
    });
  });
}

LedgerTransaction _trx({
  required String id,
  required String journalId,
  required String account,
  required String category,
}) {
  return LedgerTransaction(
    id: id,
    date: DateTime(2026, 6, 1),
    account: account,
    description: 'Filtered ledger provider test',
    type: TransactionType.debit,
    amount: 100,
    reference: 'REF-$id',
    category: category,
    journalId: journalId,
  );
}
