import 'package:intl/intl.dart';

import '../models/bank_reconciliation.dart';
import '../models/bank_reconciliation_control_summary.dart';
import '../models/bank_reconciliation_timing_register.dart';
import '../models/bank_reconciliation_timing_review.dart';
import '../models/accounting_policy_profile.dart';
import '../models/financial_entry.dart';
import '../models/financial_report_management_measure.dart';
import '../models/financial_report_mapping.dart';
import '../models/financial_report_pack.dart';
import '../models/financial_report_tax_profile.dart';
import 'bank_reconciliation_timing_review_evidence_service.dart';
import 'financial_equity_movement_classifier.dart';
import 'financial_report_cash_roll_forward_service.dart';
import 'financial_report_materiality_service.dart';
import 'financial_report_management_measure_service.dart';
import 'financial_report_reconciliation_service.dart';
import 'financial_report_tax_benchmark_service.dart';
import 'financial_report_tax_settlement_service.dart';
import 'financial_report_vat_settlement_service.dart';

const _managementPerformanceMeasureNoteReference = '6';
const _openDisclosureNoteReference = '7';

class FinancialReportPackService {
  static const defaultCorporateIncomeTaxRate =
      FinancialReportTaxProfiles.standardCorporateRate;

  final FinancialReportLineMapper lineMapper;
  final FinancialEquityMovementClassifier equityMovementClassifier;
  final FinancialReportReconciliationService reconciliationService;
  final FinancialReportMaterialityService materialityService;
  final FinancialReportTaxBenchmarkService taxBenchmarkService;
  final FinancialReportTaxSettlementService taxSettlementService;
  final FinancialReportVatSettlementService vatSettlementService;
  final FinancialReportCashRollForwardService cashRollForwardService;
  final FinancialReportManagementMeasureService managementMeasureService;
  final BankReconciliationTimingReviewEvidenceService reviewEvidenceService;
  final FinancialReportTaxProfile taxProfile;
  final AccountingPolicyProfile accountingPolicy;

  const FinancialReportPackService({
    this.lineMapper = const FinancialReportLineMapper(),
    this.equityMovementClassifier = const FinancialEquityMovementClassifier(),
    this.reconciliationService = const FinancialReportReconciliationService(),
    this.materialityService = const FinancialReportMaterialityService(),
    this.taxBenchmarkService = const FinancialReportTaxBenchmarkService(),
    this.taxSettlementService = const FinancialReportTaxSettlementService(),
    this.vatSettlementService = const FinancialReportVatSettlementService(),
    this.cashRollForwardService = const FinancialReportCashRollForwardService(),
    this.managementMeasureService =
        const FinancialReportManagementMeasureService(),
    this.reviewEvidenceService =
        const BankReconciliationTimingReviewEvidenceService(),
    this.taxProfile = FinancialReportTaxProfiles.standardCorporate,
    AccountingPolicyProfile? accountingPolicy,
  }) : accountingPolicy =
           accountingPolicy ?? AccountingPolicyProfiles.defaultProfile;

  double get corporateIncomeTaxRate => taxProfile.rate;

  FinancialReportPack build({
    required List<FinancialEntry> entries,
    required String periodLabel,
    required String asOfLabel,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? generatedAt,
    String? entityName,
    String? presentationCurrency,
    BankReconciliation? bankReconciliation,
    BankReconciliationControlSummary? bankReconciliationControlSummary,
    List<BankReconciliationTimingRegisterItem> bankTimingRegister = const [],
    Map<String, BankReconciliationTimingReview> bankTimingReviews = const {},
    List<FinancialReportManagementMeasure> managementMeasures = const [],
  }) {
    final effectiveEntityName = entityName ?? accountingPolicy.entityName;
    final effectivePresentationCurrency =
        presentationCurrency ?? accountingPolicy.presentationCurrency;
    final comparativePeriod = _comparativePeriodFor(periodStart, periodEnd);
    final periodEntries = entries.where(
      (entry) => _isInsidePeriod(entry.date, periodStart, periodEnd),
    );
    final comparativePeriodEntries =
        comparativePeriod == null
            ? const <FinancialEntry>[]
            : entries
                .where(
                  (entry) => _isInsidePeriod(
                    entry.date,
                    comparativePeriod.start,
                    comparativePeriod.end,
                  ),
                )
                .toList();
    final positionEntries = entries.where(
      (entry) => periodEnd == null || !entry.date.isAfter(periodEnd),
    );
    final comparativePositionEntries =
        comparativePeriod == null
            ? const <FinancialEntry>[]
            : entries
                .where((entry) => !entry.date.isAfter(comparativePeriod.end))
                .toList();
    final openingEntries =
        periodStart == null
            ? const <FinancialEntry>[]
            : entries.where((entry) => entry.date.isBefore(periodStart));
    final comparativeOpeningEntries =
        comparativePeriod == null
            ? const <FinancialEntry>[]
            : entries
                .where((entry) => entry.date.isBefore(comparativePeriod.start))
                .toList();

    final profitOrLoss = _buildProfitOrLossStatement(
      periodEntries.toList(),
      comparativePeriodEntries,
      periodLabel,
    );
    final position = _buildFinancialPositionStatement(
      positionEntries.toList(),
      comparativePositionEntries,
      asOfLabel,
    );
    final cashFlows = _buildCashFlowStatement(
      entries: entries,
      periodEntries: periodEntries.toList(),
      comparativePeriodEntries: comparativePeriodEntries,
      periodStart: periodStart,
      comparativePeriodStart: comparativePeriod?.start,
      periodLabel: periodLabel,
    );
    final changesInEquity = _buildChangesInEquityStatement(
      periodEntries: periodEntries.toList(),
      comparativePeriodEntries: comparativePeriodEntries,
      openingEntries: openingEntries.toList(),
      comparativeOpeningEntries: comparativeOpeningEntries,
      endingEquity: _amountFor(position, 'Total equity'),
      comparativeEndingEquity: _comparativeAmountFor(position, 'Total equity'),
      profitForPeriod: _amountFor(profitOrLoss, 'Profit (loss) for the period'),
      comparativeProfitForPeriod: _comparativeAmountFor(
        profitOrLoss,
        'Profit (loss) for the period',
      ),
      otherComprehensiveIncome: _amountFor(
        profitOrLoss,
        'Other comprehensive income',
      ),
      comparativeOtherComprehensiveIncome: _comparativeAmountFor(
        profitOrLoss,
        'Other comprehensive income',
      ),
      periodLabel: periodLabel,
    );

    final supportingSchedules = _buildSupportingSchedules(
      entries: entries,
      periodEntries: periodEntries.toList(),
      comparativePeriodEntries: comparativePeriodEntries,
      positionEntries: positionEntries.toList(),
      comparativePositionEntries: comparativePositionEntries,
      periodStart: periodStart,
      comparativePeriodStart: comparativePeriod?.start,
      profitOrLoss: profitOrLoss,
      periodLabel: periodLabel,
      bankReconciliation: bankReconciliation,
      bankReconciliationControlSummary: bankReconciliationControlSummary,
      bankTimingRegister: bankTimingRegister,
      bankTimingReviews: bankTimingReviews,
      managementMeasures: managementMeasures,
    );
    final notes = _buildNotes(
      periodLabel,
      effectivePresentationCurrency,
      comparativePeriod,
      supportingSchedules,
      accountingPolicy,
    );
    final notesStatement = _buildNotesStatement(notes, periodLabel);
    final statements = [
      position,
      profitOrLoss,
      changesInEquity,
      cashFlows,
      notesStatement,
    ];
    final materiality = materialityService.assess(
      position: position,
      profitOrLoss: profitOrLoss,
    );

    return FinancialReportPack(
      entityName: effectiveEntityName,
      frameworkName: accountingPolicy.frameworkName,
      jurisdiction: accountingPolicy.jurisdiction,
      presentationCurrency: effectivePresentationCurrency,
      periodLabel: periodLabel,
      asOfLabel: asOfLabel,
      comparativePeriodLabel: comparativePeriod?.label,
      comparativeAsOfLabel: comparativePeriod?.asOfLabel,
      periodStart: periodStart,
      periodEnd: periodEnd,
      generatedAt: generatedAt ?? DateTime.now(),
      statements: statements,
      notes: notes,
      supportingSchedules: supportingSchedules,
      complianceItems: _buildComplianceItems(
        statements: statements,
        position: position,
        profitOrLoss: profitOrLoss,
        changesInEquity: changesInEquity,
        cashFlows: cashFlows,
        notes: notes,
        periodEntries: periodEntries.toList(),
        supportingSchedules: supportingSchedules,
        hasComparativePeriod: comparativePeriod != null,
        hasComparativeSourceData:
            comparativePeriodEntries.isNotEmpty ||
            comparativePositionEntries.isNotEmpty,
        materiality: materiality,
        bankReconciliation: bankReconciliation,
        bankReconciliationControlSummary: bankReconciliationControlSummary,
      ),
      metrics: _buildMetrics(
        position,
        profitOrLoss,
        cashFlows,
        hasComparativePeriod: comparativePeriod != null,
      ),
      taxProfile: taxProfile,
    );
  }

