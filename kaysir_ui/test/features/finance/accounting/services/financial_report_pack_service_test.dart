import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_control_summary.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/models/financial_entry.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_tax_profile.dart';
import 'package:kaysir/features/finance/accounting/models/ledger_trx.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_pack_service.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_reconciliation_service.dart';

void main() {
  group('FinancialReportPackService', () {
    const service = FinancialReportPackService();

    test('builds a complete SAK Indonesia statement pack', () {
      final pack = service.build(
        entries: _entries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 1, 2026 - Jan 31, 2026',
        asOfLabel: 'Jan 31, 2026',
        generatedAt: DateTime(2026, 2, 1, 9),
      );

      expect(pack.frameworkName, 'SAK Indonesia (IFRS-converged)');
      expect(pack.presentationCurrency, 'IDR');
      expect(pack.hasCompletePrimaryStatements, isTrue);
      expect(
        pack.statements.map((statement) => statement.kind),
        containsAll(FinancialReportStatementKind.values),
      );
      expect(
        pack.notes.expand((note) => note.standardReferences),
        contains('PSAK 118'),
      );
      expect(
        pack.notes.map((note) => note.title),
        contains('UKTM / management performance measures'),
      );
    });

    test('calculates profit or loss subtotals for PSAK 118 readiness', () {
      final pack = service.build(
        entries: _entries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final statement = pack.statementFor(
        FinancialReportStatementKind.profitOrLossAndOci,
      );

      expect(_amount(statement, 'Total revenue'), 5000);
      expect(_amount(statement, 'Total operating expenses'), 1200);
      expect(_amount(statement, 'Operating profit (loss)'), 3800);
      expect(
        _amount(statement, 'Profit (loss) before financing and income tax'),
        3800,
      );
      expect(_amount(statement, 'Profit (loss) before tax'), 3700);
      expect(_amount(statement, 'Profit (loss) for the period'), 3400);
      expect(_amount(statement, 'Total comprehensive income'), 3400);
    });

    test(
      'adds UKTM management performance measure reconciliation evidence',
      () {
        final pack = service.build(
          entries: _entries(),
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
          periodLabel: 'Jan 2026',
          asOfLabel: 'Jan 31, 2026',
        );
        final schedule = _schedule(
          pack,
          FinancialReportSupportingScheduleKind.managementPerformanceMeasure,
        );

        expect(schedule.title, 'UKTM Reconciliation');
        expect(schedule.standardReferences, contains('PSAK 118'));
        expect(schedule.standardReferences, contains('UKTM'));
        expect(_scheduleMetric(schedule, 'Management measures'), '1');
        expect(
          _scheduleMetric(schedule, 'Closest SAK subtotal'),
          'Before financing and tax',
        );
        expect(_scheduleMetric(schedule, 'Approval status'), 'Draft');
        expect(
          _scheduleAmount(schedule, 'UKTM: management operating performance'),
          3800,
        );
        expect(
          _scheduleAmount(
            schedule,
            'Less: Profit (loss) before financing and income tax',
          ),
          -3800,
        );
        expect(
          _scheduleAmount(schedule, 'Reconciling management adjustments'),
          0,
        );
        expect(schedule.lines.map((line) => line.noteReference).toSet(), {'6'});
        expect(schedule.totalAmount, 0);
      },
    );

    test(
      'uses registered UKTM measures and adjustments in report schedules',
      () {
        final pack = service.build(
          entries: _entries(),
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
          periodLabel: 'Jan 2026',
          asOfLabel: 'Jan 31, 2026',
          managementMeasures: const [
            FinancialReportManagementMeasure(
              id: 'uktm-adjusted-operating-performance',
              label: 'adjusted operating performance',
              owner: 'CFO',
              amountOverride: 4000,
              approvalStatus:
                  FinancialReportManagementMeasureApprovalStatus.approved,
              adjustments: [
                FinancialReportManagementMeasureAdjustment(
                  label: 'Non-recurring setup cost',
                  amount: 200,
                  sourceReference: 'Management adjustment register',
                ),
              ],
            ),
          ],
        );
        final schedule = _schedule(
          pack,
          FinancialReportSupportingScheduleKind.managementPerformanceMeasure,
        );

        expect(_scheduleMetric(schedule, 'Management measures'), '1');
        expect(_scheduleMetric(schedule, 'Approval status'), 'Approved');
        expect(_scheduleMetric(schedule, 'Open variances'), '0');
        expect(
          _scheduleAmount(schedule, 'UKTM: adjusted operating performance'),
          4000,
        );
        expect(
          _scheduleAmount(
            schedule,
            'Less: Profit (loss) before financing and income tax',
          ),
          -3800,
        );
        expect(
          _scheduleAmount(schedule, 'Adjustment: Non-recurring setup cost'),
          -200,
        );
        expect(schedule.totalAmount, 0);
      },
    );

    test('reconciles financial position and cash flow statements', () {
      final pack = service.build(
        entries: _entries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final position = pack.statementFor(
        FinancialReportStatementKind.financialPosition,
      );
      final cashFlow = pack.statementFor(
        FinancialReportStatementKind.cashFlows,
      );

      expect(_amount(position, 'Total assets'), 4400);
      expect(_amount(position, 'Total liabilities'), 600);
      expect(_amount(position, 'Total equity'), 3800);
      expect(_amount(position, 'Total liabilities and equity'), 4400);
      expect(
        _amount(
          cashFlow,
          'Net increase (decrease) in cash and cash equivalents',
        ),
        3400,
      );
      expect(
        _amount(cashFlow, 'Cash and cash equivalents at beginning of period'),
        1000,
      );
      expect(
        _amount(cashFlow, 'Cash and cash equivalents at end of period'),
        4400,
      );
      expect(_compliance(pack, 'position-equation').isSatisfied, isTrue);
      expect(_compliance(pack, 'position-equation').variance, 0);
      expect(_compliance(pack, 'cash-reconciliation').isSatisfied, isTrue);
      expect(_compliance(pack, 'equity-roll-forward').isSatisfied, isTrue);
      expect(
        _compliance(pack, 'comprehensive-income-tie-out').isSatisfied,
        isTrue,
      );
      expect(
        pack.complianceItems
            .where((item) => item.id != 'tax-reconciliation')
            .every((item) => item.isSatisfied),
        isTrue,
      );
      expect(_compliance(pack, 'tax-reconciliation').isSatisfied, isFalse);
      expect(_compliance(pack, 'tax-reconciliation').variance, -514);
      expect(
        _compliance(pack, 'tax-reconciliation').isMaterialVariance,
        isTrue,
      );
    });

    test(
      'includes bank accounts in cash flow and cash roll-forward evidence',
      () {
        final pack = service.build(
          entries: _bankEntries(),
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
          periodLabel: 'Jan 2026',
          asOfLabel: 'Jan 31, 2026',
        );
        final position = pack.statementFor(
          FinancialReportStatementKind.financialPosition,
        );
        final cashFlow = pack.statementFor(
          FinancialReportStatementKind.cashFlows,
        );
        final cashRollForward = _schedule(
          pack,
          FinancialReportSupportingScheduleKind.cashRollForward,
        );

        expect(_amount(position, 'Cash and cash equivalents'), 1500);
        expect(
          _amount(cashFlow, 'Cash and cash equivalents at beginning of period'),
          1000,
        );
        expect(
          _amount(
            cashFlow,
            'Net increase (decrease) in cash and cash equivalents',
          ),
          500,
        );
        expect(
          _amount(cashFlow, 'Cash and cash equivalents at end of period'),
          1500,
        );
        expect(_scheduleMetric(cashRollForward, 'Cash accounts'), '1');
        expect(_scheduleMetric(cashRollForward, 'Cash movement lines'), '1');
        expect(
          _scheduleAmount(cashRollForward, 'Opening cash and cash equivalents'),
          1000,
        );
        expect(_scheduleAmount(cashRollForward, 'Cash inflows'), 500);
        expect(
          _scheduleAmount(cashRollForward, 'Calculated ending cash'),
          1500,
        );
        expect(
          _scheduleAmount(
            cashRollForward,
            'Statement ending cash and cash equivalents',
          ),
          1500,
        );
        expect(cashRollForward.totalAmount, 0);
        expect(_compliance(pack, 'cash-roll-forward').isSatisfied, isTrue);
      },
    );

    test('adds balanced bank reconciliation evidence to the report pack', () {
      final pack = service.build(
        entries: _bankEntries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
        bankReconciliation: _balancedBankReconciliation(),
        bankReconciliationControlSummary: _balancedBankControlSummary(),
      );
      final schedule = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.bankReconciliation,
      );
      final compliance = _compliance(pack, 'bank-reconciliation');

      expect(schedule.standardReferences, contains('PSAK 207'));
      expect(_scheduleMetric(schedule, 'Statement lines'), '1');
      expect(_scheduleMetric(schedule, 'Matched lines'), '1');
      expect(_scheduleMetric(schedule, 'Unmatched items'), '0');
      expect(_scheduleMetric(schedule, 'Status'), 'Balanced');
      expect(
        _scheduleMetric(schedule, 'Next action'),
        'Bank statement evidence is matched and ready for close.',
      );
      expect(_scheduleMetric(schedule, 'Suggested journals'), '0');
      expect(_scheduleMetric(schedule, 'Timing differences'), '0');
      expect(_scheduleMetric(schedule, 'Timing aging'), 'No timing items');
      expect(
        _scheduleMetric(schedule, 'Timing exposure'),
        'No timing exposure',
      );
      expect(_scheduleMetric(schedule, 'Oldest open item'), 'N/A');
      expect(_scheduleMetric(schedule, 'Stale unmatched item'), 'No');
      expect(_scheduleAmount(schedule, 'Statement movement'), 1200);
      expect(_scheduleAmount(schedule, 'GL cash/bank movement'), 1200);
      expect(_scheduleAmount(schedule, 'Reconciliation variance'), 0);
      expect(schedule.totalAmount, 0);
      expect(compliance.isSatisfied, isTrue);
      expect(compliance.variance, 0);
    });

    test('flags unreconciled bank evidence as a report-pack blocker', () {
      final pack = service.build(
        entries: _bankEntries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
        bankReconciliation: _unreconciledBankReconciliation(),
        bankReconciliationControlSummary: _unreconciledBankControlSummary(),
      );
      final schedule = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.bankReconciliation,
      );
      final compliance = _compliance(pack, 'bank-reconciliation');

      expect(_scheduleMetric(schedule, 'Status'), 'Post adjustments');
      expect(
        _scheduleMetric(schedule, 'Next action'),
        contains('Post or review'),
      );
      expect(_scheduleMetric(schedule, 'Suggested journals'), '1');
      expect(_scheduleMetric(schedule, 'Oldest open item'), '26 days');
      expect(_scheduleMetric(schedule, 'Unmatched items'), '1');
      expect(_scheduleAmount(schedule, 'Reconciliation variance'), 1200);
      expect(schedule.totalAmount, 1200);
      expect(compliance.isSatisfied, isFalse);
      expect(compliance.variance, 1200);
      expect(compliance.hasMaterialityEvidence, isTrue);
      expect(compliance.description, contains('Next action: Post or review'));
    });

    test('adds timing exposure amounts to bank reconciliation evidence', () {
      final pack = service.build(
        entries: _bankEntries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
        bankReconciliation: _timingBankReconciliation(),
        bankReconciliationControlSummary: _timingBankControlSummary(),
        bankTimingRegister: _timingBankRegister(),
        bankTimingReviews: _timingBankReviews(),
      );
      final schedule = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.bankReconciliation,
      );

      expect(_scheduleMetric(schedule, 'Status'), 'Review timing');
      expect(_scheduleMetric(schedule, 'Timing differences'), '3');
      expect(
        _scheduleMetric(schedule, 'Timing aging'),
        'Current 1 / Watch 1 / Stale 1',
      );
      expect(
        _scheduleMetric(schedule, 'Timing exposure'),
        'Current 100 / Watch 200 / Stale 300',
      );
      expect(
        _scheduleMetric(schedule, 'Timing deadline risk'),
        '1 overdue / 1 due soon',
      );
      expect(
        _scheduleMetric(schedule, 'Timing review coverage'),
        '2/3 documented / 2/3 resolved',
      );
      expect(
        _scheduleMetric(schedule, 'Timing review action'),
        'Document 1 open review(s)',
      );
      expect(
        _scheduleMetric(schedule, 'Timing review gaps'),
        '1 unreviewed / 0 owner gaps / 0 overdue unresolved',
      );
      expect(
        _scheduleAmount(schedule, 'Timing PAY-002 - Outstanding payment'),
        -300,
      );
      expect(
        _scheduleSource(schedule, 'Timing PAY-002 - Outstanding payment'),
        'Stale timing difference / Escalate / Clear by Jan 29, 2026 / '
        'Overdue / Review Cleared / Owner Controller / Reviewed Jan 31, 2026 / '
        'Cleared on Feb bank statement.',
      );
      expect(
        _scheduleSource(schedule, 'Timing PAY-001 - Outstanding payment'),
        'Watch timing difference / Monitor / Clear by Feb 4, 2026 / '
        'Due soon (4d left) / Review Adjusted / Owner Accounting Lead / '
        'Reviewed Feb 1, 2026 / Posted bank fee adjustment.',
      );
      expect(
        _scheduleAmount(schedule, 'Timing DEP-001 - Deposit in transit'),
        100,
      );
    });

    test('uses standardized report lines instead of raw account labels', () {
      final pack = service.build(
        entries: _entries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final position = pack.statementFor(
        FinancialReportStatementKind.financialPosition,
      );
      final profitOrLoss = pack.statementFor(
        FinancialReportStatementKind.profitOrLossAndOci,
      );

      expect(_amount(position, 'Cash and cash equivalents'), 4400);
      expect(_amount(position, 'Trade and other payables'), 600);
      expect(_amount(position, 'Owner/share capital'), 500);
      expect(
        _amount(profitOrLoss, 'Revenue from contracts with customers'),
        5000,
      );
      expect(_amount(profitOrLoss, 'Occupancy expenses'), 1200);
      expect(
        _amount(profitOrLoss, 'Interest expense and finance charges'),
        100,
      );
      expect(_amount(profitOrLoss, 'Current tax expense'), 300);
    });

    test('adds prior-period comparative amounts across statements', () {
      final pack = service.build(
        entries: _entries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final position = pack.statementFor(
        FinancialReportStatementKind.financialPosition,
      );
      final profitOrLoss = pack.statementFor(
        FinancialReportStatementKind.profitOrLossAndOci,
      );
      final cashFlow = pack.statementFor(
        FinancialReportStatementKind.cashFlows,
      );

      expect(pack.hasComparativePeriod, isTrue);
      expect(pack.comparativePeriodLabel, 'Dec 1, 2025 - Dec 31, 2025');
      expect(pack.comparativeAsOfLabel, 'Dec 31, 2025');
      expect(_comparativeAmount(position, 'Total assets'), 1000);
      expect(_comparativeAmount(position, 'Total equity'), 1000);
      expect(_comparativeAmount(profitOrLoss, 'Total revenue'), 0);
      expect(
        _comparativeAmount(
          cashFlow,
          'Cash and cash equivalents at end of period',
        ),
        1000,
      );
      expect(
        pack.metrics
            .singleWhere((metric) => metric.label == 'Total Assets')
            .comparativeAmount,
        1000,
      );
    });

    test('separates detailed equity movements in the equity statement', () {
      final pack = service.build(
        entries: _equityMovementEntries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final equity = pack.statementFor(
        FinancialReportStatementKind.changesInEquity,
      );
      final profitOrLoss = pack.statementFor(
        FinancialReportStatementKind.profitOrLossAndOci,
      );
      final position = pack.statementFor(
        FinancialReportStatementKind.financialPosition,
      );

      expect(_amount(profitOrLoss, 'Other comprehensive income'), 75);
      expect(_amount(position, 'Other reserves and OCI'), 75);
      expect(_amount(equity, 'Opening equity'), 1000);
      expect(_amount(equity, 'Owner contributions'), 500);
      expect(_amount(equity, 'Owner distributions'), -100);
      expect(_amount(equity, 'Profit (loss) for the period'), 500);
      expect(_amount(equity, 'Other comprehensive income'), 75);
      expect(_amount(equity, 'Other equity movements / closing entries'), 225);
      expect(_amount(equity, 'Ending equity'), 2200);
      expect(_compliance(pack, 'equity-roll-forward').isSatisfied, isTrue);
      expect(
        _compliance(pack, 'comprehensive-income-tie-out').isSatisfied,
        isTrue,
      );
    });

    test('adds supporting schedules for income tax and OCI detail', () {
      final pack = service.build(
        entries: [
          ..._entries(),
          FinancialEntry(
            name: 'Deferred Tax Expense',
            amount: 80,
            date: DateTime(2026, 1, 22),
            category: '5901 - Deferred Tax Expense',
            type: 'expense',
            sourceCategory: 'Pajak tangguhan',
          ),
          FinancialEntry(
            name: 'OCI Revaluation Reserve',
            amount: 75,
            date: DateTime(2026, 1, 31),
            category: '3000 - OCI Reserve',
            type: 'equity',
            sourceCategory: 'Cadangan revaluasi',
          ),
        ],
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );

      final taxSchedule = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.incomeTax,
      );
      final ociSchedule = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.otherComprehensiveIncome,
      );
      final taxReconciliation = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.incomeTaxReconciliation,
      );

      expect(taxSchedule.standardReferences, contains('PSAK 212'));
      expect(_scheduleMetric(taxSchedule, 'Source lines'), '2');
      expect(_scheduleMetric(taxSchedule, 'Source categories'), '2');
      expect(_scheduleAmount(taxSchedule, 'Current tax expense'), 300);
      expect(
        _scheduleAmount(taxSchedule, 'Deferred tax expense (benefit)'),
        80,
      );
      expect(taxSchedule.totalAmount, 380);
      expect(
        _scheduleAmount(taxReconciliation, 'Profit (loss) before tax'),
        3700,
      );
      expect(
        _scheduleAmount(taxReconciliation, 'Expected tax expense at 22%'),
        closeTo(814, 0.001),
      );
      expect(
        _scheduleAmount(taxReconciliation, 'Recorded income tax expense'),
        380,
      );
      expect(_scheduleMetric(taxReconciliation, 'Effective tax rate'), '10.3%');
      expect(
        _scheduleMetric(taxReconciliation, 'Statutory benchmark'),
        '22.0%',
      );
      expect(_scheduleMetric(taxReconciliation, 'Tax source lines'), '2');
      expect(taxReconciliation.totalAmount, closeTo(-434, 0.001));
      expect(
        taxReconciliation.lines.map((line) => line.noteReference).toSet(),
        {'7'},
      );
      expect(_scheduleAmount(ociSchedule, 'Cadangan revaluasi'), 75);
      expect(_scheduleMetric(ociSchedule, 'Source lines'), '1');
      expect(_scheduleMetric(ociSchedule, 'Source categories'), '1');
      expect(ociSchedule.lines.map((line) => line.noteReference).toSet(), {
        '7',
      });
      expect(ociSchedule.totalAmount, 75);
      expect(_compliance(pack, 'tax-oci-detail').isSatisfied, isTrue);
      expect(
        pack.notes.singleWhere((note) => note.number == '7').body,
        contains('Supporting schedules are included'),
      );
    });

    test('uses the selected tax profile for tax reconciliation', () {
      const service = FinancialReportPackService(
        taxProfile: FinancialReportTaxProfiles.publicCompanyReduced,
      );

      final pack = service.build(
        entries: _entries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final taxReconciliation = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.incomeTaxReconciliation,
      );

      expect(pack.taxProfile, FinancialReportTaxProfiles.publicCompanyReduced);
      expect(
        _scheduleMetric(taxReconciliation, 'Statutory benchmark'),
        '19.0%',
      );
      expect(
        _scheduleMetric(taxReconciliation, 'Benchmark profile'),
        'Listed 19%',
      );
      expect(
        _scheduleAmount(taxReconciliation, 'Expected tax expense at 19%'),
        closeTo(703, 0.001),
      );
      expect(taxReconciliation.totalAmount, closeTo(-403, 0.001));
      expect(
        _compliance(pack, 'tax-reconciliation').variance,
        closeTo(-403, 0.001),
      );
    });

    test('adds Article 31E proportional facility evidence', () {
      const service = FinancialReportPackService(
        taxProfile: FinancialReportTaxProfiles.smallBusinessFacility,
      );

      final pack = service.build(
        entries: _article31eEntries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 12, 31),
        periodLabel: 'FY 2026',
        asOfLabel: 'Dec 31, 2026',
      );
      final taxReconciliation = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.incomeTaxReconciliation,
      );

      expect(
        _scheduleMetric(taxReconciliation, 'Statutory benchmark'),
        '16.7%',
      );
      expect(
        _scheduleMetric(taxReconciliation, 'Benchmark profile'),
        'Eligible 11%',
      );
      expect(
        _scheduleAmount(
          taxReconciliation,
          'Gross turnover for Article 31E test',
        ),
        10000000000,
      );
      expect(
        _scheduleAmount(
          taxReconciliation,
          'Article 31E eligible taxable income',
        ),
        closeTo(480000000, 0.001),
      );
      expect(
        _scheduleAmount(
          taxReconciliation,
          'Tax at Article 31E discounted rate',
        ),
        closeTo(52800000, 0.001),
      );
      expect(
        _scheduleAmount(
          taxReconciliation,
          'Tax at standard rate after facility',
        ),
        closeTo(114400000, 0.001),
      );
      expect(
        _scheduleAmount(
          taxReconciliation,
          'Expected tax expense at 16.7% blended',
        ),
        closeTo(167200000, 0.001),
      );
      expect(taxReconciliation.totalAmount, closeTo(-17200000, 0.001));
      expect(
        _compliance(pack, 'tax-reconciliation').variance,
        closeTo(-17200000, 0.001),
      );
    });

    test('adds income tax settlement schedule and compliance evidence', () {
      final pack = service.build(
        entries: _taxSettlementEntries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final settlement = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.incomeTaxSettlement,
      );

      expect(settlement.standardReferences, contains('PSAK 212'));
      expect(_scheduleMetric(settlement, 'Tax credit lines'), '1');
      expect(_scheduleMetric(settlement, 'Tax payable lines'), '1');
      expect(_scheduleAmount(settlement, 'Current tax expense'), 814);
      expect(
        _scheduleAmount(settlement, 'Less: tax credits and prepayments'),
        -200,
      );
      expect(
        _scheduleAmount(settlement, 'Expected income tax payable (receivable)'),
        614,
      );
      expect(_scheduleAmount(settlement, 'Recorded income tax payable'), 614);
      expect(settlement.totalAmount, 0);
      expect(_compliance(pack, 'tax-settlement').isSatisfied, isTrue);
    });

    test('flags material income tax settlement variances', () {
      final pack = service.build(
        entries: _taxSettlementEntries(payableAmount: 500),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final settlement = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.incomeTaxSettlement,
      );
      final compliance = _compliance(pack, 'tax-settlement');

      expect(settlement.totalAmount, -114);
      expect(compliance.isSatisfied, isFalse);
      expect(compliance.variance, -114);
      expect(compliance.isMaterialVariance, isTrue);
    });

    test('adds VAT / PPN settlement schedule and compliance evidence', () {
      final pack = service.build(
        entries: _vatSettlementEntries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final settlement = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.valueAddedTaxSettlement,
      );

      expect(settlement.standardReferences, contains('Indonesia VAT / PPN'));
      expect(_scheduleMetric(settlement, 'Input VAT lines'), '1');
      expect(_scheduleMetric(settlement, 'Output VAT lines'), '1');
      expect(_scheduleMetric(settlement, 'Settlement lines'), '1');
      expect(_scheduleAmount(settlement, 'Output VAT collected'), 330);
      expect(_scheduleAmount(settlement, 'Less: input VAT credit'), -110);
      expect(
        _scheduleAmount(settlement, 'Expected net VAT payable (refund)'),
        220,
      );
      expect(
        _scheduleAmount(settlement, 'Recorded net VAT payable (refund)'),
        220,
      );
      expect(settlement.totalAmount, 0);
      expect(_compliance(pack, 'vat-settlement').isSatisfied, isTrue);
    });

    test('flags material VAT / PPN settlement variances', () {
      final pack = service.build(
        entries: _vatSettlementEntries(vatPayableAmount: 100),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final settlement = _schedule(
        pack,
        FinancialReportSupportingScheduleKind.valueAddedTaxSettlement,
      );
      final compliance = _compliance(pack, 'vat-settlement');

      expect(settlement.totalAmount, -120);
      expect(compliance.isSatisfied, isFalse);
      expect(compliance.variance, -120);
      expect(compliance.isMaterialVariance, isTrue);
    });

    test('carries reconciliation variances into compliance evidence', () {
      const service = FinancialReportPackService(
        reconciliationService: _VarianceReconciliationService(),
      );

      final pack = service.build(
        entries: _entries(),
        periodStart: DateTime(2026, 1, 1),
        periodEnd: DateTime(2026, 1, 31),
        periodLabel: 'Jan 2026',
        asOfLabel: 'Jan 31, 2026',
      );
      final item = _compliance(pack, 'equity-roll-forward');

      expect(item.isSatisfied, isFalse);
      expect(item.variance, 125);
      expect(item.comparativeVariance, -10);
      expect(item.hasVarianceEvidence, isTrue);
      expect(item.materialityThreshold, 44);
      expect(item.materialityBasis, '1% of total assets');
      expect(item.isMaterialVariance, isTrue);
    });

    test('omits comparative metadata when the report period is unbounded', () {
      final pack = service.build(
        entries: _entries(),
        periodLabel: 'All periods',
        asOfLabel: 'latest available period',
      );

      expect(pack.hasComparativePeriod, isFalse);
      expect(pack.comparativePeriodLabel, isNull);
      expect(
        pack.metrics.map((metric) => metric.comparativeAmount),
        everyElement(isNull),
      );
    });
  });
}

