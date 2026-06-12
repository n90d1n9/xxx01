import 'package:intl/intl.dart';

import '../accounting_core/models/ledger_posting.dart';
import '../models/bank_reconciliation.dart';
import '../models/bank_reconciliation_control_summary.dart';
import '../models/bank_reconciliation_timing_register.dart';
import '../models/bank_reconciliation_timing_review.dart';
import '../models/financial_close_checklist.dart';
import '../models/financial_report_disclosure_review.dart';
import '../models/financial_report_evidence_close_task.dart';
import '../models/financial_report_exception_resolution.dart';
import '../models/financial_report_pack.dart';
import '../models/ledger_trx.dart';
import '../models/payable_reconciliation.dart';
import '../models/receivable_reconciliation.dart';
import '../models/trial_balance.dart';
import 'financial_report_evidence_close_task_service.dart';
import 'financial_report_exception_resolution_service.dart';
import 'trial_balance_service.dart';

class FinancialCloseChecklistService {
  static const _eps = 0.01;
  final FinancialReportExceptionResolutionService exceptionResolutionService;
  final FinancialReportEvidenceCloseTaskService evidenceCloseTaskService;
  final TrialBalanceService trialBalanceService;

  const FinancialCloseChecklistService({
    this.exceptionResolutionService =
        const FinancialReportExceptionResolutionService(),
    this.evidenceCloseTaskService =
        const FinancialReportEvidenceCloseTaskService(),
    this.trialBalanceService = const TrialBalanceService(),
  });

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
    final generatedAtValue = generatedAt ?? DateTime.now();
    final trialBalance = trialBalanceService.buildReport(
      transactions: ledgerTransactions,
      startDate: periodStart,
      endDate: periodEnd,
    );
    final summary = trialBalance.summary;
    final totalDebit = summary.totalDebits;
    final totalCredit = summary.totalCredits;
    final variance = summary.variance;
    final hasLedgerActivity = trialBalance.transactions.isNotEmpty;
    final positionReconciliation = _compliance(pack, 'position-equation');
    final cashReconciliation = _compliance(pack, 'cash-reconciliation');
    final cashRollForward = _compliance(pack, 'cash-roll-forward');
    final equityRollForward = _compliance(pack, 'equity-roll-forward');
    final incomeTieOut = _compliance(pack, 'comprehensive-income-tie-out');
    final chartMapping = _compliance(pack, 'chart-mapping');
    final taxOci = _compliance(pack, 'tax-oci-detail');
    final taxReconciliation = _compliance(pack, 'tax-reconciliation');
    final taxSettlement = _compliance(pack, 'tax-settlement');
    final vatSettlement = _compliance(pack, 'vat-settlement');
    final reportExceptions = exceptionResolutionService.buildReviewItems(
      pack: pack,
      resolutions: exceptionResolutions,
      postedAdjustmentJournals: postedAdjustmentJournals,
    );
    final blockingReportExceptions =
        reportExceptions.where((item) => item.blocksClose).toList();
    final evidenceCloseTaskItems = evidenceCloseTaskService.buildReviewItems(
      schedules: pack.supportingSchedules,
      resolutions: evidenceTaskResolutions,
      generatedAt: generatedAtValue,
    );
    final evidenceTasksBlockClose = evidenceCloseTaskItems.any(
      (item) => item.blocksClose,
    );
    final bankTimingSummary = BankReconciliationTimingRegisterSummary.fromItems(
      bankTimingRegister,
    );
    final bankTimingReviewSummary =
        BankReconciliationTimingReviewSummary.fromItems(
          items: bankTimingRegister,
          reviews: bankTimingReviews,
        );
    final bankReconciliationBlocksClose = _bankReconciliationBlocksClose(
      reconciliation: bankReconciliation,
      controlSummary: bankReconciliationControlSummary,
      timingSummary: bankTimingSummary,
      timingReviewSummary: bankTimingReviewSummary,
    );
    final isExportReady =
        pack.hasCompletePrimaryStatements &&
        variance.abs() < _eps &&
        closingEntryPosted &&
        !evidenceTasksBlockClose &&
        !bankReconciliationBlocksClose &&
        (receivableReconciliation == null ||
            receivableReconciliation.isBalanced) &&
        (payableReconciliation == null || payableReconciliation.isBalanced) &&
        blockingReportExceptions.isEmpty;

