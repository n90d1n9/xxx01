import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_control_summary.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_close_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/financial_entry.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_exception_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_tax_profile.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_materiality_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_pack_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_package_fingerprint_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_reconciliation_service.dart';

void main() {
  group('FinancialReportPackageFingerprintService', () {
    const packService = FinancialReportPackService();
    const fingerprintService = FinancialReportPackageFingerprintService();

    test('creates a stable SHA-256 fingerprint for the same close package', () {
      final pack = _pack(packService);
      final checklist = _checklist();

      final first = fingerprintService.build(pack: pack, checklist: checklist);
      final second = fingerprintService.build(pack: pack, checklist: checklist);

      expect(first.algorithm, 'SHA-256');
      expect(first.hash, second.hash);
      expect(first.hash.length, 64);
      expect(first.shortHash.length, 12);
    });

    test('changes fingerprint when checklist evidence changes', () {
      final pack = _pack(packService);

      final ready = fingerprintService.build(
        pack: pack,
        checklist: _checklist(blockerCount: 0),
      );
      final blocked = fingerprintService.build(
        pack: pack,
        checklist: _checklist(blockerCount: 1),
      );

      expect(ready.hash, isNot(blocked.hash));
    });

    test(
      'changes fingerprint when reconciliation variance evidence changes',
      () {
        const variancePackService = FinancialReportPackService(
          reconciliationService: _VarianceReconciliationService(),
        );
        final cleanPack = _pack(packService);
        final variancePack = _pack(variancePackService);
        final checklist = _checklist();

        final clean = fingerprintService.build(
          pack: cleanPack,
          checklist: checklist,
        );
        final changed = fingerprintService.build(
          pack: variancePack,
          checklist: checklist,
        );
        final cleanReconciliation =
            cleanPack.complianceItems
                .where((item) => item.id == 'equity-roll-forward')
                .single;
        final changedReconciliation =
            variancePack.complianceItems
                .where((item) => item.id == 'equity-roll-forward')
                .single;

        expect(cleanReconciliation.isSatisfied, isTrue);
        expect(changedReconciliation.isSatisfied, isTrue);
        expect(changedReconciliation.variance, 0.009);
        expect(clean.hash, isNot(changed.hash));
      },
    );

    test('changes fingerprint when materiality evidence changes', () {
      const higherMaterialityPackService = FinancialReportPackService(
        materialityService: FinancialReportMaterialityService(
          minimumThreshold: 1000,
        ),
      );
      final baselinePack = _pack(packService);
      final materialityPack = _pack(higherMaterialityPackService);
      final checklist = _checklist();

      final baseline = fingerprintService.build(
        pack: baselinePack,
        checklist: checklist,
      );
      final changed = fingerprintService.build(
        pack: materialityPack,
        checklist: checklist,
      );

      expect(
        baselinePack.complianceItems
            .where((item) => item.id == 'equity-roll-forward')
            .single
            .materialityThreshold,
        isNot(
          materialityPack.complianceItems
              .where((item) => item.id == 'equity-roll-forward')
              .single
              .materialityThreshold,
        ),
      );
      expect(baseline.hash, isNot(changed.hash));
    });

    test('changes fingerprint when the report tax profile changes', () {
      const listedPackService = FinancialReportPackService(
        taxProfile: FinancialReportTaxProfiles.publicCompanyReduced,
      );
      final baselinePack = _pack(packService);
      final listedPack = _pack(listedPackService);
      final checklist = _checklist();

      final baseline = fingerprintService.build(
        pack: baselinePack,
        checklist: checklist,
      );
      final changed = fingerprintService.build(
        pack: listedPack,
        checklist: checklist,
      );

      expect(baselinePack.taxProfile.id, isNot(listedPack.taxProfile.id));
      expect(baseline.hash, isNot(changed.hash));
    });

    test('changes fingerprint when bank reconciliation evidence changes', () {
      final reconciledPack = _pack(
        packService,
        bankReconciliation: _balancedBankReconciliation(),
      );
      final unreconciledPack = _pack(
        packService,
        bankReconciliation: _unreconciledBankReconciliation(),
      );
      final checklist = _checklist();

      final reconciled = fingerprintService.build(
        pack: reconciledPack,
        checklist: checklist,
      );
      final unreconciled = fingerprintService.build(
        pack: unreconciledPack,
        checklist: checklist,
      );

      expect(
        reconciledPack.complianceItems
            .where((item) => item.id == 'bank-reconciliation')
            .single
            .isSatisfied,
        isTrue,
      );
      expect(
        unreconciledPack.complianceItems
            .where((item) => item.id == 'bank-reconciliation')
            .single
            .isSatisfied,
        isFalse,
      );
      expect(reconciled.hash, isNot(unreconciled.hash));
    });

    test('changes fingerprint when bank control summary changes', () {
      final reconciliation = _balancedBankReconciliation();
      final baselinePack = _pack(
        packService,
        bankReconciliation: reconciliation,
        bankReconciliationControlSummary: _bankControlSummary(
          nextAction: 'Bank statement evidence is matched and ready for close.',
        ),
      );
      final changedPack = _pack(
        packService,
        bankReconciliation: reconciliation,
        bankReconciliationControlSummary: _bankControlSummary(
          nextAction: 'Controller reviewed bank reconciliation evidence.',
        ),
      );
      final checklist = _checklist();

      final baseline = fingerprintService.build(
        pack: baselinePack,
        checklist: checklist,
      );
      final changed = fingerprintService.build(
        pack: changedPack,
        checklist: checklist,
      );

      expect(baseline.hash, isNot(changed.hash));
    });

    test('changes fingerprint when bank timing review evidence changes', () {
      final reconciliation = _balancedBankReconciliation();
      final register = [_timingItem()];
      final baselinePack = _pack(
        packService,
        bankReconciliation: reconciliation,
        bankReconciliationControlSummary: _bankControlSummary(
          nextAction: 'Confirm timing differences clear later.',
          timingDifferenceCount: 1,
        ),
        bankTimingRegister: register,
      );
      final reviewedPack = _pack(
        packService,
        bankReconciliation: reconciliation,
        bankReconciliationControlSummary: _bankControlSummary(
          nextAction: 'Confirm timing differences clear later.',
          timingDifferenceCount: 1,
        ),
        bankTimingRegister: register,
        bankTimingReviews: {
          'PAY-001': BankReconciliationTimingReview(
            reference: 'PAY-001',
            status: BankReconciliationTimingReviewStatus.cleared,
            owner: 'Controller',
            note: 'Cleared on Feb bank statement.',
            reviewedAt: DateTime(2026, 2, 3, 10),
          ),
        },
      );
      final checklist = _checklist();

      final baseline = fingerprintService.build(
        pack: baselinePack,
        checklist: checklist,
      );
      final reviewed = fingerprintService.build(
        pack: reviewedPack,
        checklist: checklist,
      );

      expect(baseline.hash, isNot(reviewed.hash));
    });

    test('changes fingerprint when exception resolution evidence changes', () {
      final pack = _pack(packService);
      final checklist = _checklist();

      final unresolved = fingerprintService.build(
        pack: pack,
        checklist: checklist,
      );
      final approved = fingerprintService.build(
        pack: pack,
        checklist: checklist,
        exceptionResolutions: [
          FinancialReportExceptionResolution(
            exceptionId: 'equity-roll-forward-blocking',
            status: FinancialReportExceptionResolutionStatus.approved,
            reviewer: 'Controller',
            resolvedAt: DateTime(2026, 2, 1, 11),
            note: 'Approved with supporting equity roll-forward schedule.',
            adjustmentReference: 'REV-001',
          ),
        ],
      );

      expect(unresolved.hash, isNot(approved.hash));
    });
  });
}

