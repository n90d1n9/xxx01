import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/services/bank_reconciliation_resolution_service.dart';

void main() {
  group('BankReconciliationResolutionService', () {
    const service = BankReconciliationResolutionService();

    test('suggests journals for bank fees and bank interest', () {
      final plan = service.build(
        BankReconciliation(
          statementLines: const [],
          ledgerLines: const [],
          matches: const [],
          unmatchedStatementLines: [
            _statement('fee', amount: -15000, description: 'Biaya admin bank'),
            _statement('interest', amount: 25000, description: 'Bunga bank'),
          ],
          unmatchedLedgerLines: const [],
        ),
      );

      expect(plan.suggestedJournalCount, 2);
      expect(plan.timingDifferenceCount, 0);
      expect(plan.actions.map((action) => action.type), [
        BankReconciliationResolutionType.bankFee,
        BankReconciliationResolutionType.bankInterest,
      ]);
      expect(plan.actions.first.title, 'Post bank fee expense');
      expect(plan.actions.last.title, 'Post bank interest income');
    });

    test('classifies generic statement-only cash movements', () {
      final plan = service.build(
        BankReconciliation(
          statementLines: const [],
          ledgerLines: const [],
          matches: const [],
          unmatchedStatementLines: [
            _statement(
              'receipt',
              amount: 1000,
              description: 'Customer payment',
            ),
            _statement(
              'payment',
              amount: -300,
              description: 'Supplier payment',
            ),
          ],
          unmatchedLedgerLines: const [],
        ),
      );

      expect(plan.actions.map((action) => action.type), [
        BankReconciliationResolutionType.statementOnlyReceipt,
        BankReconciliationResolutionType.statementOnlyPayment,
      ]);
      expect(plan.actions.map((action) => action.suggestsJournal), [
        isTrue,
        isTrue,
      ]);
    });

    test('classifies ledger-only rows as timing differences', () {
      final plan = service.build(
        BankReconciliation(
          statementLines: const [],
          ledgerLines: const [],
          matches: const [],
          unmatchedStatementLines: const [],
          unmatchedLedgerLines: [
            _ledger('receipt', TransactionType.debit, 1200),
            _ledger('payment', TransactionType.credit, 450),
          ],
        ),
      );

      expect(plan.suggestedJournalCount, 0);
      expect(plan.timingDifferenceCount, 2);
      expect(plan.actions.map((action) => action.type), [
        BankReconciliationResolutionType.depositInTransit,
        BankReconciliationResolutionType.outstandingPayment,
      ]);
    });
  });
}

BankStatementLine _statement(
  String id, {
  required double amount,
  required String description,
}) {
  return BankStatementLine(
    id: id,
    date: DateTime(2026, 1, 5),
    description: description,
    amount: amount,
    reference: id.toUpperCase(),
  );
}

BankLedgerReconciliationLine _ledger(
  String id,
  TransactionType type,
  double amount,
) {
  return BankLedgerReconciliationLine(
    transactionId: id,
    date: DateTime(2026, 1, 5),
    account: '1000 - Bank Mandiri',
    description: 'Ledger movement',
    reference: id.toUpperCase(),
    type: type,
    amount: amount,
  );
}
