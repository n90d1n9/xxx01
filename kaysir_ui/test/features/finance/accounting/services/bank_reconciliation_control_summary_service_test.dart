import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_control_summary.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/services/bank_reconciliation_control_summary_service.dart';
import 'package:kaysir/features/finance/accounting/services/bank_reconciliation_resolution_service.dart';

void main() {
  group('BankReconciliationControlSummaryService', () {
    const summaryService = BankReconciliationControlSummaryService();
    const resolutionService = BankReconciliationResolutionService();

    test('asks for statement evidence before close readiness', () {
      final summary = summaryService.summarize(
        reconciliation: const BankReconciliation(
          statementLines: [],
          ledgerLines: [],
          matches: [],
          unmatchedStatementLines: [],
          unmatchedLedgerLines: [],
        ),
        resolutionPlan: const BankReconciliationResolutionPlan(actions: []),
        asOfDate: DateTime(2026, 1, 31),
      );

      expect(summary.severity, BankReconciliationControlSeverity.needsEvidence);
      expect(summary.statusLabel, 'Needs statement');
      expect(summary.requiresAttention, isTrue);
      expect(summary.oldestUnmatchedAgeDays, isNull);
    });

    test('marks a fully matched reconciliation as balanced', () {
      final statementLine = _statement('BNK-001', amount: 1200);
      final ledgerLine = _ledger('BNK-001', TransactionType.debit, 1200);
      final reconciliation = BankReconciliation(
        statementLines: [statementLine],
        ledgerLines: [ledgerLine],
        matches: [
          BankReconciliationMatch(
            statementLine: statementLine,
            ledgerLine: ledgerLine,
            matchType: BankReconciliationMatchType.reference,
            dateDifferenceDays: 0,
            amountVariance: 0,
          ),
        ],
        unmatchedStatementLines: const [],
        unmatchedLedgerLines: const [],
      );

      final summary = summaryService.summarize(
        reconciliation: reconciliation,
        resolutionPlan: resolutionService.build(reconciliation),
        asOfDate: DateTime(2026, 1, 31),
      );

      expect(summary.severity, BankReconciliationControlSeverity.ready);
      expect(summary.statusLabel, 'Balanced');
      expect(summary.isReadyToClose, isTrue);
      expect(summary.matchedCount, 1);
      expect(summary.oldestUnmatchedAgeLabel, 'N/A');
    });

    test('prioritizes unmatched statement rows that need journals', () {
      final fee = _statement(
        'ADM-001',
        amount: -15000,
        description: 'Biaya admin bank',
      );
      final reconciliation = BankReconciliation(
        statementLines: [fee],
        ledgerLines: const [],
        matches: const [],
        unmatchedStatementLines: [fee],
        unmatchedLedgerLines: const [],
      );

      final summary = summaryService.summarize(
        reconciliation: reconciliation,
        resolutionPlan: resolutionService.build(reconciliation),
        asOfDate: DateTime(2026, 1, 31),
      );

      expect(
        summary.severity,
        BankReconciliationControlSeverity.postAdjustments,
      );
      expect(summary.suggestedJournalCount, 1);
      expect(summary.timingDifferenceCount, 0);
      expect(summary.oldestUnmatchedReference, 'ADM-001');
      expect(summary.oldestUnmatchedAgeDays, 26);
      expect(summary.hasStaleUnmatchedItems, isFalse);
    });

    test('flags stale timing differences for review', () {
      final statementLine = _statement('BNK-001', amount: 1200);
      final matchedLedger = _ledger('BNK-001', TransactionType.debit, 1200);
      final outstandingPayment = _ledger(
        'PAY-001',
        TransactionType.credit,
        450,
      );
      final reconciliation = BankReconciliation(
        statementLines: [statementLine],
        ledgerLines: [matchedLedger, outstandingPayment],
        matches: [
          BankReconciliationMatch(
            statementLine: statementLine,
            ledgerLine: matchedLedger,
            matchType: BankReconciliationMatchType.reference,
            dateDifferenceDays: 0,
            amountVariance: 0,
          ),
        ],
        unmatchedStatementLines: const [],
        unmatchedLedgerLines: [outstandingPayment],
      );

      final summary = summaryService.summarize(
        reconciliation: reconciliation,
        resolutionPlan: resolutionService.build(reconciliation),
        asOfDate: DateTime(2026, 2, 10),
      );

      expect(summary.severity, BankReconciliationControlSeverity.timingReview);
      expect(summary.suggestedJournalCount, 0);
      expect(summary.timingDifferenceCount, 1);
      expect(summary.oldestUnmatchedReference, 'PAY-001');
      expect(summary.oldestUnmatchedAgeDays, 36);
      expect(summary.hasStaleUnmatchedItems, isTrue);
      expect(summary.timingAging.staleCount, 1);
      expect(summary.timingAgingLabel, 'Current 0 / Watch 0 / Stale 1');
    });

    test('ages timing differences into close review buckets', () {
      final statementLine = _statement('BNK-001', amount: 1200);
      final matchedLedger = _ledger('BNK-001', TransactionType.debit, 1200);
      final currentDeposit = _ledger(
        'DEP-001',
        TransactionType.debit,
        100,
        date: DateTime(2026, 1, 29),
      );
      final watchPayment = _ledger(
        'PAY-001',
        TransactionType.credit,
        200,
        date: DateTime(2026, 1, 5),
      );
      final stalePayment = _ledger(
        'PAY-002',
        TransactionType.credit,
        300,
        date: DateTime(2025, 12, 30),
      );
      final reconciliation = BankReconciliation(
        statementLines: [statementLine],
        ledgerLines: [
          matchedLedger,
          currentDeposit,
          watchPayment,
          stalePayment,
        ],
        matches: [
          BankReconciliationMatch(
            statementLine: statementLine,
            ledgerLine: matchedLedger,
            matchType: BankReconciliationMatchType.reference,
            dateDifferenceDays: 0,
            amountVariance: 0,
          ),
        ],
        unmatchedStatementLines: const [],
        unmatchedLedgerLines: [currentDeposit, watchPayment, stalePayment],
      );

      final summary = summaryService.summarize(
        reconciliation: reconciliation,
        resolutionPlan: resolutionService.build(reconciliation),
        asOfDate: DateTime(2026, 1, 31),
      );

      expect(summary.timingDifferenceCount, 3);
      expect(summary.timingAging.currentCount, 1);
      expect(summary.timingAging.watchCount, 1);
      expect(summary.timingAging.staleCount, 1);
      expect(summary.timingAging.currentAmount, 100);
      expect(summary.timingAging.watchAmount, 200);
      expect(summary.timingAging.staleAmount, 300);
      expect(summary.timingAging.totalAmount, 600);
      expect(summary.timingAgingLabel, 'Current 1 / Watch 1 / Stale 1');
      expect(
        summary.timingAging.amountLabel((amount) => amount.toStringAsFixed(0)),
        'Current 100 / Watch 200 / Stale 300',
      );
    });
  });
}

BankStatementLine _statement(
  String id, {
  required double amount,
  String description = 'Customer transfer',
}) {
  return BankStatementLine(
    id: id,
    date: DateTime(2026, 1, 5),
    description: description,
    amount: amount,
    reference: id,
  );
}

BankLedgerReconciliationLine _ledger(
  String id,
  TransactionType type,
  double amount, {
  DateTime? date,
}) {
  return BankLedgerReconciliationLine(
    transactionId: id,
    date: date ?? DateTime(2026, 1, 5),
    account: '1000 - Bank Mandiri',
    description: 'Ledger movement',
    reference: id,
    type: type,
    amount: amount,
  );
}