  FinancialReportStatement _buildFinancialPositionStatement(
    List<FinancialEntry> entries,
    List<FinancialEntry> comparativeEntries,
    String asOfLabel,
  ) {
    final assetsByCategory = _sumByReportLine(entries, 'asset');
    final liabilitiesByCategory = _sumByReportLine(entries, 'liability');
    final equityByCategory = _sumByReportLine(entries, 'equity');
    final comparativeAssetsByCategory = _sumByReportLine(
      comparativeEntries,
      'asset',
    );
    final comparativeLiabilitiesByCategory = _sumByReportLine(
      comparativeEntries,
      'liability',
    );
    final comparativeEquityByCategory = _sumByReportLine(
      comparativeEntries,
      'equity',
    );

    final totalAssets = _sumMap(assetsByCategory);
    final totalLiabilities = _sumMap(liabilitiesByCategory);
    final explicitEquity = _sumMap(equityByCategory);
    final retainedEarnings = totalAssets - totalLiabilities - explicitEquity;
    final totalEquity = explicitEquity + retainedEarnings;
    final comparativeTotalAssets = _sumMap(comparativeAssetsByCategory);
    final comparativeTotalLiabilities = _sumMap(
      comparativeLiabilitiesByCategory,
    );
    final comparativeExplicitEquity = _sumMap(comparativeEquityByCategory);
    final comparativeRetainedEarnings =
        comparativeTotalAssets -
        comparativeTotalLiabilities -
        comparativeExplicitEquity;
    final comparativeTotalEquity =
        comparativeExplicitEquity + comparativeRetainedEarnings;

    return FinancialReportStatement(
      kind: FinancialReportStatementKind.financialPosition,
      title: 'Statement of Financial Position',
      subtitle: 'As of $asOfLabel',
      standardReferences: const ['PSAK 201'],
      lines: [
        const FinancialReportLine(
          label: 'Assets',
          type: FinancialReportLineType.section,
        ),
        ..._categoryLines(assetsByCategory, comparativeAssetsByCategory),
        FinancialReportLine(
          label: 'Total assets',
          amount: totalAssets,
          comparativeAmount: comparativeTotalAssets,
          type: FinancialReportLineType.total,
        ),
        const FinancialReportLine(
          label: 'Liabilities',
          type: FinancialReportLineType.section,
        ),
        ..._categoryLines(
          liabilitiesByCategory,
          comparativeLiabilitiesByCategory,
        ),
        FinancialReportLine(
          label: 'Total liabilities',
          amount: totalLiabilities,
          comparativeAmount: comparativeTotalLiabilities,
          type: FinancialReportLineType.total,
        ),
        const FinancialReportLine(
          label: 'Equity',
          type: FinancialReportLineType.section,
        ),
        ..._categoryLines(equityByCategory, comparativeEquityByCategory),
        FinancialReportLine(
          label: 'Retained earnings / current period result',
          amount: retainedEarnings,
          comparativeAmount: comparativeRetainedEarnings,
          noteReference: '4',
        ),
        FinancialReportLine(
          label: 'Total equity',
          amount: totalEquity,
          comparativeAmount: comparativeTotalEquity,
          type: FinancialReportLineType.total,
        ),
        FinancialReportLine(
          label: 'Total liabilities and equity',
          amount: totalLiabilities + totalEquity,
          comparativeAmount:
              comparativeTotalLiabilities + comparativeTotalEquity,
          type: FinancialReportLineType.total,
        ),
      ],
    );
  }

  FinancialReportStatement _buildProfitOrLossStatement(
    List<FinancialEntry> entries,
    List<FinancialEntry> comparativeEntries,
    String periodLabel,
  ) {
    final revenueByCategory = _sumByReportLine(entries, 'income');
    final operatingExpenseByCategory = _sumByReportLine(
      entries.where(
        (entry) =>
            lineMapper.expenseGroupFor(entry) ==
            FinancialReportExpenseGroup.operating,
      ),
      'expense',
    );
    final financeExpenseByCategory = _sumByReportLine(
      entries.where(
        (entry) =>
            lineMapper.expenseGroupFor(entry) ==
            FinancialReportExpenseGroup.finance,
      ),
      'expense',
    );
    final taxExpenseByCategory = _sumByReportLine(
      entries.where(
        (entry) =>
            lineMapper.expenseGroupFor(entry) ==
            FinancialReportExpenseGroup.tax,
      ),
      'expense',
    );
    final comparativeRevenueByCategory = _sumByReportLine(
      comparativeEntries,
      'income',
    );
    final comparativeOperatingExpenseByCategory = _sumByReportLine(
      comparativeEntries.where(
        (entry) =>
            lineMapper.expenseGroupFor(entry) ==
            FinancialReportExpenseGroup.operating,
      ),
      'expense',
    );
    final comparativeFinanceExpenseByCategory = _sumByReportLine(
      comparativeEntries.where(
        (entry) =>
            lineMapper.expenseGroupFor(entry) ==
            FinancialReportExpenseGroup.finance,
      ),
      'expense',
    );
    final comparativeTaxExpenseByCategory = _sumByReportLine(
      comparativeEntries.where(
        (entry) =>
            lineMapper.expenseGroupFor(entry) ==
            FinancialReportExpenseGroup.tax,
      ),
      'expense',
    );

    final totalRevenue = _sumMap(revenueByCategory);
    final operatingExpenses = _sumMap(operatingExpenseByCategory);
    final financeExpenses = _sumMap(financeExpenseByCategory);
    final taxExpense = _sumMap(taxExpenseByCategory);
    final operatingProfit = totalRevenue - operatingExpenses;
    final profitBeforeTax = operatingProfit - financeExpenses;
    final profitForPeriod = profitBeforeTax - taxExpense;
    final comparativeTotalRevenue = _sumMap(comparativeRevenueByCategory);
    final comparativeOperatingExpenses = _sumMap(
      comparativeOperatingExpenseByCategory,
    );
    final comparativeFinanceExpenses = _sumMap(
      comparativeFinanceExpenseByCategory,
    );
    final comparativeTaxExpense = _sumMap(comparativeTaxExpenseByCategory);
    final comparativeOperatingProfit =
        comparativeTotalRevenue - comparativeOperatingExpenses;
    final comparativeProfitBeforeTax =
        comparativeOperatingProfit - comparativeFinanceExpenses;
    final comparativeProfitForPeriod =
        comparativeProfitBeforeTax - comparativeTaxExpense;
    final otherComprehensiveIncome =
        equityMovementClassifier.summarize(entries).otherComprehensiveIncome;
    final comparativeOtherComprehensiveIncome =
        equityMovementClassifier
            .summarize(comparativeEntries)
            .otherComprehensiveIncome;

    return FinancialReportStatement(
      kind: FinancialReportStatementKind.profitOrLossAndOci,
      title: 'Statement of Profit or Loss and Other Comprehensive Income',
      subtitle: 'For $periodLabel',
      standardReferences: const ['PSAK 201', 'PSAK 118 ready'],
      lines: [
        const FinancialReportLine(
          label: 'Revenue',
          type: FinancialReportLineType.section,
        ),
        ..._categoryLines(revenueByCategory, comparativeRevenueByCategory),
        FinancialReportLine(
          label: 'Total revenue',
          amount: totalRevenue,
          comparativeAmount: comparativeTotalRevenue,
          type: FinancialReportLineType.subtotal,
        ),
        const FinancialReportLine(
          label: 'Operating expenses',
          type: FinancialReportLineType.section,
        ),
        ..._categoryLines(
          operatingExpenseByCategory,
          comparativeOperatingExpenseByCategory,
        ),
        FinancialReportLine(
          label: 'Total operating expenses',
          amount: operatingExpenses,
          comparativeAmount: comparativeOperatingExpenses,
          type: FinancialReportLineType.subtotal,
        ),
        FinancialReportLine(
          label: 'Operating profit (loss)',
          amount: operatingProfit,
          comparativeAmount: comparativeOperatingProfit,
          type: FinancialReportLineType.subtotal,
          noteReference: '5',
        ),
        FinancialReportLine(
          label: 'Profit (loss) before financing and income tax',
          amount: operatingProfit,
          comparativeAmount: comparativeOperatingProfit,
          type: FinancialReportLineType.subtotal,
          noteReference: '5',
        ),
        ..._optionalCategoryGroup(
          title: 'Finance costs',
          categories: financeExpenseByCategory,
          comparativeCategories: comparativeFinanceExpenseByCategory,
        ),
        FinancialReportLine(
          label: 'Profit (loss) before tax',
          amount: profitBeforeTax,
          comparativeAmount: comparativeProfitBeforeTax,
          type: FinancialReportLineType.subtotal,
        ),
        ..._optionalCategoryGroup(
          title: 'Income tax expense',
          categories: taxExpenseByCategory,
          comparativeCategories: comparativeTaxExpenseByCategory,
          forceTotal: true,
        ),
        FinancialReportLine(
          label: 'Profit (loss) for the period',
          amount: profitForPeriod,
          comparativeAmount: comparativeProfitForPeriod,
          type: FinancialReportLineType.total,
        ),
        FinancialReportLine(
          label: 'Other comprehensive income',
          amount: otherComprehensiveIncome,
          comparativeAmount: comparativeOtherComprehensiveIncome,
          noteReference: _openDisclosureNoteReference,
        ),
        FinancialReportLine(
          label: 'Total comprehensive income',
          amount: profitForPeriod + otherComprehensiveIncome,
          comparativeAmount:
              comparativeProfitForPeriod + comparativeOtherComprehensiveIncome,
          type: FinancialReportLineType.total,
        ),
      ],
    );
  }

  FinancialReportStatement _buildChangesInEquityStatement({
    required List<FinancialEntry> periodEntries,
    required List<FinancialEntry> comparativePeriodEntries,
    required List<FinancialEntry> openingEntries,
    required List<FinancialEntry> comparativeOpeningEntries,
    required double endingEquity,
    required double comparativeEndingEquity,
    required double profitForPeriod,
    required double comparativeProfitForPeriod,
    required double otherComprehensiveIncome,
    required double comparativeOtherComprehensiveIncome,
    required String periodLabel,
  }) {
    final openingEquity = _netAssets(openingEntries);
    final comparativeOpeningEquity = _netAssets(comparativeOpeningEntries);
    final movement = equityMovementClassifier.summarize(periodEntries);
    final comparativeMovement = equityMovementClassifier.summarize(
      comparativePeriodEntries,
    );
    final otherMovements =
        endingEquity -
        openingEquity -
        movement.ownerContributions +
        movement.ownerDistributions -
        profitForPeriod -
        otherComprehensiveIncome -
        movement.retainedEarningsTransfers -
        movement.otherReserveMovements;
    final comparativeOtherMovements =
        comparativeEndingEquity -
        comparativeOpeningEquity -
        comparativeMovement.ownerContributions +
        comparativeMovement.ownerDistributions -
        comparativeProfitForPeriod -
        comparativeOtherComprehensiveIncome -
        comparativeMovement.retainedEarningsTransfers -
        comparativeMovement.otherReserveMovements;

    return FinancialReportStatement(
      kind: FinancialReportStatementKind.changesInEquity,
      title: 'Statement of Changes in Equity',
      subtitle: 'For $periodLabel',
      standardReferences: const ['PSAK 201'],
      lines: [
        FinancialReportLine(
          label: 'Opening equity',
          amount: openingEquity,
          comparativeAmount: comparativeOpeningEquity,
          type: FinancialReportLineType.subtotal,
        ),
        FinancialReportLine(
          label: 'Owner contributions',
          amount: movement.ownerContributions,
          comparativeAmount: comparativeMovement.ownerContributions,
        ),
        FinancialReportLine(
          label: 'Owner distributions',
          amount: -movement.ownerDistributions,
          comparativeAmount: -comparativeMovement.ownerDistributions,
        ),
        FinancialReportLine(
          label: 'Profit (loss) for the period',
          amount: profitForPeriod,
          comparativeAmount: comparativeProfitForPeriod,
        ),
        FinancialReportLine(
          label: 'Other comprehensive income',
          amount: otherComprehensiveIncome,
          comparativeAmount: comparativeOtherComprehensiveIncome,
        ),
        FinancialReportLine(
          label: 'Retained earnings closing transfers',
          amount: movement.retainedEarningsTransfers,
          comparativeAmount: comparativeMovement.retainedEarningsTransfers,
          noteReference: '4',
        ),
        FinancialReportLine(
          label: 'Other equity reserve movements',
          amount: movement.otherReserveMovements,
          comparativeAmount: comparativeMovement.otherReserveMovements,
        ),
        FinancialReportLine(
          label: 'Other equity movements / closing entries',
          amount: otherMovements,
          comparativeAmount: comparativeOtherMovements,
          noteReference: '4',
        ),
        FinancialReportLine(
          label: 'Ending equity',
          amount: endingEquity,
          comparativeAmount: comparativeEndingEquity,
          type: FinancialReportLineType.total,
        ),
      ],
    );
  }

