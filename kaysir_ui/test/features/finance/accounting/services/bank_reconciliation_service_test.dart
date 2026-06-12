import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/services/bank_reconciliation_service.dart';

void main() {
  group('BankReconciliationService', () {
    const service = BankReconciliationService();

    test('matches bank statement lines to cash ledger by reference', () {
      final reconciliation = service.reconcile(
        statementLines: [
          BankStatementLine(
            id: 'stmt-1',
            date: DateTime(2026, 1, 6),
            description: 'Customer transfer',
            amount: 1200,
            reference: 'BNK-001',
          ),
          BankStatementLine(
            id: 'stmt-2',
            date: DateTime(2026, 1, 7),
            description: 'Supplier payment',
            amount: -300,
            reference: 'BNK-002',
          ),
        ],
        ledgerTransactions: [
          LedgerTransaction(
            id: 'cash-in',
            date: DateTime(2026, 1, 5),
            account: '1000 - Bank Mandiri',
            description: 'Customer transfer',
            type: TransactionType.debit,
            amount: 1200,
            reference: 'BNK-001',
            category: 'Receipt',
          ),
          LedgerTransaction(
            id: 'cash-out',
            date: DateTime(2026, 1, 7),
            account: '1000 - Bank Mandiri',
            description: 'Supplier payment',
            type: TransactionType.credit,
            amount: 300,
            reference: 'BNK-002',
            category: 'Payment',
          ),
          LedgerTransaction(
            id: 'expense',
            date: DateTime(2026, 1, 7),
            account: '5000 - Rent expense',
            description: 'Supplier payment',
            type: TransactionType.debit,
            amount: 300,
            reference: 'BNK-002',
            category: 'Expense',
          ),
        ],
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(reconciliation.statementMovement, 900);
      expect(reconciliation.ledgerMovement, 900);
      expect(reconciliation.variance, 0);
      expect(reconciliation.matches, hasLength(2));
      expect(
        reconciliation.matches.first.matchType,
        BankReconciliationMatchType.reference,
      );
      expect(reconciliation.unmatchedStatementLines, isEmpty);
      expect(reconciliation.unmatchedLedgerLines, isEmpty);
      expect(reconciliation.isBalanced, isTrue);
      expect(reconciliation.blocksClose, isFalse);
    });

    test(
      'reports unmatched statement and ledger activity as close blockers',
      () {
        final reconciliation = service.reconcile(
          statementLines: [
            BankStatementLine(
              id: 'stmt-1',
              date: DateTime(2026, 1, 8),
              description: 'Unposted bank fee',
              amount: -25,
              reference: 'FEE-001',
            ),
          ],
          ledgerTransactions: [
            LedgerTransaction(
              id: 'cash-in',
              date: DateTime(2026, 1, 8),
              account: '1000 - Cash',
              description: 'Cash sale',
              type: TransactionType.debit,
              amount: 100,
              reference: 'SALE-001',
              category: 'Receipt',
            ),
          ],
        );

        expect(reconciliation.statementMovement, -25);
        expect(reconciliation.ledgerMovement, 100);
        expect(reconciliation.variance, -125);
        expect(reconciliation.matches, isEmpty);
        expect(reconciliation.unmatchedStatementLines, hasLength(1));
        expect(reconciliation.unmatchedLedgerLines, hasLength(1));
        expect(reconciliation.isBalanced, isFalse);
        expect(reconciliation.blocksClose, isTrue);
      },
    );

    test('prefers the nearest ledger date for amount/date matches', () {
      final reconciliation = service.reconcile(
        statementLines: [
          BankStatementLine(
            id: 'stmt-1',
            date: DateTime(2026, 1, 10),
            description: 'Card settlement',
            amount: 450,
          ),
        ],
        ledgerTransactions: [
          LedgerTransaction(
            id: 'older-cash',
            date: DateTime(2026, 1, 8),
            account: '1000 - Bank BCA',
            description: 'Card settlement',
            type: TransactionType.debit,
            amount: 450,
            reference: 'CARD-OLD',
            category: 'Receipt',
          ),
          LedgerTransaction(
            id: 'exact-cash',
            date: DateTime(2026, 1, 10),
            account: '1000 - Bank BCA',
            description: 'Card settlement',
            type: TransactionType.debit,
            amount: 450,
            reference: 'CARD-NEW',
            category: 'Receipt',
          ),
        ],
      );

      expect(
        reconciliation.matches.single.ledgerLine.transactionId,
        'exact-cash',
      );
      expect(
        reconciliation.matches.single.matchType,
        BankReconciliationMatchType.amountAndDate,
      );
    });
  });
}