List<FinancialEntry> _entries() {
  return [
    FinancialEntry(
      name: 'Cash',
      amount: 1000,
      date: DateTime(2025, 12, 31),
      category: '1000 - Cash',
      type: 'asset',
      sourceCategory: 'Opening balance',
    ),
    FinancialEntry(
      name: 'Owner Capital',
      amount: 500,
      date: DateTime(2026, 1, 1),
      category: '3000 - Owner Capital',
      type: 'equity',
      sourceCategory: 'Modal disetor',
    ),
    FinancialEntry(
      name: 'Sales Revenue',
      amount: 5000,
      date: DateTime(2026, 1, 15),
      category: '4000 - Sales Revenue',
      type: 'income',
      sourceCategory: 'Sales invoice',
    ),
    FinancialEntry(
      name: 'Rent Expense',
      amount: 1200,
      date: DateTime(2026, 1, 16),
      category: '5000 - Rent Expense',
      type: 'expense',
      sourceCategory: 'Operating expense',
    ),
    FinancialEntry(
      name: 'Interest Expense',
      amount: 100,
      date: DateTime(2026, 1, 18),
      category: '5100 - Interest Expense',
      type: 'expense',
      sourceCategory: 'Finance cost',
    ),
    FinancialEntry(
      name: 'Income Tax Expense',
      amount: 300,
      date: DateTime(2026, 1, 20),
      category: '5200 - Income Tax Expense',
      type: 'expense',
      sourceCategory: 'Pajak penghasilan',
    ),
    FinancialEntry(
      name: 'Accounts Payable',
      amount: 600,
      date: DateTime(2026, 1, 25),
      category: '2000 - Accounts Payable',
      type: 'liability',
      sourceCategory: 'Vendor accrual',
    ),
    FinancialEntry(
      name: 'Cash',
      amount: 3400,
      date: DateTime(2026, 1, 31),
      category: '1000 - Cash',
      type: 'asset',
      sourceCategory: 'Operating collection',
    ),
  ];
}