  FinancialReportStatement _buildCashFlowStatement({
    required List<FinancialEntry> entries,
    required List<FinancialEntry> periodEntries,
    required List<FinancialEntry> comparativePeriodEntries,
    required DateTime? periodStart,
    required DateTime? comparativePeriodStart,
    required String periodLabel,
  }) {
    final cashEntries = periodEntries.where(_isCashEntry).toList();
    final comparativeCashEntries =
        comparativePeriodEntries.where(_isCashEntry).toList();
    final operatingCashFlow = _cashFlowByBucket(
      cashEntries,
      _CashFlowBucket.operating,
    );
    final investingCashFlow = _cashFlowByBucket(
      cashEntries,
      _CashFlowBucket.investing,
    );
    final financingCashFlow = _cashFlowByBucket(
      cashEntries,
      _CashFlowBucket.financing,
    );
    final comparativeOperatingCashFlow = _cashFlowByBucket(
      comparativeCashEntries,
      _CashFlowBucket.operating,
    );
    final comparativeInvestingCashFlow = _cashFlowByBucket(
      comparativeCashEntries,
      _CashFlowBucket.investing,
    );
    final comparativeFinancingCashFlow = _cashFlowByBucket(
      comparativeCashEntries,
      _CashFlowBucket.financing,
    );
    final netCashFlow =
        operatingCashFlow + investingCashFlow + financingCashFlow;
    final comparativeNetCashFlow =
        comparativeOperatingCashFlow +
        comparativeInvestingCashFlow +
        comparativeFinancingCashFlow;
    final beginningCashBalance =
        periodStart == null
            ? 0.0
            : entries
                .where(
                  (entry) =>
                      _isCashEntry(entry) && entry.date.isBefore(periodStart),
                )
                .fold(0.0, (sum, entry) => sum + entry.amount);
    final comparativeBeginningCashBalance =
        comparativePeriodStart == null
            ? 0.0
            : entries
                .where(
                  (entry) =>
                      _isCashEntry(entry) &&
                      entry.date.isBefore(comparativePeriodStart),
                )
                .fold(0.0, (sum, entry) => sum + entry.amount);
    final endingCashBalance = beginningCashBalance + netCashFlow;
    final comparativeEndingCashBalance =
        comparativeBeginningCashBalance + comparativeNetCashFlow;

    return FinancialReportStatement(
      kind: FinancialReportStatementKind.cashFlows,
      title: 'Statement of Cash Flows',
      subtitle: 'For $periodLabel',
      standardReferences: const ['PSAK 207'],
      lines: [
        FinancialReportLine(
          label: 'Net cash from operating activities',
          amount: operatingCashFlow,
          comparativeAmount: comparativeOperatingCashFlow,
          type: FinancialReportLineType.subtotal,
        ),
        FinancialReportLine(
          label: 'Net cash from investing activities',
          amount: investingCashFlow,
          comparativeAmount: comparativeInvestingCashFlow,
          type: FinancialReportLineType.subtotal,
        ),
        FinancialReportLine(
          label: 'Net cash from financing activities',
          amount: financingCashFlow,
          comparativeAmount: comparativeFinancingCashFlow,
          type: FinancialReportLineType.subtotal,
        ),
        FinancialReportLine(
          label: 'Net increase (decrease) in cash and cash equivalents',
          amount: netCashFlow,
          comparativeAmount: comparativeNetCashFlow,
          type: FinancialReportLineType.total,
        ),
        FinancialReportLine(
          label: 'Cash and cash equivalents at beginning of period',
          amount: beginningCashBalance,
          comparativeAmount: comparativeBeginningCashBalance,
        ),
        FinancialReportLine(
          label: 'Cash and cash equivalents at end of period',
          amount: endingCashBalance,
          comparativeAmount: comparativeEndingCashBalance,
          type: FinancialReportLineType.total,
        ),
      ],
    );
  }

  List<FinancialReportSupportingSchedule> _buildSupportingSchedules({
    required List<FinancialEntry> entries,
    required List<FinancialEntry> periodEntries,
    required List<FinancialEntry> comparativePeriodEntries,
    required List<FinancialEntry> positionEntries,
    required List<FinancialEntry> comparativePositionEntries,
    required DateTime? periodStart,
    required DateTime? comparativePeriodStart,
    required FinancialReportStatement profitOrLoss,
    required String periodLabel,
    required BankReconciliation? bankReconciliation,
    required BankReconciliationControlSummary? bankReconciliationControlSummary,
    required List<BankReconciliationTimingRegisterItem> bankTimingRegister,
    required Map<String, BankReconciliationTimingReview> bankTimingReviews,
    required List<FinancialReportManagementMeasure> managementMeasures,
  }) {
    final schedules = [
      _buildCashRollForwardSchedule(
        entries: entries,
        periodEntries: periodEntries,
        comparativePeriodEntries: comparativePeriodEntries,
        positionEntries: positionEntries,
        comparativePositionEntries: comparativePositionEntries,
        periodStart: periodStart,
        comparativePeriodStart: comparativePeriodStart,
        periodLabel: periodLabel,
      ),
      _buildBankReconciliationSchedule(
        bankReconciliation: bankReconciliation,
        controlSummary: bankReconciliationControlSummary,
        timingRegister: bankTimingRegister,
        timingReviews: bankTimingReviews,
        periodLabel: periodLabel,
      ),
      _buildIncomeTaxSchedule(
        periodEntries: periodEntries,
        comparativePeriodEntries: comparativePeriodEntries,
        periodLabel: periodLabel,
      ),
      _buildIncomeTaxSettlementSchedule(
        periodEntries: periodEntries,
        comparativePeriodEntries: comparativePeriodEntries,
        positionEntries: positionEntries,
        comparativePositionEntries: comparativePositionEntries,
        periodLabel: periodLabel,
      ),
      _buildVatSettlementSchedule(
        positionEntries: positionEntries,
        comparativePositionEntries: comparativePositionEntries,
        periodLabel: periodLabel,
      ),
      _buildIncomeTaxReconciliationSchedule(
        periodEntries: periodEntries,
        comparativePeriodEntries: comparativePeriodEntries,
        profitOrLoss: profitOrLoss,
        periodLabel: periodLabel,
      ),
      _buildManagementPerformanceMeasureSchedule(
        profitOrLoss: profitOrLoss,
        periodLabel: periodLabel,
        managementMeasures: managementMeasures,
      ),
      _buildOciSchedule(
        periodEntries: periodEntries,
        comparativePeriodEntries: comparativePeriodEntries,
        periodLabel: periodLabel,
      ),
    ];
    return schedules.where((schedule) => schedule.hasActivity).toList();
  }

  FinancialReportSupportingSchedule _buildBankReconciliationSchedule({
    required BankReconciliation? bankReconciliation,
    required BankReconciliationControlSummary? controlSummary,
    required List<BankReconciliationTimingRegisterItem> timingRegister,
    required Map<String, BankReconciliationTimingReview> timingReviews,
    required String periodLabel,
  }) {
    final reconciliation = bankReconciliation;
    final hasEvidence =
        reconciliation != null && reconciliation.hasStatementEvidence;
    final timingSummary = BankReconciliationTimingRegisterSummary.fromItems(
      timingRegister,
    );
    final reviewSummary = reviewEvidenceService.summarize(
      items: timingRegister,
      reviews: timingReviews,
    );

    return FinancialReportSupportingSchedule(
      kind: FinancialReportSupportingScheduleKind.bankReconciliation,
      title: 'Bank Reconciliation Evidence',
      subtitle: 'Bank statement and GL cash/bank tie-out for $periodLabel.',
      totalLabel: 'Bank reconciliation variance',
      standardReferences: const ['PSAK 201', 'PSAK 207'],
      totalAmountOverride: hasEvidence ? reconciliation.variance : 0,
      metrics: [
        FinancialReportScheduleMetric(
          label: 'Statement lines',
          value: (reconciliation?.statementLines.length ?? 0).toString(),
          helperText: 'Imported bank statement lines included as evidence.',
        ),
        FinancialReportScheduleMetric(
          label: 'Matched lines',
          value: (reconciliation?.matches.length ?? 0).toString(),
          helperText: 'Statement lines matched to cash/bank ledger rows.',
        ),
        FinancialReportScheduleMetric(
          label: 'Unmatched items',
          value: (reconciliation?.unmatchedCount ?? 0).toString(),
          helperText: 'Unmatched statement and ledger items needing review.',
        ),
        FinancialReportScheduleMetric(
          label: 'Status',
          value:
              controlSummary?.statusLabel ??
              (reconciliation?.isBalanced == true
                  ? 'Balanced'
                  : 'Needs review'),
          helperText: 'Bank reconciliation readiness for the close package.',
        ),
        if (controlSummary != null) ...[
          FinancialReportScheduleMetric(
            label: 'Next action',
            value: controlSummary.nextAction,
            helperText: 'Operational close action for finance review.',
          ),
          FinancialReportScheduleMetric(
            label: 'Suggested journals',
            value: controlSummary.suggestedJournalCount.toString(),
            helperText: 'Bank adjustment journals identified for posting.',
          ),
          FinancialReportScheduleMetric(
            label: 'Timing differences',
            value: controlSummary.timingDifferenceCount.toString(),
            helperText: 'Ledger-only items expected to clear later.',
          ),
          FinancialReportScheduleMetric(
            label: 'Timing aging',
            value: controlSummary.timingAgingLabel,
            helperText:
                'Current, watch, and stale timing difference buckets for close review.',
          ),
          FinancialReportScheduleMetric(
            label: 'Timing exposure',
            value: controlSummary.timingAging.amountLabel(_metricAmount),
            helperText:
                'Absolute cash value of timing differences by aging bucket.',
          ),
          if (timingRegister.isNotEmpty)
            FinancialReportScheduleMetric(
              label: 'Timing deadline risk',
              value:
                  '${timingSummary.overdueCount} overdue / '
                  '${timingSummary.dueSoonCount} due soon',
              helperText:
                  'Clear-by deadline risk for timing differences in this pack.',
            ),
          if (timingRegister.isNotEmpty) ...[
            FinancialReportScheduleMetric(
              label: 'Timing review coverage',
              value: reviewEvidenceService.coverageValue(reviewSummary),
              helperText:
                  'Owner, status, and note evidence captured for timing differences.',
            ),
            FinancialReportScheduleMetric(
              label: 'Timing review action',
              value: reviewSummary.nextActionLabel,
              helperText:
                  'Review follow-up required before relying on timing evidence.',
            ),
            FinancialReportScheduleMetric(
              label: 'Timing review gaps',
              value: reviewEvidenceService.gapValue(reviewSummary),
              helperText: 'Open documentation, owner, and overdue review gaps.',
            ),
          ],
          FinancialReportScheduleMetric(
            label: 'Oldest open item',
            value: controlSummary.oldestUnmatchedAgeLabel,
            helperText:
                controlSummary.oldestUnmatchedReference == null
                    ? 'No unmatched bank item remains open.'
                    : 'Reference ${controlSummary.oldestUnmatchedReference}.',
          ),
          FinancialReportScheduleMetric(
            label: 'Stale unmatched item',
            value: controlSummary.hasStaleUnmatchedItems ? 'Yes' : 'No',
            helperText:
                'Uses a ${controlSummary.staleThresholdDays}-day stale-item threshold.',
          ),
        ],
      ],
      lines:
          hasEvidence
              ? [
                FinancialReportScheduleLine(
                  label: 'Statement movement',
                  amount: reconciliation.statementMovement,
                  sourceCategory: 'Imported bank statement lines',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'GL cash/bank movement',
                  amount: reconciliation.ledgerMovement,
                  sourceCategory: 'Cash and bank ledger rows',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'Reconciliation variance',
                  amount: reconciliation.variance,
                  sourceCategory: 'Statement movement less GL movement',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'Matched statement lines',
                  amount: reconciliation.matches.length.toDouble(),
                  sourceCategory: 'Matched bank activity count',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'Unmatched statement lines',
                  amount:
                      reconciliation.unmatchedStatementLines.length.toDouble(),
                  sourceCategory: 'Unmatched imported statement count',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'Unmatched cash ledger rows',
                  amount: reconciliation.unmatchedLedgerLines.length.toDouble(),
                  sourceCategory: 'Unmatched cash/bank ledger count',
                  noteReference: '3',
                ),
                for (final item in timingRegister)
                  FinancialReportScheduleLine(
                    label: 'Timing ${item.reference} - ${item.typeLabel}',
                    amount: item.amount,
                    sourceCategory: reviewEvidenceService.sourceLabel(
                      item: item,
                      review: timingReviews[item.reference],
                    ),
                    noteReference: '3',
                  ),
              ]
              : const [],
    );
  }

