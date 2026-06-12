import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/services/trial_balance_service.dart';

void main() {
  group('TrialBalanceService', () {
    const service = TrialBalanceService();

    test('builds opening, movement, and closing balances by account', () {
      final report = service.buildReport(
        transactions: [
          _trx(
            date: DateTime(2026, 5, 31),
            account: '1000 Cash',
            type: TransactionType.debit,
            amount: 1000,
          ),
          _trx(
            date: DateTime(2026, 6, 2),
            account: '1000 Cash',
            type: TransactionType.credit,
            amount: 250,
          ),
          _trx(
            date: DateTime(2026, 6, 2),
            account: '4000 Revenue',
            type: TransactionType.credit,
            amount: 250,
            category: 'Revenue',
          ),
        ],
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 30),
      );

      final cash = report.rows.singleWhere((row) => row.account == '1000 Cash');
      expect(cash.openingBalance, 1000);
      expect(cash.debitMovement, 0);
      expect(cash.creditMovement, 250);
      expect(cash.debitBalance, 750);
      expect(cash.entryCount, 1);

      final revenue = report.rows.singleWhere(
        (row) => row.account == '4000 Revenue',
      );
      expect(revenue.creditMovement, 250);
      expect(revenue.creditBalance, 250);

      expect(report.summary.totalDebits, 750);
      expect(report.summary.totalCredits, 250);
      expect(report.summary.variance, 500);
      expect(report.summary.isBalanced, isFalse);
      expect(report.blockerCount, 1);
      expect(
        report.diagnostics.map((diagnostic) => diagnostic.id),
        contains('trial-balance-variance'),
      );
      expect(
        report.diagnostics
            .singleWhere(
              (diagnostic) => diagnostic.id == 'trial-balance-variance',
            )
            .affectedAccounts,
        containsAll(['1000 Cash', '4000 Revenue']),
      );
    });

    test('filters by date and query and reports close readiness checks', () {
      final report = service.buildReport(
        transactions: [
          _trx(
            date: DateTime(2026, 6, 1),
            account: '1000 Cash',
            description: 'Owner funding',
            type: TransactionType.debit,
            amount: 500,
            reference: 'CAP-1',
          ),
          _trx(
            date: DateTime(2026, 6, 1),
            account: '3000 Equity',
            description: 'Owner funding',
            type: TransactionType.credit,
            amount: 500,
            category: 'Equity',
            reference: 'CAP-1',
          ),
          _trx(
            date: DateTime(2026, 7, 1),
            account: '1000 Cash',
            description: 'Outside period',
            type: TransactionType.debit,
            amount: 100,
          ),
        ],
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 30),
        query: 'owner',
      );

      expect(report.transactions, hasLength(2));
      expect(report.summary.isBalanced, isTrue);
      expect(report.isReadyForClose, isTrue);
      expect(
        report.closeChecks.map((check) => check.label),
        containsAll([
          'Debits equal credits',
          'References assigned',
          'Categories mapped',
          'Activity loaded',
        ]),
      );
    });

    test('reports missing references, unmapped accounts, and no activity', () {
      final report = service.buildReport(
        transactions: const [],
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 31),
      );

      expect(report.warningCount, 1);
      expect(
        report.diagnostics.map((diagnostic) => diagnostic.id),
        contains('no-period-activity'),
      );

      final currentPeriodReport = service.buildReport(
        transactions: [
          _trx(
            id: 'trx-missing-reference',
            date: DateTime(2026, 6, 1),
            account: '1000 Cash',
            type: TransactionType.debit,
            amount: 100,
            reference: '',
            category: '',
            journalId: 'JE-MISSING-1',
          ),
        ],
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 30),
      );

      expect(currentPeriodReport.blockerCount, 1);
      expect(currentPeriodReport.warningCount, 2);
      expect(
        currentPeriodReport.diagnostics.map((diagnostic) => diagnostic.id),
        containsAll([
          'trial-balance-variance',
          'missing-references',
          'unmapped-categories',
        ]),
      );
      expect(
        currentPeriodReport.diagnostics
            .singleWhere((diagnostic) => diagnostic.id == 'missing-references')
            .affectedAccounts,
        ['1000 Cash'],
      );
      expect(
        currentPeriodReport.diagnostics
            .singleWhere((diagnostic) => diagnostic.id == 'missing-references')
            .affectedTransactionIds,
        ['JE-MISSING-1'],
      );
      expect(
        currentPeriodReport.diagnostics
            .singleWhere((diagnostic) => diagnostic.id == 'unmapped-categories')
            .affectedAccounts,
        ['1000 Cash'],
      );
    });
  });
}

LedgerTransaction _trx({
  String? id,
  required DateTime date,
  required String account,
  required TransactionType type,
  required double amount,
  String description = 'Trial balance test',
  String category = 'Asset',
  String reference = 'JE-1',
  String? journalId,
}) {
  return LedgerTransaction(
    id: id,
    date: date,
    account: account,
    description: description,
    type: type,
    amount: amount,
    reference: reference,
    category: category,
    journalId: journalId,
  );
}