FinancialCloseChecklist _checklist({int blockerCount = 0}) {
  return FinancialCloseChecklist(
    periodLabel: 'Jan 2026',
    generatedAt: DateTime(2026, 2, 1, 9),
    totalDebit: 100,
    totalCredit: blockerCount == 0 ? 100 : 90,
    trialBalanceVariance: blockerCount == 0 ? 0 : 10,
    items: [
      FinancialCloseChecklistItem(
        id: 'trial-balance',
        title: 'Trial balance',
        description: 'Debits equal credits',
        status:
            blockerCount == 0
                ? FinancialCloseItemStatus.ready
                : FinancialCloseItemStatus.blocked,
        reference: 'GL',
      ),
      const FinancialCloseChecklistItem(
        id: 'report-pack',
        title: 'Report pack',
        description: 'Statements generated',
        status: FinancialCloseItemStatus.ready,
        reference: 'PSAK 201',
      ),
    ],
  );
}

FinancialReportPack _pack(
  FinancialReportPackService service, {
  BankReconciliation? bankReconciliation,
  BankReconciliationControlSummary? bankReconciliationControlSummary,
  List<BankReconciliationTimingRegisterItem> bankTimingRegister = const [],
  Map<String, BankReconciliationTimingReview> bankTimingReviews = const {},
}) {
  return service.build(
    entries: [
      FinancialEntry(
        name: 'Sales Revenue',
        amount: 5000,
        date: DateTime(2026, 1, 15),
        category: '4000 - Sales Revenue',
        type: 'income',
      ),
      FinancialEntry(
        name: 'Rent Expense',
        amount: 1200,
        date: DateTime(2026, 1, 16),
        category: '5000 - Rent Expense',
        type: 'expense',
      ),
      FinancialEntry(
        name: 'Cash',
        amount: 3800,
        date: DateTime(2026, 1, 31),
        category: '1000 - Cash',
        type: 'asset',
        sourceCategory: 'Operating collection',
      ),
    ],
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    generatedAt: DateTime(2026, 2, 1, 9),
    bankReconciliation: bankReconciliation,
    bankReconciliationControlSummary: bankReconciliationControlSummary,
    bankTimingRegister: bankTimingRegister,
    bankTimingReviews: bankTimingReviews,
  );
}