  FinancialReportSupportingSchedule _buildCashRollForwardSchedule({
    required List<FinancialEntry> entries,
    required List<FinancialEntry> periodEntries,
    required List<FinancialEntry> comparativePeriodEntries,
    required List<FinancialEntry> positionEntries,
    required List<FinancialEntry> comparativePositionEntries,
    required DateTime? periodStart,
    required DateTime? comparativePeriodStart,
    required String periodLabel,
  }) {
    final current = cashRollForwardService.summarize(
      allEntries: entries,
      periodEntries: periodEntries,
      positionEntries: positionEntries,
      lineMapper: lineMapper,
      periodStart: periodStart,
    );
    final comparative = cashRollForwardService.summarize(
      allEntries: entries,
      periodEntries: comparativePeriodEntries,
      positionEntries: comparativePositionEntries,
      lineMapper: lineMapper,
      periodStart: comparativePeriodStart,
    );
    final hasCashEvidence =
        current.hasCashEvidence || comparative.hasCashEvidence;

    return FinancialReportSupportingSchedule(
      kind: FinancialReportSupportingScheduleKind.cashRollForward,
      title: 'Cash Roll-Forward',
      subtitle:
          'Opening cash, cash movements, and closing cash tie-out for $periodLabel.',
      totalLabel: 'Cash roll-forward variance',
      standardReferences: const ['PSAK 207', 'PSAK 201'],
      totalAmountOverride: hasCashEvidence ? current.rollForwardVariance : 0,
      comparativeTotalAmountOverride:
          hasCashEvidence ? comparative.rollForwardVariance : 0,
      metrics: [
        FinancialReportScheduleMetric(
          label: 'Cash accounts',
          value: current.cashAccountCount.toString(),
          helperText: 'Distinct cash and bank statement line categories.',
        ),
        FinancialReportScheduleMetric(
          label: 'Cash movement lines',
          value: current.periodLineCount.toString(),
          helperText: 'Current-period cash and bank ledger lines included.',
        ),
        FinancialReportScheduleMetric(
          label: 'Opening lines',
          value: current.openingLineCount.toString(),
          helperText: 'Prior ledger lines supporting opening cash.',
        ),
      ],
      lines:
          hasCashEvidence
              ? [
                FinancialReportScheduleLine(
                  label: 'Opening cash and cash equivalents',
                  amount: current.openingCash,
                  comparativeAmount: comparative.openingCash,
                  sourceCategory: 'Prior-period cash and bank balances',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'Cash inflows',
                  amount: current.cashInflows,
                  comparativeAmount: comparative.cashInflows,
                  sourceCategory: 'Positive cash and bank movements',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'Less: cash outflows',
                  amount: -current.cashOutflows,
                  comparativeAmount: -comparative.cashOutflows,
                  sourceCategory: 'Negative cash and bank movements',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'Net cash movement',
                  amount: current.netCashMovement,
                  comparativeAmount: comparative.netCashMovement,
                  sourceCategory: 'Cash inflows less cash outflows',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'Calculated ending cash',
                  amount: current.calculatedClosingCash,
                  comparativeAmount: comparative.calculatedClosingCash,
                  sourceCategory: 'Opening cash plus net cash movement',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'Statement ending cash and cash equivalents',
                  amount: current.reportedClosingCash,
                  comparativeAmount: comparative.reportedClosingCash,
                  sourceCategory: 'Statement of financial position cash line',
                  noteReference: '3',
                ),
                FinancialReportScheduleLine(
                  label: 'Cash roll-forward variance',
                  amount: current.rollForwardVariance,
                  comparativeAmount: comparative.rollForwardVariance,
                  sourceCategory:
                      'Statement ending cash minus calculated ending cash',
                  noteReference: '3',
                ),
              ]
              : const [],
    );
  }

  FinancialReportSupportingSchedule _buildIncomeTaxSchedule({
    required List<FinancialEntry> periodEntries,
    required List<FinancialEntry> comparativePeriodEntries,
    required String periodLabel,
  }) {
    final taxEntries = periodEntries.where(_isIncomeTaxEntry).toList();
    final comparativeTaxEntries =
        comparativePeriodEntries.where(_isIncomeTaxEntry).toList();

    return FinancialReportSupportingSchedule(
      kind: FinancialReportSupportingScheduleKind.incomeTax,
      title: 'Income Tax Detail',
      subtitle: 'Income tax expense source lines for $periodLabel',
      totalLabel: 'Total income tax expense',
      standardReferences: const ['PSAK 212', 'PSAK 201'],
      metrics: [
        FinancialReportScheduleMetric(
          label: 'Source lines',
          value: taxEntries.length.toString(),
          helperText: 'Current-period ledger lines included in tax expense.',
        ),
        FinancialReportScheduleMetric(
          label: 'Source categories',
          value: _sourceCategoryCount(taxEntries).toString(),
          helperText: 'Distinct source categories represented in tax evidence.',
        ),
        if (comparativeTaxEntries.isNotEmpty)
          FinancialReportScheduleMetric(
            label: 'Comparative lines',
            value: comparativeTaxEntries.length.toString(),
            helperText: 'Prior-period tax ledger lines included.',
          ),
      ],
      lines: _scheduleLines(
        currentEntries: taxEntries,
        comparativeEntries: comparativeTaxEntries,
        labelFor: _incomeTaxScheduleLabel,
      ),
    );
  }

  FinancialReportSupportingSchedule _buildVatSettlementSchedule({
    required List<FinancialEntry> positionEntries,
    required List<FinancialEntry> comparativePositionEntries,
    required String periodLabel,
  }) {
    final current = vatSettlementService.summarize(
      positionEntries: positionEntries,
    );
    final comparative = vatSettlementService.summarize(
      positionEntries: comparativePositionEntries,
    );
    final hasVatEvidence = current.hasVatEvidence || comparative.hasVatEvidence;
    final hasNetSettlementEvidence =
        current.hasNetSettlementEvidence ||
        comparative.hasNetSettlementEvidence;

    return FinancialReportSupportingSchedule(
      kind: FinancialReportSupportingScheduleKind.valueAddedTaxSettlement,
      title: 'VAT / PPN Settlement',
      subtitle:
          'Input VAT, output VAT, and net payable/refund tie-out for $periodLabel.',
      totalLabel: 'VAT settlement variance',
      standardReferences: const ['PSAK 201', 'Indonesia VAT / PPN'],
      totalAmountOverride: hasVatEvidence ? current.settlementVariance : 0,
      comparativeTotalAmountOverride:
          hasVatEvidence ? comparative.settlementVariance : 0,
      metrics: [
        FinancialReportScheduleMetric(
          label: 'Input VAT lines',
          value: current.inputVatLineCount.toString(),
          helperText: 'Creditable input VAT balance lines included.',
        ),
        FinancialReportScheduleMetric(
          label: 'Output VAT lines',
          value: current.outputVatLineCount.toString(),
          helperText: 'Output VAT collected balance lines included.',
        ),
        FinancialReportScheduleMetric(
          label: 'Settlement lines',
          value: current.settlementLineCount.toString(),
          helperText: 'Net VAT payable or refund clearing lines included.',
        ),
      ],
      lines:
          hasVatEvidence
              ? [
                FinancialReportScheduleLine(
                  label: 'Output VAT collected',
                  amount: current.outputVat,
                  comparativeAmount: comparative.outputVat,
                  sourceCategory: 'PPN keluaran / output VAT liabilities',
                  noteReference: _openDisclosureNoteReference,
                ),
                FinancialReportScheduleLine(
                  label: 'Less: input VAT credit',
                  amount: -current.inputVat,
                  comparativeAmount: -comparative.inputVat,
                  sourceCategory: 'PPN masukan / input VAT assets',
                  noteReference: _openDisclosureNoteReference,
                ),
                FinancialReportScheduleLine(
                  label: 'Expected net VAT payable (refund)',
                  amount: current.expectedNetVatPayable,
                  comparativeAmount: comparative.expectedNetVatPayable,
                  sourceCategory: 'Output VAT less input VAT',
                  noteReference: _openDisclosureNoteReference,
                ),
                if (hasNetSettlementEvidence) ...[
                  FinancialReportScheduleLine(
                    label: 'Recorded net VAT payable (refund)',
                    amount: current.recordedNetVatPosition,
                    comparativeAmount: comparative.recordedNetVatPosition,
                    sourceCategory: 'Net VAT settlement clearing balance',
                    noteReference: _openDisclosureNoteReference,
                  ),
                  FinancialReportScheduleLine(
                    label: 'VAT settlement variance',
                    amount: current.settlementVariance,
                    comparativeAmount: comparative.settlementVariance,
                    sourceCategory:
                        'Recorded net VAT position minus expected net VAT',
                    noteReference: _openDisclosureNoteReference,
                  ),
                ],
              ]
              : const [],
    );
  }