List<FinancialEntry> _equityMovementEntries() {
  return [
    FinancialEntry(
      name: 'Cash',
      amount: 1000,
      date: DateTime(2025, 12, 31),
      category: '1000 - Cash',
      type: 'asset',
      sourceCategory: 'Opening balance',
    ),
    FinancialEntry(
      name: 'Cash',
      amount: 1200,
      date: DateTime(2026, 1, 31),
      category: '1000 - Cash',
      type: 'asset',
      sourceCategory: 'Operating collection',
    ),
    FinancialEntry(
      name: 'Owner Capital',
      amount: 500,
      date: DateTime(2026, 1, 1),
      category: '3000 - Owner Capital',
      type: 'equity',
      sourceCategory: 'Modal disetor',
    ),
    FinancialEntry(
      name: 'Owner Drawings',
      amount: -100,
      date: DateTime(2026, 1, 15),
      category: '3001 - Owner Drawings',
      type: 'equity',
      sourceCategory: 'Prive',
    ),
    FinancialEntry(
      name: 'Sales Revenue',
      amount: 800,
      date: DateTime(2026, 1, 20),
      category: '4000 - Sales Revenue',
      type: 'income',
    ),
    FinancialEntry(
      name: 'Operating Expense',
      amount: 300,
      date: DateTime(2026, 1, 21),
      category: '5000 - Rent Expense',
      type: 'expense',
    ),
    FinancialEntry(
      name: 'OCI Revaluation Reserve',
      amount: 75,
      date: DateTime(2026, 1, 31),
      category: '3000 - OCI Reserve',
      type: 'equity',
      sourceCategory: 'Other comprehensive income',
    ),
  ];
}

