import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_control_summary.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_disclosure_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_evidence_close_task.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_exception_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/models/payable_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/receivable_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/repositories/bank_reconciliation_timing_review_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/repositories/posted_ledger_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/services/financial_close_checklist_service.dart';
import 'package:kaysir/features/finance/accounting/states/bank_reconciliation_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_close_checklist_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_report_disclosure_review_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_report_evidence_task_resolution_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_report_exception_resolution_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_report_pack_provider.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/period_closing_entry_provider.dart';
import 'package:kaysir/features/finance/accounting/states/gl/ledger_provider.dart';
import 'package:kaysir/features/finance/accounting/states/payable_reconciliation_provider.dart';
import 'package:kaysir/features/finance/accounting/states/receivable_reconciliation_provider.dart';

void main() {
  group('financialCloseChecklistProvider', () {
    test(
      'passes bank, AR, and AP reconciliation evidence into the service',
      () {
        final service = _CapturingFinancialCloseChecklistService();
        const bankReconciliation = BankReconciliation(
          statementLines: [],
          ledgerLines: [],
          matches: [],
          unmatchedStatementLines: [],
          unmatchedLedgerLines: [],
        );
        const bankControlSummary = BankReconciliationControlSummary(
          severity: BankReconciliationControlSeverity.needsEvidence,
          nextAction:
              'Import or add bank statement lines for this close period.',
          statementLineCount: 0,
          matchedCount: 0,
          unmatchedStatementCount: 0,
          unmatchedLedgerCount: 0,
          suggestedJournalCount: 0,
          timingDifferenceCount: 0,
          staleThresholdDays: 30,
        );
        const receivableReconciliation = ReceivableReconciliation(
          subledgerBalance: 100,
          ledgerBalance: 100,
        );
        const payableReconciliation = PayableReconciliation(
          subledgerBalance: 80,
          ledgerBalance: 80,
        );
        final bankTimingRegister = [
          BankReconciliationTimingRegisterItem(
            reference: 'PAY-001',
            date: DateTime(2026, 1, 26),
            description: 'Outstanding vendor payment',
            amount: -250,
            ageDays: 5,
            clearByDate: DateTime(2026, 2, 4),
            bucket: BankReconciliationTimingBucket.current,
            type: BankReconciliationResolutionType.outstandingPayment,
            clearanceStatus: BankReconciliationTimingClearanceStatus.open,
            suggestedAction: 'Confirm later statement clearing.',
          ),
        ];
        final bankTimingReviews = {
          'PAY-001': BankReconciliationTimingReview(
            reference: 'PAY-001',
            status: BankReconciliationTimingReviewStatus.inReview,
            owner: 'Controller',
            note: 'Waiting for next bank statement.',
            reviewedAt: DateTime(2026, 2, 1),
          ),
        };
        final container = ProviderContainer(
          overrides: [
            financialCloseChecklistServiceProvider.overrideWithValue(service),
            financialReportPackProvider.overrideWithValue(_pack()),
            combinedLedgerProvider.overrideWithValue(
              const <LedgerTransaction>[],
            ),
            currentPeriodClosingEntryPostedProvider.overrideWithValue(true),
            currentFinancialReportExceptionResolutionsProvider
                .overrideWithValue(
                  const <FinancialReportExceptionResolution>[],
                ),
            currentFinancialReportEvidenceTaskResolutionsProvider
                .overrideWithValue(
                  const <FinancialReportEvidenceCloseTaskResolution>[],
                ),
            currentFinancialReportDisclosureReviewItemsProvider
                .overrideWithValue(
                  const <FinancialReportDisclosureReviewItem>[],
                ),
            postedLedgerRepositoryProvider.overrideWithValue(
              InMemoryPostedLedgerRepository(),
            ),
            bankReconciliationProvider.overrideWithValue(bankReconciliation),
            bankReconciliationControlSummaryProvider.overrideWithValue(
              bankControlSummary,
            ),
            bankReconciliationTimingRegisterProvider.overrideWithValue(
              bankTimingRegister,
            ),
            bankReconciliationTimingReviewRepositoryProvider.overrideWithValue(
              InMemoryBankReconciliationTimingReviewRepository(
                reviewsByPeriod: {'20260101-20260131': bankTimingReviews},
              ),
            ),
            receivableReconciliationProvider.overrideWithValue(
              receivableReconciliation,
            ),
            payableReconciliationProvider.overrideWithValue(
              payableReconciliation,
            ),
          ],
        );
        addTearDown(container.dispose);
        container
            .read(selectedFinancialPeriodProvider.notifier)
            .state = FinancialStatementPeriod(
          preset: FinancialPeriodPreset.custom,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 31),
        );

        final checklist = container.read(financialCloseChecklistProvider);

        expect(checklist.periodLabel, 'Jan 2026');
        expect(service.bankReconciliation, same(bankReconciliation));
        expect(
          service.bankReconciliationControlSummary,
          same(bankControlSummary),
        );
        expect(service.bankTimingRegister, same(bankTimingRegister));
        expect(service.bankTimingReviews?.keys, bankTimingReviews.keys);
        expect(
          service.bankTimingReviews?['PAY-001']?.owner,
          bankTimingReviews['PAY-001']?.owner,
        );
        expect(
          service.receivableReconciliation,
          same(receivableReconciliation),
        );
        expect(service.payableReconciliation, same(payableReconciliation));
        expect(service.postedAdjustmentJournals, isEmpty);
        expect(service.disclosureReviewItems, isEmpty);
      },
    );
  });
}