  FinancialReportSupportingSchedule _buildIncomeTaxSettlementSchedule({
    required List<FinancialEntry> periodEntries,
    required List<FinancialEntry> comparativePeriodEntries,
    required List<FinancialEntry> positionEntries,
    required List<FinancialEntry> comparativePositionEntries,
    required String periodLabel,
  }) {
    final current = taxSettlementService.summarize(
      periodEntries: periodEntries,
      positionEntries: positionEntries,
      lineMapper: lineMapper,
    );
    final comparative = taxSettlementService.summarize(
      periodEntries: comparativePeriodEntries,
      positionEntries: comparativePositionEntries,
      lineMapper: lineMapper,
    );
    final hasSettlementEvidence =
        current.hasSettlementEvidence || comparative.hasSettlementEvidence;

    return FinancialReportSupportingSchedule(
      kind: FinancialReportSupportingScheduleKind.incomeTaxSettlement,
      title: 'Income Tax Settlement',
      subtitle:
          'Current tax expense, tax credits/prepayments, and payable tie-out for $periodLabel.',
      totalLabel: 'Tax settlement variance',
      standardReferences: const ['PSAK 212', 'PSAK 201'],
      totalAmountOverride:
          hasSettlementEvidence ? current.settlementVariance : 0,
      comparativeTotalAmountOverride:
          hasSettlementEvidence ? comparative.settlementVariance : 0,
      metrics: [
        FinancialReportScheduleMetric(
          label: 'Tax credit lines',
          value: current.taxCreditLineCount.toString(),
          helperText: 'Prepaid or withheld income tax credit lines included.',
        ),
        FinancialReportScheduleMetric(
          label: 'Tax payable lines',
          value: current.taxPayableLineCount.toString(),
          helperText: 'Income tax payable liability lines included.',
        ),
      ],
      lines:
          hasSettlementEvidence
              ? [
                FinancialReportScheduleLine(
                  label: 'Current tax expense',
                  amount: current.currentTaxExpense,
                  comparativeAmount: comparative.currentTaxExpense,
                  sourceCategory: 'Current-period income tax ledger lines',
                  noteReference: _openDisclosureNoteReference,
                ),
                FinancialReportScheduleLine(
                  label: 'Less: tax credits and prepayments',
                  amount: -current.taxCreditsAndPrepayments,
                  comparativeAmount: -comparative.taxCreditsAndPrepayments,
                  sourceCategory: 'Prepaid and withheld income tax assets',
                  noteReference: _openDisclosureNoteReference,
                ),
                FinancialReportScheduleLine(
                  label: 'Expected income tax payable (receivable)',
                  amount: current.expectedTaxPayable,
                  comparativeAmount: comparative.expectedTaxPayable,
                  sourceCategory: 'Current tax less credits/prepayments',
                  noteReference: _openDisclosureNoteReference,
                ),
                FinancialReportScheduleLine(
                  label: 'Recorded income tax payable',
                  amount: current.recordedTaxPayable,
                  comparativeAmount: comparative.recordedTaxPayable,
                  sourceCategory: 'Income tax payable liability balance',
                  noteReference: _openDisclosureNoteReference,
                ),
                FinancialReportScheduleLine(
                  label: 'Tax settlement variance',
                  amount: current.settlementVariance,
                  comparativeAmount: comparative.settlementVariance,
                  sourceCategory: 'Recorded payable minus expected payable',
                  noteReference: _openDisclosureNoteReference,
                ),
              ]
              : const [],
    );
  }

  FinancialReportSupportingSchedule _buildIncomeTaxReconciliationSchedule({
    required List<FinancialEntry> periodEntries,
    required List<FinancialEntry> comparativePeriodEntries,
    required FinancialReportStatement profitOrLoss,
    required String periodLabel,
  }) {
    final profitBeforeTax = _amountFor(
      profitOrLoss,
      'Profit (loss) before tax',
    );
    final comparativeProfitBeforeTax = _comparativeAmountFor(
      profitOrLoss,
      'Profit (loss) before tax',
    );
    final grossTurnover = _amountFor(profitOrLoss, 'Total revenue');
    final comparativeGrossTurnover = _comparativeAmountFor(
      profitOrLoss,
      'Total revenue',
    );
    final currentTax = _sumWhere(periodEntries, _isCurrentTaxEntry);
    final deferredTax = _sumWhere(periodEntries, _isDeferredTaxEntry);
    final taxSourceLineCount = periodEntries.where(_isIncomeTaxEntry).length;
    final comparativeCurrentTax = _sumWhere(
      comparativePeriodEntries,
      _isCurrentTaxEntry,
    );
    final comparativeDeferredTax = _sumWhere(
      comparativePeriodEntries,
      _isDeferredTaxEntry,
    );
    final taxBenchmark = taxBenchmarkService.calculate(
      profile: taxProfile,
      profitBeforeTax: profitBeforeTax,
      grossTurnover: grossTurnover,
    );
    final comparativeTaxBenchmark = taxBenchmarkService.calculate(
      profile: taxProfile,
      profitBeforeTax: comparativeProfitBeforeTax,
      grossTurnover: comparativeGrossTurnover,
    );
    final expectedTax = taxBenchmark.expectedTax;
    final comparativeExpectedTax = comparativeTaxBenchmark.expectedTax;
    final recordedTax = currentTax + deferredTax;
    final comparativeRecordedTax =
        comparativeCurrentTax + comparativeDeferredTax;
    final effectiveTaxRate = _effectiveTaxRate(
      recordedTax: recordedTax,
      profitBeforeTax: profitBeforeTax,
    );

    return FinancialReportSupportingSchedule(
      kind: FinancialReportSupportingScheduleKind.incomeTaxReconciliation,
      title: 'Income Tax Reconciliation',
      subtitle:
          'Accounting profit-to-tax bridge for $periodLabel using ${taxProfile.label} (${taxBenchmark.rateLabel}).',
      totalLabel: 'Tax reconciliation difference',
      standardReferences: const ['PSAK 212', 'PSAK 201'],
      totalAmountOverride: recordedTax - expectedTax,
      comparativeTotalAmountOverride:
          comparativeRecordedTax - comparativeExpectedTax,
      metrics: [
        FinancialReportScheduleMetric(
          label: 'Effective tax rate',
          value: _rateLabel(effectiveTaxRate),
          helperText: 'Recorded tax expense divided by profit before tax.',
        ),
        FinancialReportScheduleMetric(
          label: 'Statutory benchmark',
          value: taxBenchmark.rateLabel,
          helperText: taxBenchmark.methodLabel,
        ),
        FinancialReportScheduleMetric(
          label: 'Benchmark profile',
          value: taxProfile.shortLabel,
          helperText: taxProfile.taxReference,
        ),
        FinancialReportScheduleMetric(
          label: 'Tax source lines',
          value: taxSourceLineCount.toString(),
          helperText: 'Ledger lines supporting recorded tax expense.',
        ),
      ],
      lines: [
        FinancialReportScheduleLine(
          label: 'Profit (loss) before tax',
          amount: profitBeforeTax,
          comparativeAmount: comparativeProfitBeforeTax,
          sourceCategory: 'Profit or loss subtotal',
          noteReference: _openDisclosureNoteReference,
        ),
        FinancialReportScheduleLine(
          label: taxBenchmark.expectedTaxLineLabel,
          amount: expectedTax,
          comparativeAmount: comparativeExpectedTax,
          sourceCategory: taxProfile.label,
          noteReference: _openDisclosureNoteReference,
        ),
        ..._taxBenchmarkEvidenceLines(
          current: taxBenchmark,
          comparative: comparativeTaxBenchmark,
        ),
        FinancialReportScheduleLine(
          label: 'Current tax expense',
          amount: currentTax,
          comparativeAmount: comparativeCurrentTax,
          sourceCategory: 'Current-period income tax ledger lines',
          noteReference: _openDisclosureNoteReference,
        ),
        FinancialReportScheduleLine(
          label: 'Deferred tax expense (benefit)',
          amount: deferredTax,
          comparativeAmount: comparativeDeferredTax,
          sourceCategory: 'Temporary-difference tax ledger lines',
          noteReference: _openDisclosureNoteReference,
        ),
        FinancialReportScheduleLine(
          label: 'Recorded income tax expense',
          amount: recordedTax,
          comparativeAmount: comparativeRecordedTax,
          sourceCategory: 'Current plus deferred tax expense',
          noteReference: _openDisclosureNoteReference,
        ),
        FinancialReportScheduleLine(
          label: 'Permanent differences, credits, or missing tax evidence',
          amount: recordedTax - expectedTax,
          comparativeAmount: comparativeRecordedTax - comparativeExpectedTax,
          sourceCategory: 'Recorded tax minus expected tax',
          noteReference: _openDisclosureNoteReference,
        ),
      ],
    );
  }

  List<FinancialReportScheduleLine> _taxBenchmarkEvidenceLines({
    required FinancialReportTaxBenchmarkResult current,
    required FinancialReportTaxBenchmarkResult comparative,
  }) {
    if (!current.hasArticle31eEvidence && !comparative.hasArticle31eEvidence) {
      return const [];
    }

    return [
      FinancialReportScheduleLine(
        label: 'Gross turnover for Article 31E test',
        amount: current.grossTurnover,
        comparativeAmount: comparative.grossTurnover,
        sourceCategory: 'Report revenue lines',
        noteReference: _openDisclosureNoteReference,
      ),
      FinancialReportScheduleLine(
        label: 'Article 31E eligible taxable income',
        amount: current.eligibleTaxableIncome,
        comparativeAmount: comparative.eligibleTaxableIncome,
        sourceCategory: 'Turnover up to IDR 4.8B divided by gross turnover',
        noteReference: _openDisclosureNoteReference,
      ),
      FinancialReportScheduleLine(
        label: 'Tax at Article 31E discounted rate',
        amount: current.discountedTax,
        comparativeAmount: comparative.discountedTax,
        sourceCategory: '50% of standard PPh Badan rate',
        noteReference: _openDisclosureNoteReference,
      ),
      FinancialReportScheduleLine(
        label: 'Tax at standard rate after facility',
        amount: current.standardTax,
        comparativeAmount: comparative.standardTax,
        sourceCategory: 'Taxable income not covered by facility',
        noteReference: _openDisclosureNoteReference,
      ),
    ];
  }