    return FinancialCloseChecklist(
      periodLabel: pack.periodLabel,
      generatedAt: generatedAtValue,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      trialBalanceVariance: variance,
      items: [
        FinancialCloseChecklistItem(
          id: 'ledger-activity',
          title: 'Ledger activity captured',
          description:
              'The selected period has ledger rows to support the close pack.',
          reference: 'GL',
          status:
              hasLedgerActivity
                  ? FinancialCloseItemStatus.ready
                  : FinancialCloseItemStatus.review,
          amountLabel: _ledgerActivityLabel(trialBalance),
        ),
        FinancialCloseChecklistItem(
          id: 'trial-balance',
          title: 'Trial balance is balanced',
          description: 'Total debits equal total credits for the close period.',
          reference: 'GL',
          status:
              variance.abs() < _eps
                  ? FinancialCloseItemStatus.ready
                  : FinancialCloseItemStatus.blocked,
          amountLabel:
              'Dr ${_money(totalDebit)} / Cr ${_money(totalCredit)} / Var ${_money(variance)}',
        ),
        FinancialCloseChecklistItem(
          id: 'primary-statements',
          title: 'Primary statements generated',
          description:
              'Financial position, profit or loss and OCI, equity, cash flow, and notes are present.',
          reference: 'PSAK 201',
          status:
              pack.hasCompletePrimaryStatements
                  ? FinancialCloseItemStatus.ready
                  : FinancialCloseItemStatus.blocked,
        ),
        FinancialCloseChecklistItem(
          id: 'financial-position-reconciliation',
          title: 'Financial position reconciles',
          description:
              positionReconciliation?.description ??
              'Total assets equal total liabilities plus equity.',
          reference: positionReconciliation?.standardReference ?? 'PSAK 201',
          status: _statusForCompliance(
            positionReconciliation,
            reportExceptions,
          ),
          amountLabel: _varianceLabel(positionReconciliation),
        ),
        FinancialCloseChecklistItem(
          id: 'cash-flow',
          title: 'Cash flow reconciles',
          description:
              cashReconciliation?.description ??
              'Cash flow reconciles beginning cash, net cash flow, and ending cash.',
          reference: cashReconciliation?.standardReference ?? 'PSAK 207',
          status: _statusForCompliance(cashReconciliation, reportExceptions),
          amountLabel: _varianceLabel(cashReconciliation),
        ),
        FinancialCloseChecklistItem(
          id: 'cash-roll-forward',
          title: 'Cash roll-forward reviewed',
          description:
              cashRollForward?.description ??
              'Opening cash plus cash movements should tie to statement cash and cash equivalents.',
          reference: cashRollForward?.standardReference ?? 'PSAK 207',
          status: _statusForCompliance(cashRollForward, reportExceptions),
          amountLabel: _varianceLabel(cashRollForward),
        ),
        FinancialCloseChecklistItem(
          id: 'bank-reconciliation',
          title: 'Bank reconciliation reviewed',
          description: _bankReconciliationDescription(
            bankReconciliationControlSummary,
            bankTimingSummary,
            bankTimingReviewSummary,
          ),
          reference: 'Cash',
          status: _statusForBankReconciliation(
            bankReconciliation,
            bankReconciliationControlSummary,
            bankTimingSummary,
            bankTimingReviewSummary,
          ),
          amountLabel: _bankReconciliationLabel(
            bankReconciliation,
            bankReconciliationControlSummary,
            bankTimingSummary,
            bankTimingReviewSummary,
          ),
        ),
        FinancialCloseChecklistItem(
          id: 'receivable-reconciliation',
          title: 'Accounts receivable reconciles',
          description:
              'Open customer invoices tie to the accounts receivable ledger before close.',
          reference: 'AR',
          status: _statusForReceivableReconciliation(receivableReconciliation),
          amountLabel: _receivableReconciliationLabel(receivableReconciliation),
        ),
        FinancialCloseChecklistItem(
          id: 'payable-reconciliation',
          title: 'Accounts payable reconciles',
          description:
              'Open vendor bills tie to the accounts payable ledger before close.',
          reference: 'AP',
          status: _statusForPayableReconciliation(payableReconciliation),
          amountLabel: _payableReconciliationLabel(payableReconciliation),
        ),
        FinancialCloseChecklistItem(
          id: 'equity-roll-forward',
          title: 'Equity roll-forward reconciles',
          description:
              equityRollForward?.description ??
              'Opening equity plus current-period equity movements equals ending equity.',
          reference: equityRollForward?.standardReference ?? 'PSAK 201',
          status: _statusForCompliance(equityRollForward, reportExceptions),
          amountLabel: _varianceLabel(equityRollForward),
        ),
        FinancialCloseChecklistItem(
          id: 'profit-oci-tie-out',
          title: 'Profit and OCI tie to equity',
          description:
              incomeTieOut?.description ??
              'Profit or loss and OCI agree between performance and equity statements.',
          reference: incomeTieOut?.standardReference ?? 'PSAK 201',
          status: _statusForCompliance(incomeTieOut, reportExceptions),
          amountLabel: _varianceLabel(incomeTieOut),
        ),
        FinancialCloseChecklistItem(
          id: 'mapping',
          title: 'Chart mapping reviewed',
          description:
              chartMapping?.description ??
              'Ledger accounts are mapped into standardized statement lines.',
          reference: chartMapping?.standardReference ?? 'PSAK 201',
          status: _statusForCompliance(chartMapping, reportExceptions),
        ),
        FinancialCloseChecklistItem(
          id: 'comparatives',
          title: 'Comparatives available',
          description:
              pack.hasComparativePeriod
                  ? 'Prior comparable period is shown in the report pack.'
                  : 'Select a bounded reporting period to show comparatives.',
          reference: 'PSAK 201',
          status:
              pack.hasComparativePeriod
                  ? FinancialCloseItemStatus.ready
                  : FinancialCloseItemStatus.review,
        ),
        FinancialCloseChecklistItem(
          id: 'tax-oci',
          title: 'Tax and OCI source detail reviewed',
          description:
              taxOci?.description ??
              'Tax and OCI schedules should be reviewed before statutory use.',
          reference: taxOci?.standardReference ?? 'PSAK 201',
          status:
              taxOci == null
                  ? FinancialCloseItemStatus.review
                  : taxOci.isSatisfied
                  ? FinancialCloseItemStatus.ready
                  : FinancialCloseItemStatus.review,
        ),
        FinancialCloseChecklistItem(
          id: 'tax-reconciliation',
          title: 'Income tax reconciliation reviewed',
          description:
              taxReconciliation?.description ??
              'Income tax expense should reconcile to the statutory benchmark or be documented.',
          reference: taxReconciliation?.standardReference ?? 'PSAK 212',
          status: _statusForCompliance(taxReconciliation, reportExceptions),
          amountLabel: _varianceLabel(taxReconciliation),
        ),
        FinancialCloseChecklistItem(
          id: 'tax-settlement',
          title: 'Income tax settlement reviewed',
          description:
              taxSettlement?.description ??
              'Income tax credits, prepayments, and payable balances should tie out before close.',
          reference: taxSettlement?.standardReference ?? 'PSAK 212',
          status: _statusForCompliance(taxSettlement, reportExceptions),
          amountLabel: _varianceLabel(taxSettlement),
        ),
        FinancialCloseChecklistItem(
          id: 'vat-settlement',
          title: 'VAT / PPN settlement reviewed',
          description:
              vatSettlement?.description ??
              'Input VAT, output VAT, and recorded VAT payable or refund should tie out before close.',
          reference: vatSettlement?.standardReference ?? 'Indonesia VAT / PPN',
          status: _statusForCompliance(vatSettlement, reportExceptions),
          amountLabel: _varianceLabel(vatSettlement),
        ),
        FinancialCloseChecklistItem(
          id: 'supporting-evidence',
          title: 'Supporting evidence tasks cleared',
          description: _evidenceTaskDescription(evidenceCloseTaskItems),
          reference: 'Close evidence',
          status: _statusForEvidenceTasks(evidenceCloseTaskItems),
          amountLabel: _evidenceTaskLabel(evidenceCloseTaskItems),
        ),
        FinancialCloseChecklistItem(
          id: 'report-exceptions',
          title: 'Report exceptions reviewed',
          description:
              'Unresolved report pack issues are classified by close impact and materiality.',
          reference: 'PSAK 201',
          status: _statusForExceptions(reportExceptions),
          amountLabel: _exceptionLabel(reportExceptions),
        ),
        if (disclosureReviewItems.isNotEmpty)
          FinancialCloseChecklistItem(
            id: 'disclosure-notes',
            title: 'Disclosure notes reviewed',
            description: _disclosureReviewDescription(disclosureReviewItems),
            reference: 'Notes',
            status: _statusForDisclosureReviews(disclosureReviewItems),
            amountLabel: _disclosureReviewLabel(disclosureReviewItems),
          ),
        FinancialCloseChecklistItem(
          id: 'closing-entry',
          title: 'Closing entry posted',
          description:
              'Revenue and expense balances are transferred to retained earnings before the period is locked.',
          reference: 'Close',
          status:
              closingEntryPosted
                  ? FinancialCloseItemStatus.ready
                  : FinancialCloseItemStatus.blocked,
        ),
        FinancialCloseChecklistItem(
          id: 'export-ready',
          title: 'Export pack is ready',
          description:
              'PDF/CSV report pack can be shared once blocker checks are clear.',
          reference: 'Close',
          status:
              isExportReady
                  ? FinancialCloseItemStatus.ready
                  : FinancialCloseItemStatus.blocked,
        ),
      ],
    );
  }

  FinancialReportComplianceItem? _compliance(
    FinancialReportPack pack,
    String id,
  ) {
    for (final item in pack.complianceItems) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  FinancialCloseItemStatus _statusForCompliance(
    FinancialReportComplianceItem? item,
    List<FinancialReportExceptionReviewItem> reviewItems,
  ) {
    if (item == null) {
      return FinancialCloseItemStatus.review;
    }
    if (item.isSatisfied) {
      return FinancialCloseItemStatus.ready;
    }
    final reviewItem = exceptionResolutionService.itemForCompliance(
      complianceId: item.id,
      items: reviewItems,
    );
    if (reviewItem != null && !reviewItem.blocksClose) {
      return FinancialCloseItemStatus.review;
    }
    return FinancialCloseItemStatus.blocked;
  }

  FinancialCloseItemStatus _statusForReceivableReconciliation(
    ReceivableReconciliation? reconciliation,
  ) {
    if (reconciliation == null) {
      return FinancialCloseItemStatus.review;
    }
    return reconciliation.isBalanced
        ? FinancialCloseItemStatus.ready
        : FinancialCloseItemStatus.blocked;
  }

  FinancialCloseItemStatus _statusForBankReconciliation(
    BankReconciliation? reconciliation,
    BankReconciliationControlSummary? controlSummary,
    BankReconciliationTimingRegisterSummary timingSummary,
    BankReconciliationTimingReviewSummary timingReviewSummary,
  ) {
    if (reconciliation == null || !reconciliation.hasStatementEvidence) {
      return FinancialCloseItemStatus.review;
    }
    if (reconciliation.isBalanced) {
      return FinancialCloseItemStatus.ready;
    }
    return _bankReconciliationBlocksClose(
          reconciliation: reconciliation,
          controlSummary: controlSummary,
          timingSummary: timingSummary,
          timingReviewSummary: timingReviewSummary,
        )
        ? FinancialCloseItemStatus.blocked
        : FinancialCloseItemStatus.review;
  }

  bool _bankReconciliationBlocksClose({
    required BankReconciliation? reconciliation,
    required BankReconciliationControlSummary? controlSummary,
    required BankReconciliationTimingRegisterSummary timingSummary,
    required BankReconciliationTimingReviewSummary timingReviewSummary,
  }) {
    if (reconciliation == null ||
        !reconciliation.hasStatementEvidence ||
        reconciliation.isBalanced) {
      return false;
    }
    if (controlSummary == null) {
      return reconciliation.blocksClose;
    }
    if (timingReviewSummary.unresolvedOverdueCount > 0) {
      return true;
    }

    final hasOnlyCurrentTimingDifferences =
        controlSummary.severity ==
            BankReconciliationControlSeverity.timingReview &&
        controlSummary.timingDifferenceCount > 0 &&
        controlSummary.suggestedJournalCount == 0 &&
        controlSummary.unmatchedStatementCount == 0 &&
        !controlSummary.hasStaleUnmatchedItems;

    return !hasOnlyCurrentTimingDifferences;
  }

  FinancialCloseItemStatus _statusForPayableReconciliation(
    PayableReconciliation? reconciliation,
  ) {
    if (reconciliation == null) {
      return FinancialCloseItemStatus.review;
    }
    return reconciliation.isBalanced
        ? FinancialCloseItemStatus.ready
        : FinancialCloseItemStatus.blocked;
  }

  FinancialCloseItemStatus _statusForExceptions(
    List<FinancialReportExceptionReviewItem> exceptions,
  ) {
    if (exceptions.any((item) => item.blocksClose)) {
      return FinancialCloseItemStatus.blocked;
    }
    if (exceptions.any((item) => !item.isResolved)) {
      return FinancialCloseItemStatus.review;
    }
    return FinancialCloseItemStatus.ready;
  }

  FinancialCloseItemStatus _statusForEvidenceTasks(
    List<FinancialReportEvidenceCloseTaskReviewItem> items,
  ) {
    if (items.any((item) => item.blocksClose)) {
      return FinancialCloseItemStatus.blocked;
    }
    if (items.any((item) => !item.isResolved)) {
      return FinancialCloseItemStatus.review;
    }
    return FinancialCloseItemStatus.ready;
  }

  FinancialCloseItemStatus _statusForDisclosureReviews(
    List<FinancialReportDisclosureReviewItem> items,
  ) {
    if (items.any((item) => item.needsReview)) {
      return FinancialCloseItemStatus.review;
    }
    return FinancialCloseItemStatus.ready;
  }

  String _evidenceTaskDescription(
    List<FinancialReportEvidenceCloseTaskReviewItem> items,
  ) {
    if (items.isEmpty) {
      return 'Supporting schedule evidence is ready for close.';
    }
    FinancialReportEvidenceCloseTaskReviewItem? firstOpenItem;
    for (final item in items) {
      if (!item.isResolved) {
        firstOpenItem = item;
        break;
      }
    }
    if (firstOpenItem == null) {
      return 'Supporting schedule evidence tasks are resolved for close.';
    }
    return '${firstOpenItem.task.scheduleTitle}: ${firstOpenItem.task.actionLabel}';
  }

  String _disclosureReviewDescription(
    List<FinancialReportDisclosureReviewItem> items,
  ) {
    FinancialReportDisclosureReviewItem? firstOpenItem;
    for (final item in items) {
      if (item.needsReview) {
        firstOpenItem = item;
        break;
      }
    }
    if (firstOpenItem == null) {
      return 'Generated disclosure notes are prepared or approved for the report pack.';
    }
    return '${firstOpenItem.requirement.title} needs preparation or approval before statutory release.';
  }

  String _disclosureReviewLabel(
    List<FinancialReportDisclosureReviewItem> items,
  ) {
    final requiredItems = items.where((item) => item.requirement.blocksClose);
    final resolved = items.where((item) => item.isResolved).length;
    final approved =
        items
            .where(
              (item) =>
                  item.resolution?.status ==
                  FinancialReportDisclosureResolutionStatus.approved,
            )
            .length;
    final deferred = items.where((item) => item.isDeferred).length;
    return '$resolved/${items.length} resolved / ${requiredItems.length} required / $approved approved / $deferred deferred';
  }

  String _evidenceTaskLabel(
    List<FinancialReportEvidenceCloseTaskReviewItem> items,
  ) {
    if (items.isEmpty) {
      return 'No open evidence tasks';
    }
    final blockers = items.where((item) => item.blocksClose).length;
    final resolved = items.where((item) => item.isResolved).length;
    return '$blockers blocker(s) / ${items.length} task(s) / $resolved resolved';
  }

  String _exceptionLabel(List<FinancialReportExceptionReviewItem> exceptions) {
    if (exceptions.isEmpty) {
      return 'No exceptions';
    }
    final blockers = exceptions.where((item) => item.blocksClose);
    final resolved = exceptions.where((item) => item.isResolved);
    return '${blockers.length} blocker(s) / ${exceptions.length} exception(s) / ${resolved.length} resolved';
  }

  String? _varianceLabel(FinancialReportComplianceItem? item) {
    if (item == null || !item.hasVarianceEvidence) {
      return null;
    }

    final labels = <String>[];
    final variance = item.variance;
    if (variance != null) {
      labels.add('Var ${_money(variance)}');
    }
    final comparativeVariance = item.comparativeVariance;
    if (comparativeVariance != null) {
      labels.add('Comp ${_money(comparativeVariance)}');
    }
    if (item.hasMaterialityEvidence) {
      labels.add(item.isMaterialVariance ? 'Material' : 'Below materiality');
    }
    return labels.join(' / ');
  }

  String? _receivableReconciliationLabel(
    ReceivableReconciliation? reconciliation,
  ) {
    if (reconciliation == null) {
      return null;
    }
    return 'Sub ${_money(reconciliation.subledgerBalance)} / GL ${_money(reconciliation.ledgerBalance)} / Var ${_money(reconciliation.variance)}';
  }

  String _ledgerActivityLabel(TrialBalanceReport trialBalance) {
    return '${trialBalance.transactions.length} rows / '
        '${trialBalance.rows.length} account(s)';
  }

  String _bankReconciliationDescription(
    BankReconciliationControlSummary? controlSummary,
    BankReconciliationTimingRegisterSummary timingSummary,
    BankReconciliationTimingReviewSummary timingReviewSummary,
  ) {
    const base =
        'Bank statement activity ties to cash and bank ledger activity before close.';
    if (controlSummary == null) {
      return base;
    }
    final deadlineAction = _bankTimingDeadlineAction(
      timingSummary,
      timingReviewSummary,
    );
    final reviewAction = _bankTimingReviewAction(timingReviewSummary);
    final actions = <String>[
      controlSummary.nextAction,
      if (deadlineAction != null) deadlineAction,
      if (reviewAction != null) reviewAction,
    ];
    return '$base ${actions.join(' ')}';
  }

  String? _bankReconciliationLabel(
    BankReconciliation? reconciliation,
    BankReconciliationControlSummary? controlSummary,
    BankReconciliationTimingRegisterSummary timingSummary,
    BankReconciliationTimingReviewSummary timingReviewSummary,
  ) {
    if (reconciliation == null) {
      return controlSummary == null
          ? null
          : 'Action ${controlSummary.statusLabel}';
    }
    final controlLabels = <String>[
      if (controlSummary != null) 'Action ${controlSummary.statusLabel}',
      if ((controlSummary?.suggestedJournalCount ?? 0) > 0)
        'Journals ${controlSummary!.suggestedJournalCount}',
      if ((controlSummary?.timingDifferenceCount ?? 0) > 0)
        'Timing ${controlSummary!.timingDifferenceCount}',
      if (controlSummary?.timingAging.hasItems == true)
        'Aging ${controlSummary!.timingAgingLabel}',
      if (controlSummary?.timingAging.hasItems == true)
        'Exposure ${controlSummary!.timingAging.amountLabel(_money)}',
      if (timingSummary.deadlineRiskCount > 0)
        'Deadline ${timingSummary.overdueCount} overdue / ${timingSummary.dueSoonCount} due soon',
      if (timingReviewSummary.hasItems)
        'Review ${timingReviewSummary.coverageLabel}',
      if (timingReviewSummary.hasItems)
        'Resolved ${timingReviewSummary.resolvedLabel}',
      if (timingReviewSummary.unresolvedOverdueCount > 0)
        'Review overdue ${timingReviewSummary.unresolvedOverdueCount}',
      if (timingReviewSummary.needsOwnerCount > 0)
        'Owner gaps ${timingReviewSummary.needsOwnerCount}',
      if (controlSummary?.hasUnmatchedItems == true)
        'Oldest ${controlSummary!.oldestUnmatchedAgeLabel}',
      if (controlSummary?.hasStaleUnmatchedItems == true) 'Stale',
    ];
    if (!reconciliation.hasStatementEvidence) {
      return ['No statement lines', ...controlLabels].join(' / ');
    }
    return [
      'Stmt ${_money(reconciliation.statementMovement)}',
      'GL ${_money(reconciliation.ledgerMovement)}',
      'Var ${_money(reconciliation.variance)}',
      'Unmatched ${reconciliation.unmatchedCount}',
      ...controlLabels,
    ].join(' / ');
  }

  String? _bankTimingDeadlineAction(
    BankReconciliationTimingRegisterSummary timingSummary,
    BankReconciliationTimingReviewSummary timingReviewSummary,
  ) {
    if (timingSummary.overdueCount > 0) {
      if (timingReviewSummary.unresolvedOverdueCount > 0) {
        return 'Resolve ${timingReviewSummary.unresolvedOverdueCount} overdue timing review(s) before close.';
      }
      return 'Overdue timing item(s) have documented review evidence.';
    }
    if (timingSummary.dueSoonCount > 0) {
      return 'Monitor ${timingSummary.dueSoonCount} timing item(s) due soon.';
    }
    return null;
  }

  String? _bankTimingReviewAction(
    BankReconciliationTimingReviewSummary timingReviewSummary,
  ) {
    if (!timingReviewSummary.hasItems) {
      return null;
    }
    if (timingReviewSummary.unresolvedOverdueCount > 0) {
      return null;
    }
    if (timingReviewSummary.needsOwnerCount > 0) {
      return 'Assign ${timingReviewSummary.needsOwnerCount} timing review owner(s).';
    }
    if (timingReviewSummary.unreviewedCount > 0) {
      return 'Document ${timingReviewSummary.unreviewedCount} timing review item(s).';
    }
    if (timingReviewSummary.inReviewCount > 0) {
      return 'Follow up ${timingReviewSummary.inReviewCount} active timing review(s).';
    }
    return 'Timing review evidence is documented.';
  }

  String? _payableReconciliationLabel(PayableReconciliation? reconciliation) {
    if (reconciliation == null) {
      return null;
    }
    return 'Sub ${_money(reconciliation.subledgerBalance)} / GL ${_money(reconciliation.ledgerBalance)} / Var ${_money(reconciliation.variance)}';
  }

  String _money(double value) {
    return NumberFormat.compactCurrency(
      symbol: '',
    ).format(value).trim().replaceFirst(RegExp(r'\.00$'), '');
  }
}