class _CapturingFinancialCloseChecklistService
    extends FinancialCloseChecklistService {
  BankReconciliation? bankReconciliation;
  BankReconciliationControlSummary? bankReconciliationControlSummary;
  List<BankReconciliationTimingRegisterItem>? bankTimingRegister;
  Map<String, BankReconciliationTimingReview>? bankTimingReviews;
  ReceivableReconciliation? receivableReconciliation;
  PayableReconciliation? payableReconciliation;
  List<LedgerPosting>? postedAdjustmentJournals;
  List<FinancialReportDisclosureReviewItem>? disclosureReviewItems;

  _CapturingFinancialCloseChecklistService();

  @override
  FinancialCloseChecklist build({
    required FinancialReportPack pack,
    required List<LedgerTransaction> ledgerTransactions,
    required bool closingEntryPosted,
    List<FinancialReportExceptionResolution> exceptionResolutions = const [],
    List<FinancialReportEvidenceCloseTaskResolution> evidenceTaskResolutions =
        const [],
    List<FinancialReportDisclosureReviewItem> disclosureReviewItems = const [],
    List<LedgerPosting> postedAdjustmentJournals = const [],
    BankReconciliation? bankReconciliation,
    BankReconciliationControlSummary? bankReconciliationControlSummary,
    List<BankReconciliationTimingRegisterItem> bankTimingRegister = const [],
    Map<String, BankReconciliationTimingReview> bankTimingReviews = const {},
    ReceivableReconciliation? receivableReconciliation,
    PayableReconciliation? payableReconciliation,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? generatedAt,
  }) {
    this.bankReconciliation = bankReconciliation;
    this.bankReconciliationControlSummary = bankReconciliationControlSummary;
    this.bankTimingRegister = bankTimingRegister;
    this.bankTimingReviews = bankTimingReviews;
    this.receivableReconciliation = receivableReconciliation;
    this.payableReconciliation = payableReconciliation;
    this.postedAdjustmentJournals = postedAdjustmentJournals;
    this.disclosureReviewItems = disclosureReviewItems;

    return FinancialCloseChecklist(
      periodLabel: pack.periodLabel,
      generatedAt: generatedAt ?? pack.generatedAt,
      totalDebit: 0,
      totalCredit: 0,
      trialBalanceVariance: 0,
      items: const [
        FinancialCloseChecklistItem(
          id: 'captured',
          title: 'Captured',
          description: 'Provider dependencies were captured.',
          status: FinancialCloseItemStatus.ready,
          reference: 'TEST',
        ),
      ],
    );
  }
}

FinancialReportPack _pack() {
  return FinancialReportPack(
    entityName: 'Kaysir',
    frameworkName: 'SAK Indonesia (IFRS-converged)',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    generatedAt: DateTime(2026, 2, 1),
    statements: const [],
    notes: const [],
    complianceItems: const [],
    metrics: const [],
  );
}