  FinancialReportSupportingSchedule _buildManagementPerformanceMeasureSchedule({
    required FinancialReportStatement profitOrLoss,
    required String periodLabel,
    required List<FinancialReportManagementMeasure> managementMeasures,
  }) {
    final reconciliations = managementMeasureService.reconcileAll(
      profitOrLoss: profitOrLoss,
      measures: managementMeasures,
    );
    final approvedCount = managementMeasureService.approvedCount(
      reconciliations,
    );
    final openVarianceCount = managementMeasureService.openVarianceCount(
      reconciliations,
    );
    final closestSubtotalLabels =
        reconciliations
            .map(
              (reconciliation) =>
                  reconciliation.measure.closestSubtotalShortLabel,
            )
            .toSet();

    return FinancialReportSupportingSchedule(
      kind: FinancialReportSupportingScheduleKind.managementPerformanceMeasure,
      title: 'UKTM Reconciliation',
      subtitle:
          'Management performance measure reconciliation for $periodLabel.',
      totalLabel: 'UKTM reconciliation variance',
      standardReferences: const ['PSAK 118', 'UKTM'],
      metrics: [
        FinancialReportScheduleMetric(
          label: 'Management measures',
          value: reconciliations.length.toString(),
          helperText: 'Management-designated performance measures documented.',
        ),
        FinancialReportScheduleMetric(
          label: 'Closest SAK subtotal',
          value:
              closestSubtotalLabels.length == 1
                  ? closestSubtotalLabels.single
                  : 'Multiple subtotals',
          helperText: 'Reconciled to profit before financing and income tax.',
        ),
        FinancialReportScheduleMetric(
          label: 'Approval status',
          value:
              reconciliations.length == 1
                  ? reconciliations.single.measure.approvalStatus.label
                  : '$approvedCount/${reconciliations.length} approved',
          helperText:
              'Management approval is required before external release.',
        ),
        FinancialReportScheduleMetric(
          label: 'Open variances',
          value: openVarianceCount.toString(),
          helperText: 'Management measures with unreconciled UKTM variance.',
        ),
      ],
      lines: _managementPerformanceMeasureLines(reconciliations),
    );
  }

  List<FinancialReportScheduleLine> _managementPerformanceMeasureLines(
    List<FinancialReportManagementMeasureReconciliation> reconciliations,
  ) {
    return [
      for (final reconciliation in reconciliations) ...[
        FinancialReportScheduleLine(
          label: 'UKTM: ${reconciliation.measure.label}',
          amount: reconciliation.measureAmount,
          comparativeAmount: reconciliation.comparativeMeasureAmount,
          sourceCategory:
              'Owner ${reconciliation.measure.owner} / '
              '${reconciliation.measure.approvalStatus.label}',
          noteReference: _managementPerformanceMeasureNoteReference,
        ),
        FinancialReportScheduleLine(
          label: 'Less: ${reconciliation.measure.closestSubtotalLabel}',
          amount: -reconciliation.subtotalAmount,
          comparativeAmount:
              reconciliation.comparativeSubtotalAmount == null
                  ? null
                  : -reconciliation.comparativeSubtotalAmount!,
          sourceCategory: 'Closest directly comparable PSAK 118 subtotal',
          noteReference: _managementPerformanceMeasureNoteReference,
        ),
        if (reconciliation.measure.adjustments.isEmpty)
          const FinancialReportScheduleLine(
            label: 'Reconciling management adjustments',
            amount: 0,
            comparativeAmount: 0,
            sourceCategory:
                'No separate management adjustments captured in source data',
            noteReference: _managementPerformanceMeasureNoteReference,
          )
        else
          for (final adjustment in reconciliation.measure.adjustments)
            FinancialReportScheduleLine(
              label: 'Adjustment: ${adjustment.label}',
              amount: -adjustment.amount,
              comparativeAmount:
                  adjustment.comparativeAmount == null
                      ? null
                      : -adjustment.comparativeAmount!,
              sourceCategory: adjustment.sourceReference,
              noteReference: _managementPerformanceMeasureNoteReference,
            ),
      ],
    ];
  }

  FinancialReportSupportingSchedule _buildOciSchedule({
    required List<FinancialEntry> periodEntries,
    required List<FinancialEntry> comparativePeriodEntries,
    required String periodLabel,
  }) {
    final ociEntries = periodEntries.where(_isOciEntry).toList();
    final comparativeOciEntries =
        comparativePeriodEntries.where(_isOciEntry).toList();

    return FinancialReportSupportingSchedule(
      kind: FinancialReportSupportingScheduleKind.otherComprehensiveIncome,
      title: 'Other Comprehensive Income Detail',
      subtitle: 'OCI reserve source lines for $periodLabel',
      totalLabel: 'Total other comprehensive income',
      standardReferences: const ['PSAK 201'],
      metrics: [
        FinancialReportScheduleMetric(
          label: 'Source lines',
          value: ociEntries.length.toString(),
          helperText: 'Current-period ledger lines classified as OCI.',
        ),
        FinancialReportScheduleMetric(
          label: 'Source categories',
          value: _sourceCategoryCount(ociEntries).toString(),
          helperText: 'Distinct OCI source categories represented.',
        ),
        if (comparativeOciEntries.isNotEmpty)
          FinancialReportScheduleMetric(
            label: 'Comparative lines',
            value: comparativeOciEntries.length.toString(),
            helperText: 'Prior-period OCI ledger lines included.',
          ),
      ],
      lines: _scheduleLines(
        currentEntries: ociEntries,
        comparativeEntries: comparativeOciEntries,
        labelFor: _ociScheduleLabel,
      ),
    );
  }

  List<FinancialReportScheduleLine> _scheduleLines({
    required Iterable<FinancialEntry> currentEntries,
    required Iterable<FinancialEntry> comparativeEntries,
    required String Function(FinancialEntry entry) labelFor,
  }) {
    final current = _sumScheduleDetails(currentEntries, labelFor);
    final comparative = _sumScheduleDetails(comparativeEntries, labelFor);
    final labels =
        {...current.keys, ...comparative.keys}.toList()..sort((left, right) {
          final order = lineMapper
              .sortOrderForLabel(left)
              .compareTo(lineMapper.sortOrderForLabel(right));
          if (order != 0) {
            return order;
          }
          return left.compareTo(right);
        });

    return labels
        .map(
          (label) => FinancialReportScheduleLine(
            label: label,
            amount: current[label]?.amount ?? 0,
            comparativeAmount:
                comparative.containsKey(label)
                    ? comparative[label]?.amount ?? 0
                    : null,
            sourceCategory:
                current[label]?.sourceCategory ??
                comparative[label]?.sourceCategory,
            noteReference: _openDisclosureNoteReference,
          ),
        )
        .toList();
  }

  Map<String, _ScheduleDetail> _sumScheduleDetails(
    Iterable<FinancialEntry> entries,
    String Function(FinancialEntry entry) labelFor,
  ) {
    final values = <String, _ScheduleDetail>{};
    for (final entry in entries) {
      final label = labelFor(entry);
      final existing = values[label];
      values[label] = _ScheduleDetail(
        amount: (existing?.amount ?? 0) + entry.amount,
        sourceCategory: _mergeScheduleSource(
          existing?.sourceCategory,
          entry.sourceCategory ?? entry.category,
        ),
      );
    }
    return values;
  }

  String? _mergeScheduleSource(String? current, String next) {
    final trimmedNext = next.trim();
    if (trimmedNext.isEmpty) {
      return current;
    }
    if (current == null || current.isEmpty) {
      return trimmedNext;
    }
    if (current == trimmedNext || current == 'Multiple sources') {
      return current;
    }
    return 'Multiple sources';
  }

  int _sourceCategoryCount(Iterable<FinancialEntry> entries) {
    return entries
        .map((entry) => (entry.sourceCategory ?? entry.category).trim())
        .where((source) => source.isNotEmpty)
        .toSet()
        .length;
  }

  double? _effectiveTaxRate({
    required double recordedTax,
    required double profitBeforeTax,
  }) {
    if (profitBeforeTax.abs() < 0.01) {
      return null;
    }
    return recordedTax / profitBeforeTax;
  }

  String _rateLabel(double? rate) {
    if (rate == null) {
      return 'N/A';
    }
    return '${(rate * 100).toStringAsFixed(1)}%';
  }

  bool _isIncomeTaxEntry(FinancialEntry entry) {
    return entry.type == 'expense' &&
        lineMapper.expenseGroupFor(entry) == FinancialReportExpenseGroup.tax;
  }

  bool _isCurrentTaxEntry(FinancialEntry entry) {
    return _isIncomeTaxEntry(entry) && !_isDeferredTaxEntry(entry);
  }

  bool _isDeferredTaxEntry(FinancialEntry entry) {
    if (!_isIncomeTaxEntry(entry)) {
      return false;
    }
    final label = FinancialReportLineMapper.searchLabelFor(entry);
    return label.contains('deferred') || label.contains('tangguhan');
  }

  String _incomeTaxScheduleLabel(FinancialEntry entry) {
    if (_isDeferredTaxEntry(entry)) {
      return 'Deferred tax expense (benefit)';
    }
    return lineMapper.lineLabelFor(entry);
  }

  bool _isOciEntry(FinancialEntry entry) {
    return entry.type == 'equity' &&
        equityMovementClassifier.classify(entry) ==
            FinancialEquityMovementType.otherComprehensiveIncome;
  }

  String _ociScheduleLabel(FinancialEntry entry) {
    final sourceCategory = entry.sourceCategory?.trim();
    if (sourceCategory != null && sourceCategory.isNotEmpty) {
      return sourceCategory;
    }
    return lineMapper.lineLabelFor(entry);
  }