List<FinancialEntry> _bankEntries() {
  return [
    FinancialEntry(
      name: 'Bank BCA',
      amount: 1000,
      date: DateTime(2025, 12, 31),
      category: '1001 - Bank BCA',
      type: 'asset',
      sourceCategory: 'Opening bank balance',
    ),
    FinancialEntry(
      name: 'Sales Revenue',
      amount: 500,
      date: DateTime(2026, 1, 15),
      category: '4000 - Sales Revenue',
      type: 'income',
      sourceCategory: 'Sales invoice',
    ),
    FinancialEntry(
      name: 'Bank BCA',
      amount: 500,
      date: DateTime(2026, 1, 15),
      category: '1001 - Bank BCA',
      type: 'asset',
      sourceCategory: 'Customer collection',
    ),
  ];
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

BankReconciliationControlSummary _balancedBankControlSummary() {
  return const BankReconciliationControlSummary(
    severity: BankReconciliationControlSeverity.ready,
    nextAction: 'Bank statement evidence is matched and ready for close.',
    statementLineCount: 1,
    matchedCount: 1,
    unmatchedStatementCount: 0,
    unmatchedLedgerCount: 0,
    suggestedJournalCount: 0,
    timingDifferenceCount: 0,
    staleThresholdDays: 30,
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

BankReconciliationControlSummary _unreconciledBankControlSummary() {
  return BankReconciliationControlSummary(
    severity: BankReconciliationControlSeverity.postAdjustments,
    nextAction: 'Post or review 1 suggested bank adjustment journal(s).',
    statementLineCount: 1,
    matchedCount: 0,
    unmatchedStatementCount: 1,
    unmatchedLedgerCount: 0,
    suggestedJournalCount: 1,
    timingDifferenceCount: 0,
    staleThresholdDays: 30,
    oldestUnmatchedAgeDays: 26,
    oldestUnmatchedDate: DateTime(2026, 1, 5),
    oldestUnmatchedReference: 'INV-001',
  );
}

BankReconciliation _timingBankReconciliation() {
  final statementLine = _statementLine();
  final matchedLedger = _ledgerLine();
  final currentDeposit = BankLedgerReconciliationLine(
    transactionId: 'dep-1',
    date: DateTime(2026, 1, 29),
    account: '1001 - Bank BCA',
    description: 'Deposit in transit',
    reference: 'DEP-001',
    type: TransactionType.debit,
    amount: 100,
  );
  final watchPayment = BankLedgerReconciliationLine(
    transactionId: 'pay-1',
    date: DateTime(2026, 1, 5),
    account: '1001 - Bank BCA',
    description: 'Outstanding payment',
    reference: 'PAY-001',
    type: TransactionType.credit,
    amount: 200,
  );
  final stalePayment = BankLedgerReconciliationLine(
    transactionId: 'pay-2',
    date: DateTime(2025, 12, 30),
    account: '1001 - Bank BCA',
    description: 'Stale outstanding payment',
    reference: 'PAY-002',
    type: TransactionType.credit,
    amount: 300,
  );

  return BankReconciliation(
    statementLines: [statementLine],
    ledgerLines: [matchedLedger, currentDeposit, watchPayment, stalePayment],
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
}

BankReconciliationControlSummary _timingBankControlSummary() {
  return BankReconciliationControlSummary(
    severity: BankReconciliationControlSeverity.timingReview,
    nextAction: 'Confirm 3 timing difference(s) clear on a later statement.',
    statementLineCount: 1,
    matchedCount: 1,
    unmatchedStatementCount: 0,
    unmatchedLedgerCount: 3,
    suggestedJournalCount: 0,
    timingDifferenceCount: 3,
    staleThresholdDays: 30,
    timingAging: const BankReconciliationTimingAgingSummary(
      currentCount: 1,
      watchCount: 1,
      staleCount: 1,
      currentAmount: 100,
      watchAmount: 200,
      staleAmount: 300,
    ),
    oldestUnmatchedAgeDays: 32,
    oldestUnmatchedDate: DateTime(2025, 12, 30),
    oldestUnmatchedReference: 'PAY-002',
  );
}

List<BankReconciliationTimingRegisterItem> _timingBankRegister() {
  return [
    BankReconciliationTimingRegisterItem(
      reference: 'PAY-002',
      date: DateTime(2025, 12, 30),
      description: 'Stale outstanding payment',
      amount: -300,
      ageDays: 32,
      clearByDate: DateTime(2026, 1, 29),
      bucket: BankReconciliationTimingBucket.stale,
      type: BankReconciliationResolutionType.outstandingPayment,
      clearanceStatus: BankReconciliationTimingClearanceStatus.escalate,
      suggestedAction:
          'Confirm the payment clears on a later bank statement or investigate stale items.',
    ),
    BankReconciliationTimingRegisterItem(
      reference: 'PAY-001',
      date: DateTime(2026, 1, 5),
      description: 'Outstanding payment',
      amount: -200,
      ageDays: 26,
      clearByDate: DateTime(2026, 2, 4),
      bucket: BankReconciliationTimingBucket.watch,
      type: BankReconciliationResolutionType.outstandingPayment,
      clearanceStatus: BankReconciliationTimingClearanceStatus.monitor,
      suggestedAction:
          'Confirm the payment clears on a later bank statement or investigate stale items.',
    ),
    BankReconciliationTimingRegisterItem(
      reference: 'DEP-001',
      date: DateTime(2026, 1, 29),
      description: 'Deposit in transit',
      amount: 100,
      ageDays: 2,
      clearByDate: DateTime(2026, 2, 28),
      bucket: BankReconciliationTimingBucket.current,
      type: BankReconciliationResolutionType.depositInTransit,
      clearanceStatus: BankReconciliationTimingClearanceStatus.open,
      suggestedAction:
          'Confirm the receipt clears on a later bank statement before closing.',
    ),
  ];
}

Map<String, BankReconciliationTimingReview> _timingBankReviews() {
  return {
    'PAY-002': BankReconciliationTimingReview(
      reference: 'PAY-002',
      status: BankReconciliationTimingReviewStatus.cleared,
      owner: 'Controller',
      note: 'Cleared on Feb bank statement.',
      reviewedAt: DateTime(2026, 1, 31, 16),
    ),
    'PAY-001': BankReconciliationTimingReview(
      reference: 'PAY-001',
      status: BankReconciliationTimingReviewStatus.adjusted,
      owner: 'Accounting Lead',
      note: 'Posted bank fee adjustment.',
      reviewedAt: DateTime(2026, 2, 1, 9),
    ),
  };
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
    account: '1001 - Bank BCA',
    description: 'Customer transfer INV-001',
    reference: 'INV-001',
    type: TransactionType.debit,
    amount: 1200,
  );
}

List<FinancialEntry> _article31eEntries() {
  return [
    FinancialEntry(
      name: 'Sales Revenue',
      amount: 10000000000,
      date: DateTime(2026, 6, 30),
      category: '4000 - Sales Revenue',
      type: 'income',
      sourceCategory: 'Gross turnover',
    ),
    FinancialEntry(
      name: 'Operating Expense',
      amount: 9000000000,
      date: DateTime(2026, 6, 30),
      category: '5000 - Operating Expense',
      type: 'expense',
      sourceCategory: 'Operating expense',
    ),
    FinancialEntry(
      name: 'Income Tax Expense',
      amount: 150000000,
      date: DateTime(2026, 12, 31),
      category: '5200 - Income Tax Expense',
      type: 'expense',
      sourceCategory: 'Pajak penghasilan',
    ),
    FinancialEntry(
      name: 'Cash',
      amount: 850000000,
      date: DateTime(2026, 12, 31),
      category: '1000 - Cash',
      type: 'asset',
      sourceCategory: 'Closing cash',
    ),
  ];
}

List<FinancialEntry> _taxSettlementEntries({double payableAmount = 614}) {
  return [
    FinancialEntry(
      name: 'Sales Revenue',
      amount: 5000,
      date: DateTime(2026, 1, 15),
      category: '4000 - Sales Revenue',
      type: 'income',
      sourceCategory: 'Sales invoice',
    ),
    FinancialEntry(
      name: 'Rent Expense',
      amount: 1200,
      date: DateTime(2026, 1, 16),
      category: '5000 - Rent Expense',
      type: 'expense',
      sourceCategory: 'Operating expense',
    ),
    FinancialEntry(
      name: 'Interest Expense',
      amount: 100,
      date: DateTime(2026, 1, 18),
      category: '5100 - Interest Expense',
      type: 'expense',
      sourceCategory: 'Finance cost',
    ),
    FinancialEntry(
      name: 'Income Tax Expense',
      amount: 814,
      date: DateTime(2026, 1, 20),
      category: '5900 - Income Tax Expense',
      type: 'expense',
      sourceCategory: 'Pajak penghasilan',
    ),
    FinancialEntry(
      name: 'PPh 23 Withholding Credit',
      amount: 200,
      date: DateTime(2026, 1, 31),
      category: '1350 - Kredit Pajak',
      type: 'asset',
      sourceCategory: 'Bukti potong PPh 23',
    ),
    FinancialEntry(
      name: 'Income Tax Payable',
      amount: payableAmount,
      date: DateTime(2026, 1, 31),
      category: '2400 - Income Tax Payable',
      type: 'liability',
      sourceCategory: 'PPh 29 payable',
    ),
  ];
}

List<FinancialEntry> _vatSettlementEntries({double vatPayableAmount = 220}) {
  return [
    FinancialEntry(
      name: 'Sales Revenue',
      amount: 5000,
      date: DateTime(2026, 1, 15),
      category: '4000 - Sales Revenue',
      type: 'income',
      sourceCategory: 'Sales invoice',
    ),
    FinancialEntry(
      name: 'Rent Expense',
      amount: 1200,
      date: DateTime(2026, 1, 16),
      category: '5000 - Rent Expense',
      type: 'expense',
      sourceCategory: 'Operating expense',
    ),
    FinancialEntry(
      name: 'Income Tax Expense',
      amount: 836,
      date: DateTime(2026, 1, 20),
      category: '5900 - Income Tax Expense',
      type: 'expense',
      sourceCategory: 'Pajak penghasilan',
    ),
    FinancialEntry(
      name: 'Input VAT',
      amount: 110,
      date: DateTime(2026, 1, 31),
      category: '1300 - PPN Masukan',
      type: 'asset',
      sourceCategory: 'PPN masukan',
    ),
    FinancialEntry(
      name: 'Output VAT',
      amount: 330,
      date: DateTime(2026, 1, 31),
      category: '2400 - PPN Keluaran',
      type: 'liability',
      sourceCategory: 'PPN keluaran',
    ),
    FinancialEntry(
      name: 'VAT Payable',
      amount: vatPayableAmount,
      date: DateTime(2026, 1, 31),
      category: '2410 - VAT Payable',
      type: 'liability',
      sourceCategory: 'VAT settlement',
    ),
  ];
}

double _amount(FinancialReportStatement statement, String label) {
  return statement.lines.where((line) => line.label == label).single.amount ??
      0;
}

double _comparativeAmount(FinancialReportStatement statement, String label) {
  return statement.lines
          .where((line) => line.label == label)
          .single
          .comparativeAmount ??
      0;
}

FinancialReportComplianceItem _compliance(FinancialReportPack pack, String id) {
  return pack.complianceItems.where((item) => item.id == id).single;
}

FinancialReportSupportingSchedule _schedule(
  FinancialReportPack pack,
  FinancialReportSupportingScheduleKind kind,
) {
  return pack.supportingSchedules
      .where((schedule) => schedule.kind == kind)
      .single;
}

double _scheduleAmount(
  FinancialReportSupportingSchedule schedule,
  String label,
) {
  return schedule.lines.where((line) => line.label == label).single.amount;
}

String _scheduleMetric(
  FinancialReportSupportingSchedule schedule,
  String label,
) {
  return schedule.metrics.where((metric) => metric.label == label).single.value;
}

String _scheduleSource(
  FinancialReportSupportingSchedule schedule,
  String label,
) {
  return schedule.lines
      .where((line) => line.label == label)
      .single
      .sourceCategory!;
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
    return const [
      FinancialReportReconciliationCheck(
        id: 'equity-roll-forward',
        title: 'Equity roll-forward reconciles',
        description:
            'Opening equity plus current-period equity movements equals ending equity.',
        standardReference: 'PSAK 201',
        variance: 125,
        comparativeVariance: -10,
      ),
    ];
  }
}