BankReconciliationControlSummary _bankControlSummary({
  required String nextAction,
  int timingDifferenceCount = 0,
}) {
  return BankReconciliationControlSummary(
    severity: BankReconciliationControlSeverity.ready,
    nextAction: nextAction,
    statementLineCount: 1,
    matchedCount: 1,
    unmatchedStatementCount: 0,
    unmatchedLedgerCount: 0,
    suggestedJournalCount: 0,
    timingDifferenceCount: timingDifferenceCount,
    staleThresholdDays: 30,
  );
}

BankReconciliationTimingRegisterItem _timingItem() {
  return BankReconciliationTimingRegisterItem(
    reference: 'PAY-001',
    date: DateTime(2025, 12, 30),
    description: 'Outstanding payment',
    amount: -300,
    ageDays: 32,
    clearByDate: DateTime(2026, 1, 29),
    bucket: BankReconciliationTimingBucket.stale,
    type: BankReconciliationResolutionType.outstandingPayment,
    clearanceStatus: BankReconciliationTimingClearanceStatus.escalate,
    suggestedAction: 'Investigate stale payment.',
  );
}

BankReconciliation _balancedBankReconciliation() {
  final statementLine = _statementLine();
  final ledgerLine = _ledgerLine();

  return BankReconciliation(
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
}

BankReconciliation _unreconciledBankReconciliation() {
  final statementLine = _statementLine();

  return BankReconciliation(
    statementLines: [statementLine],
    ledgerLines: const [],
    matches: const [],
    unmatchedStatementLines: [statementLine],
    unmatchedLedgerLines: const [],
  );
}

BankStatementLine _statementLine() {
  return BankStatementLine(
    id: 'stmt-1',
    date: DateTime(2026, 1, 15),
    description: 'Customer transfer INV-001',
    amount: 1200,
    reference: 'INV-001',
  );
}

BankLedgerReconciliationLine _ledgerLine() {
  return BankLedgerReconciliationLine(
    transactionId: 'trx-1',
    date: DateTime(2026, 1, 15),
    account: '1000 - Cash',
    description: 'Customer transfer INV-001',
    reference: 'INV-001',
    type: TransactionType.debit,
    amount: 1200,
  );
}

class _VarianceReconciliationService
    extends FinancialReportReconciliationService {
  const _VarianceReconciliationService();

  @override
  List<FinancialReportReconciliationCheck> buildChecks({
    required FinancialReportStatement position,
    required FinancialReportStatement profitOrLoss,
    required FinancialReportStatement changesInEquity,
    required FinancialReportStatement cashFlows,
  }) {
    return [
      for (final check in super.buildChecks(
        position: position,
        profitOrLoss: profitOrLoss,
        changesInEquity: changesInEquity,
        cashFlows: cashFlows,
      ))
        if (check.id == 'equity-roll-forward')
          FinancialReportReconciliationCheck(
            id: check.id,
            title: check.title,
            description: check.description,
            standardReference: check.standardReference,
            variance: 0.009,
            comparativeVariance: check.comparativeVariance,
          )
        else
          check,
    ];
  }
}