  List<FinancialReportDisclosureNote> _buildNotes(
    String periodLabel,
    String presentationCurrency,
    _ComparativePeriod? comparativePeriod,
    List<FinancialReportSupportingSchedule> supportingSchedules,
    AccountingPolicyProfile accountingPolicy,
  ) {
    final comparativeText =
        comparativePeriod == null
            ? accountingPolicy.requireComparatives
                ? 'Comparative columns are available once a bounded reporting period is selected.'
                : 'Comparative columns are not required under the selected reporting policy for this management pack.'
            : 'Comparative columns use ${comparativePeriod.label} and the financial-position comparison date ${comparativePeriod.asOfLabel}.';
    final scheduleTitles = supportingSchedules
        .map((schedule) => schedule.title)
        .join(', ');
    final sourceDetailText =
        supportingSchedules.isEmpty
            ? 'Income tax schedules, OCI detail, related-party disclosures, and material accounting policy notes require source data not yet captured in this module.'
            : 'Supporting schedules are included for $scheduleTitles. Related-party disclosures and material accounting policy notes still require accountant review before statutory filing.';
    return [
      FinancialReportDisclosureNote(
        number: '1',
        title: 'Basis of preparation',
        body:
            'Prepared as a management report pack using ${accountingPolicy.frameworkName} presentation concepts for $periodLabel. Amounts are presented in $presentationCurrency for ${accountingPolicy.jurisdiction} reporting and should be reviewed before statutory filing.',
        standardReferences: [accountingPolicy.standardReference],
      ),
      FinancialReportDisclosureNote(
        number: '2',
        title: 'Accounting basis',
        body:
            accountingPolicy.accrualBasis
                ? 'Profit or loss is prepared on an accrual basis from mapped ledger accounts. Cash flows are prepared from cash-account movements. The functional currency is ${accountingPolicy.functionalCurrency}; amounts are presented in ${accountingPolicy.presentationCurrency}.'
                : 'The selected policy is cash basis. Review statutory suitability before issuing external financial statements. The functional currency is ${accountingPolicy.functionalCurrency}; amounts are presented in ${accountingPolicy.presentationCurrency}.',
        standardReferences: [accountingPolicy.standardReference, 'PSAK 207'],
      ),
      const FinancialReportDisclosureNote(
        number: '3',
        title: 'Cash flow classification',
        body:
            'Cash movements are grouped into operating, investing, and financing buckets from account and source labels. This provides a reviewable draft before accountant finalisation.',
        standardReferences: ['PSAK 207'],
      ),
      const FinancialReportDisclosureNote(
        number: '4',
        title: 'Equity reconciliation',
        body:
            'Retained earnings and other equity movements are derived from the accounting equation when closing entries or detailed equity ledgers are not yet available.',
        standardReferences: ['PSAK 201'],
      ),
      const FinancialReportDisclosureNote(
        number: '5',
        title: 'PSAK 118 readiness',
        body:
            'The profit or loss structure exposes operating profit, profit before financing and income tax, profit before tax, and finance cost groupings so the report can evolve toward PSAK 118 when effective on 1 January 2027.',
        standardReferences: ['PSAK 118'],
      ),
      const FinancialReportDisclosureNote(
        number: '6',
        title: 'UKTM / management performance measures',
        body:
            'Management-designated performance for this pack is anchored to profit before financing and income tax, reconciled directly to the PSAK 118 subtotal with no separate management adjustments captured in source data. Any additional UKTM measure should be approved and reconciled before external release.',
        standardReferences: ['PSAK 118', 'UKTM'],
      ),
      FinancialReportDisclosureNote(
        number: '7',
        title: 'Open disclosure data',
        body: sourceDetailText,
        standardReferences: const ['PSAK 201', 'PSAK 212'],
      ),
      FinancialReportDisclosureNote(
        number: '8',
        title: 'Comparative information',
        body: comparativeText,
        standardReferences: [accountingPolicy.standardReference],
      ),
      const FinancialReportDisclosureNote(
        number: '9',
        title: 'Chart-to-report mapping',
        body:
            'Account codes and account labels are mapped into standardized report lines such as cash, receivables, inventories, payables, revenue, operating expenses, finance costs, and tax expense.',
        standardReferences: ['PSAK 201', 'PSAK 118'],
      ),
    ];
  }

  FinancialReportStatement _buildNotesStatement(
    List<FinancialReportDisclosureNote> notes,
    String periodLabel,
  ) {
    return FinancialReportStatement(
      kind: FinancialReportStatementKind.notes,
      title: 'Notes to Financial Statements',
      subtitle: 'For $periodLabel',
      standardReferences: const ['PSAK 201'],
      lines:
          notes.map((note) {
            return FinancialReportLine(
              label: 'Note ${note.number}. ${note.title}',
              type: FinancialReportLineType.note,
              noteReference: note.number,
            );
          }).toList(),
    );
  }

  List<FinancialReportComplianceItem> _buildComplianceItems({
    required List<FinancialReportStatement> statements,
    required FinancialReportStatement position,
    required FinancialReportStatement profitOrLoss,
    required FinancialReportStatement changesInEquity,
    required FinancialReportStatement cashFlows,
    required List<FinancialReportDisclosureNote> notes,
    required List<FinancialEntry> periodEntries,
    required List<FinancialReportSupportingSchedule> supportingSchedules,
    required bool hasComparativePeriod,
    required bool hasComparativeSourceData,
    required FinancialReportMaterialityAssessment materiality,
    required BankReconciliation? bankReconciliation,
    required BankReconciliationControlSummary? bankReconciliationControlSummary,
  }) {
    final reconciliationChecks = reconciliationService.buildChecks(
      position: position,
      profitOrLoss: profitOrLoss,
      changesInEquity: changesInEquity,
      cashFlows: cashFlows,
    );
    final hasTaxOrOciSchedule = supportingSchedules.any(
      (schedule) =>
          schedule.kind == FinancialReportSupportingScheduleKind.incomeTax ||
          schedule.kind ==
              FinancialReportSupportingScheduleKind.incomeTaxSettlement ||
          schedule.kind ==
              FinancialReportSupportingScheduleKind.incomeTaxReconciliation ||
          schedule.kind ==
              FinancialReportSupportingScheduleKind.valueAddedTaxSettlement ||
          schedule.kind ==
              FinancialReportSupportingScheduleKind.otherComprehensiveIncome,
    );
    final cashRollForwardSchedule = _scheduleFor(
      supportingSchedules,
      FinancialReportSupportingScheduleKind.cashRollForward,
    );
    final taxReconciliationSchedule = _scheduleFor(
      supportingSchedules,
      FinancialReportSupportingScheduleKind.incomeTaxReconciliation,
    );
    final taxSettlementSchedule = _scheduleFor(
      supportingSchedules,
      FinancialReportSupportingScheduleKind.incomeTaxSettlement,
    );
    final vatSettlementSchedule = _scheduleFor(
      supportingSchedules,
      FinancialReportSupportingScheduleKind.valueAddedTaxSettlement,
    );
    final cashRollForwardVariance = cashRollForwardSchedule?.totalAmount;
    final comparativeCashRollForwardVariance =
        cashRollForwardSchedule?.comparativeTotalAmount;
    final taxReconciliationVariance = taxReconciliationSchedule?.totalAmount;
    final comparativeTaxReconciliationVariance =
        taxReconciliationSchedule?.comparativeTotalAmount;
    final taxSettlementVariance = taxSettlementSchedule?.totalAmount;
    final comparativeTaxSettlementVariance =
        taxSettlementSchedule?.comparativeTotalAmount;
    final vatSettlementVariance = vatSettlementSchedule?.totalAmount;
    final comparativeVatSettlementVariance =
        vatSettlementSchedule?.comparativeTotalAmount;
    final taxReconciliationIsSatisfied =
        taxReconciliationSchedule == null ||
        !materiality.isMaterialVariance(
          variance: taxReconciliationVariance,
          comparativeVariance: comparativeTaxReconciliationVariance,
        );
    final cashRollForwardIsSatisfied =
        cashRollForwardSchedule == null ||
        !materiality.isMaterialVariance(
          variance: cashRollForwardVariance,
          comparativeVariance: comparativeCashRollForwardVariance,
        );
    final taxSettlementIsSatisfied =
        taxSettlementSchedule == null ||
        !materiality.isMaterialVariance(
          variance: taxSettlementVariance,
          comparativeVariance: comparativeTaxSettlementVariance,
        );
    final vatSettlementIsSatisfied =
        vatSettlementSchedule == null ||
        !materiality.isMaterialVariance(
          variance: vatSettlementVariance,
          comparativeVariance: comparativeVatSettlementVariance,
        );
    final bankReconciliationCompliance =
        bankReconciliation == null
            ? const <FinancialReportComplianceItem>[]
            : [
              FinancialReportComplianceItem(
                id: 'bank-reconciliation',
                title: 'Bank reconciliation evidence',
                description: _bankReconciliationComplianceDescription(
                  reconciliation: bankReconciliation,
                  controlSummary: bankReconciliationControlSummary,
                ),
                standardReference: 'PSAK 201 / PSAK 207',
                isSatisfied: bankReconciliation.isBalanced,
                variance:
                    bankReconciliation.hasStatementEvidence
                        ? bankReconciliation.variance
                        : null,
                materialityThreshold:
                    bankReconciliation.hasStatementEvidence
                        ? materiality.threshold
                        : null,
                materialityBasis:
                    bankReconciliation.hasStatementEvidence
                        ? materiality.basis
                        : null,
              ),
            ];

    return [
      FinancialReportComplianceItem(
        id: 'complete-set',
        title: 'Complete primary statement set',
        description:
            'Includes financial position, profit or loss and OCI, changes in equity, cash flows, and notes.',
        standardReference: 'PSAK 201',
        isSatisfied: FinancialReportStatementKind.values.every(
          (kind) => statements.any((statement) => statement.kind == kind),
        ),
      ),
      ...reconciliationChecks.map(
        (check) => FinancialReportComplianceItem(
          id: check.id,
          title: check.title,
          description: check.description,
          standardReference: check.standardReference,
          isSatisfied: check.isSatisfied(),
          variance: check.variance,
          comparativeVariance: check.comparativeVariance,
          materialityThreshold: materiality.threshold,
          materialityBasis: materiality.basis,
        ),
      ),
      FinancialReportComplianceItem(
        id: 'basis-notes',
        title: 'Basis and accounting policy notes',
        description:
            'Includes basis of preparation, accounting basis, cash flow, and equity notes.',
        standardReference: 'PSAK 201',
        isSatisfied: notes.length >= 4,
      ),
      FinancialReportComplianceItem(
        id: 'psak-118-subtotals',
        title: 'PSAK 118-ready subtotals',
        description:
            'Profit or loss presents operating profit, profit before financing and income tax, and profit before tax subtotals.',
        standardReference: 'PSAK 118',
        isSatisfied: true,
      ),
      FinancialReportComplianceItem(
        id: 'psak-118-uktm-disclosure',
        title: 'UKTM disclosure register',
        description:
            'Management performance measures are anchored to the PSAK 118 subtotal and flagged for approval before external release.',
        standardReference: 'PSAK 118 / UKTM',
        isSatisfied: true,
      ),
      FinancialReportComplianceItem(
        id: 'comparative-period',
        title: 'Comparative period data',
        description:
            'Comparative columns are populated from the prior comparable period.',
        standardReference: 'PSAK 201',
        isSatisfied: hasComparativePeriod && hasComparativeSourceData,
      ),
      FinancialReportComplianceItem(
        id: 'cash-roll-forward',
        title: 'Cash roll-forward ties to statement cash',
        description:
            'Opening cash plus cash movements ties to statement cash and cash equivalents, or remaining difference is below materiality.',
        standardReference: 'PSAK 207',
        isSatisfied: cashRollForwardIsSatisfied,
        variance: cashRollForwardVariance,
        comparativeVariance: comparativeCashRollForwardVariance,
        materialityThreshold:
            cashRollForwardSchedule == null ? null : materiality.threshold,
        materialityBasis:
            cashRollForwardSchedule == null ? null : materiality.basis,
      ),
      ...bankReconciliationCompliance,
      FinancialReportComplianceItem(
        id: 'tax-oci-detail',
        title: 'Tax and OCI source detail',
        description:
            'Income tax and OCI schedules are populated from ledger source lines when report data exists.',
        standardReference: 'PSAK 201',
        isSatisfied: hasTaxOrOciSchedule,
      ),
      FinancialReportComplianceItem(
        id: 'tax-reconciliation',
        title: 'Income tax reconciliation within materiality',
        description:
            'Recorded current and deferred tax expense reconciles to ${taxProfile.label} or remaining difference is below materiality.',
        standardReference: 'PSAK 212',
        isSatisfied: taxReconciliationIsSatisfied,
        variance: taxReconciliationVariance,
        comparativeVariance: comparativeTaxReconciliationVariance,
        materialityThreshold:
            taxReconciliationSchedule == null ? null : materiality.threshold,
        materialityBasis:
            taxReconciliationSchedule == null ? null : materiality.basis,
      ),
      FinancialReportComplianceItem(
        id: 'tax-settlement',
        title: 'Income tax settlement ties to payable',
        description:
            'Current tax expense less prepaid or withheld income tax credits ties to recorded income tax payable, or remaining difference is below materiality.',
        standardReference: 'PSAK 212',
        isSatisfied: taxSettlementIsSatisfied,
        variance: taxSettlementVariance,
        comparativeVariance: comparativeTaxSettlementVariance,
        materialityThreshold:
            taxSettlementSchedule == null ? null : materiality.threshold,
        materialityBasis:
            taxSettlementSchedule == null ? null : materiality.basis,
      ),
      FinancialReportComplianceItem(
        id: 'vat-settlement',
        title: 'VAT / PPN settlement ties out',
        description:
            'Input VAT, output VAT, and recorded net VAT payable or refund tie out, or remaining difference is below materiality.',
        standardReference: 'Indonesia VAT / PPN',
        isSatisfied: vatSettlementIsSatisfied,
        variance: vatSettlementVariance,
        comparativeVariance: comparativeVatSettlementVariance,
        materialityThreshold:
            vatSettlementSchedule == null ? null : materiality.threshold,
        materialityBasis:
            vatSettlementSchedule == null ? null : materiality.basis,
      ),
      FinancialReportComplianceItem(
        id: 'chart-mapping',
        title: 'Chart-to-report mapping',
        description:
            'Ledger accounts are classified into standardized report lines instead of raw account names.',
        standardReference: 'PSAK 201',
        isSatisfied:
            periodEntries.isEmpty ||
            periodEntries.every(lineMapper.hasExplicitMapping),
      ),
    ];
  }

