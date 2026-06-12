import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_control_summary.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_journal_draft.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/widgets/bank_reconciliation_detail_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/reconciliation_detail_components.dart';

void main() {
  group('bank reconciliation detail components', () {
    testWidgets('render bank summary and evidence tables', (tester) async {
      final reconciliation = _reconciliation();
      final timingItems = [_timingItem()];
      final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
      final dateFormat = DateFormat('MM/dd/yyyy');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BankReconciliationControlHealthPanel(
                      summary: _controlSummary(),
                      timingSummary:
                          BankReconciliationTimingRegisterSummary.fromItems(
                            timingItems,
                          ),
                      timingReviewSummary:
                          BankReconciliationTimingReviewSummary.fromItems(
                            items: timingItems,
                            reviews: const {},
                          ),
                      dateFormat: dateFormat,
                      statusColor: Colors.deepOrange,
                    ),
                    const SizedBox(height: 12),
                    BankReconciliationTotalsPanel(
                      reconciliation: reconciliation,
                      currency: currency,
                      statusColor: Colors.deepOrange,
                    ),
                    const SizedBox(height: 12),
                    BankStatementManagementTable(
                      lines: reconciliation.statementLines,
                      currency: currency,
                      dateFormat: dateFormat,
                      onRemove: (_) {},
                    ),
                    const SizedBox(height: 12),
                    BankResolutionActionTable(
                      actions: [_resolutionAction()],
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                    const SizedBox(height: 12),
                    BankJournalDraftSuggestionTable(
                      suggestions: [
                        BankReconciliationJournalDraftSuggestion(
                          action: _resolutionAction(),
                          draft: null,
                          issues: const ['Missing bank fee account'],
                        ),
                      ],
                      currency: currency,
                      onPost: (_) {},
                    ),
                    const SizedBox(height: 12),
                    BankMatchReconciliationTable(
                      matches: reconciliation.matches,
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('bank-reconciliation-control-health-strip')),
        findsOneWidget,
      );
      expect(find.byType(ReconciliationMetricStrip), findsNWidgets(2));
      expect(find.byType(ReconciliationTableShell), findsNWidgets(4));
      expect(find.text('Control Status'), findsOneWidget);
      expect(find.text('Timing Review'), findsOneWidget);
      expect(find.text('0/1'), findsOneWidget);
      expect(find.text('Overdue review'), findsOneWidget);
      expect(find.text('Review timing'), findsOneWidget);
      expect(find.text('Statement'), findsOneWidget);
      expect(find.text('\$1,200.00'), findsWidgets);
      expect(find.text('BNK-001'), findsWidgets);
      expect(find.text('Post bank fee expense'), findsOneWidget);
      expect(find.text('Missing bank fee account'), findsOneWidget);
    });

    testWidgets('show empty states for missing bank evidence', (tester) async {
      final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
      final dateFormat = DateFormat('MM/dd/yyyy');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BankMatchReconciliationTable(
                      matches: const [],
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                    const SizedBox(height: 12),
                    BankStatementReconciliationTable(
                      lines: const [],
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                    const SizedBox(height: 12),
                    BankLedgerReconciliationTable(
                      lines: const [],
                      currency: currency,
                      dateFormat: dateFormat,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ReconciliationEmptyState), findsNWidgets(3));
      expect(find.text('No matched bank activity'), findsOneWidget);
      expect(find.text('No unmatched statement lines'), findsOneWidget);
      expect(find.text('No unmatched cash ledger rows'), findsOneWidget);
    });
  });
}

BankReconciliation _reconciliation() {
  final statement = BankStatementLine(
    id: 'line-1',
    date: DateTime(2026, 1, 5),
    description: 'Customer transfer',
    amount: 1200,
    reference: 'BNK-001',
  );
  final ledger = BankLedgerReconciliationLine(
    transactionId: 'cash-in',
    date: DateTime(2026, 1, 5),
    account: '1000 - Bank Mandiri',
    description: 'Customer transfer',
    reference: 'BNK-001',
    type: TransactionType.debit,
    amount: 1200,
  );

  return BankReconciliation(
    statementLines: [statement],
    ledgerLines: [ledger],
    matches: [
      BankReconciliationMatch(
        statementLine: statement,
        ledgerLine: ledger,
        matchType: BankReconciliationMatchType.reference,
        dateDifferenceDays: 0,
        amountVariance: 0,
      ),
    ],
    unmatchedStatementLines: const [],
    unmatchedLedgerLines: const [],
  );
}

BankReconciliationControlSummary _controlSummary() {
  return const BankReconciliationControlSummary(
    severity: BankReconciliationControlSeverity.timingReview,
    nextAction: 'Review overdue timing items before close.',
    statementLineCount: 1,
    matchedCount: 1,
    unmatchedStatementCount: 0,
    unmatchedLedgerCount: 0,
    suggestedJournalCount: 1,
    timingDifferenceCount: 1,
    staleThresholdDays: 30,
    timingAging: BankReconciliationTimingAgingSummary(
      currentCount: 0,
      watchCount: 0,
      staleCount: 1,
      currentAmount: 0,
      watchAmount: 0,
      staleAmount: 350,
    ),
  );
}

BankReconciliationResolutionAction _resolutionAction() {
  return BankReconciliationResolutionAction(
    type: BankReconciliationResolutionType.bankFee,
    title: 'Post bank fee expense',
    description: 'Statement-only fee requires an adjustment journal.',
    suggestedAction: 'Post a bank fee journal.',
    amount: -15000,
    date: DateTime(2026, 1, 5),
    reference: 'ADM-001',
    suggestsJournal: true,
  );
}

BankReconciliationTimingRegisterItem _timingItem() {
  return BankReconciliationTimingRegisterItem(
    reference: 'DEP-001',
    date: DateTime(2026, 1, 28),
    description: 'Deposit in transit',
    amount: 350,
    ageDays: 35,
    clearByDate: DateTime(2026, 2, 27),
    bucket: BankReconciliationTimingBucket.stale,
    type: BankReconciliationResolutionType.depositInTransit,
    clearanceStatus: BankReconciliationTimingClearanceStatus.escalate,
    suggestedAction: 'Follow up on overdue deposit clearing.',
  );
}