  String _bankReconciliationComplianceDescription({
    required BankReconciliation reconciliation,
    required BankReconciliationControlSummary? controlSummary,
  }) {
    final base =
        reconciliation.hasStatementEvidence
            ? 'Bank statement movement ties to GL cash/bank movement with no unmatched items.'
            : 'Bank statement evidence has not been imported for the reporting period.';
    if (controlSummary == null || controlSummary.isReadyToClose) {
      return base;
    }
    return '$base Next action: ${controlSummary.nextAction}';
  }

  FinancialReportSupportingSchedule? _scheduleFor(
    List<FinancialReportSupportingSchedule> schedules,
    FinancialReportSupportingScheduleKind kind,
  ) {
    for (final schedule in schedules) {
      if (schedule.kind == kind) {
        return schedule;
      }
    }
    return null;
  }

  List<FinancialReportMetric> _buildMetrics(
    FinancialReportStatement position,
    FinancialReportStatement profitOrLoss,
    FinancialReportStatement cashFlows, {
    required bool hasComparativePeriod,
  }) {
    return [
      FinancialReportMetric(
        label: 'Total Assets',
        amount: _amountFor(position, 'Total assets'),
        comparativeAmount:
            hasComparativePeriod
                ? _comparativeAmountFor(position, 'Total assets')
                : null,
        helperText: 'Statement of financial position',
      ),
      FinancialReportMetric(
        label: 'Net Profit',
        amount: _amountFor(profitOrLoss, 'Profit (loss) for the period'),
        comparativeAmount:
            hasComparativePeriod
                ? _comparativeAmountFor(
                  profitOrLoss,
                  'Profit (loss) for the period',
                )
                : null,
        helperText: 'Current period performance',
      ),
      FinancialReportMetric(
        label: 'Ending Cash',
        amount: _amountFor(
          cashFlows,
          'Cash and cash equivalents at end of period',
        ),
        comparativeAmount:
            hasComparativePeriod
                ? _comparativeAmountFor(
                  cashFlows,
                  'Cash and cash equivalents at end of period',
                )
                : null,
        helperText: 'Cash flow reconciliation',
      ),
      FinancialReportMetric(
        label: 'Total Equity',
        amount: _amountFor(position, 'Total equity'),
        comparativeAmount:
            hasComparativePeriod
                ? _comparativeAmountFor(position, 'Total equity')
                : null,
        helperText: 'Residual interest after liabilities',
      ),
    ];
  }

  Iterable<FinancialReportLine> _categoryLines(
    Map<String, double> values,
    Map<String, double> comparativeValues,
  ) {
    if (values.isEmpty && comparativeValues.isEmpty) {
      return const [
        FinancialReportLine(
          label: 'No mapped ledger activity',
          amount: 0,
          indentLevel: 1,
        ),
      ];
    }

    final labels = {...values.keys, ...comparativeValues.keys}.toList()..sort();
    return labels.map(
      (label) => FinancialReportLine(
        label: label,
        amount: values[label] ?? 0,
        comparativeAmount: comparativeValues[label] ?? 0,
        indentLevel: 1,
      ),
    );
  }

  List<FinancialReportLine> _optionalCategoryGroup({
    required String title,
    required Map<String, double> categories,
    required Map<String, double> comparativeCategories,
    bool forceTotal = false,
  }) {
    if (categories.isEmpty && comparativeCategories.isEmpty && !forceTotal) {
      return const [];
    }

    return [
      FinancialReportLine(label: title, type: FinancialReportLineType.section),
      ..._categoryLines(categories, comparativeCategories),
      FinancialReportLine(
        label: 'Total $title',
        amount: _sumMap(categories),
        comparativeAmount: _sumMap(comparativeCategories),
        type: FinancialReportLineType.subtotal,
      ),
    ];
  }

  Map<String, double> _sumByReportLine(
    Iterable<FinancialEntry> entries,
    String type,
  ) {
    final values = <String, double>{};
    for (final entry in entries.where((entry) => entry.type == type)) {
      final label = lineMapper.lineLabelFor(entry);
      values[label] = (values[label] ?? 0) + entry.amount;
    }
    final sortedEntries =
        values.entries.toList()..sort((a, b) {
          final orderCompare = lineMapper
              .sortOrderForLabel(a.key)
              .compareTo(lineMapper.sortOrderForLabel(b.key));
          if (orderCompare != 0) {
            return orderCompare;
          }
          return a.key.compareTo(b.key);
        });
    return Map.fromEntries(sortedEntries);
  }

  double _sumMap(Map<String, double> values) {
    return values.values.fold(0.0, (sum, value) => sum + value);
  }

  double _sumWhere(
    Iterable<FinancialEntry> entries,
    bool Function(FinancialEntry entry) test,
  ) {
    return entries.where(test).fold(0.0, (sum, entry) => sum + entry.amount);
  }

  double _netAssets(Iterable<FinancialEntry> entries) {
    final assets = _sumWhere(entries, (entry) => entry.type == 'asset');
    final liabilities = _sumWhere(
      entries,
      (entry) => entry.type == 'liability',
    );
    return assets - liabilities;
  }

  double _amountFor(FinancialReportStatement statement, String label) {
    for (final line in statement.lines) {
      if (line.label == label) {
        return line.amount ?? 0.0;
      }
    }
    return 0.0;
  }

  double _comparativeAmountFor(
    FinancialReportStatement statement,
    String label,
  ) {
    for (final line in statement.lines) {
      if (line.label == label) {
        return line.comparativeAmount ?? 0.0;
      }
    }
    return 0.0;
  }

  _ComparativePeriod? _comparativePeriodFor(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return null;
    }
    final periodDays = end.difference(start).inDays + 1;
    final comparativeEnd = start.subtract(const Duration(days: 1));
    final comparativeStart = comparativeEnd.subtract(
      Duration(days: periodDays - 1),
    );
    return _ComparativePeriod(start: comparativeStart, end: comparativeEnd);
  }

  bool _isInsidePeriod(DateTime date, DateTime? start, DateTime? end) {
    final startsAfter = start == null || !date.isBefore(start);
    final endsBefore = end == null || !date.isAfter(end);
    return startsAfter && endsBefore;
  }

  bool _isCashEntry(FinancialEntry entry) {
    return cashRollForwardService.isCashEquivalent(entry, lineMapper);
  }

  double _cashFlowByBucket(
    List<FinancialEntry> cashEntries,
    _CashFlowBucket bucket,
  ) {
    return cashEntries
        .where((entry) => _cashFlowBucket(entry) == bucket)
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  _CashFlowBucket _cashFlowBucket(FinancialEntry entry) {
    switch (lineMapper.cashFlowGroupFor(entry)) {
      case FinancialReportCashFlowGroup.operating:
        return _CashFlowBucket.operating;
      case FinancialReportCashFlowGroup.investing:
        return _CashFlowBucket.investing;
      case FinancialReportCashFlowGroup.financing:
        return _CashFlowBucket.financing;
    }
  }

  String _metricAmount(double value) {
    final rounded = value.abs() < 0.01 ? 0.0 : value;
    if (rounded == rounded.truncateToDouble()) {
      return rounded.toStringAsFixed(0);
    }
    return rounded
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

enum _CashFlowBucket { operating, investing, financing }

class _ScheduleDetail {
  final double amount;
  final String? sourceCategory;

  const _ScheduleDetail({required this.amount, required this.sourceCategory});
}

class _ComparativePeriod {
  final DateTime start;
  final DateTime end;

  const _ComparativePeriod({required this.start, required this.end});

  String get label {
    final formatter = DateFormat('MMM d, yyyy');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  String get asOfLabel {
    return DateFormat('MMM d, yyyy').format(end);
  }
}
