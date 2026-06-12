import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_policy_profile.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_standard_transition.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_standard_transition_service.dart';

void main() {
  group('FinancialReportStandardTransitionService', () {
    const service = FinancialReportStandardTransitionService();

    test('monitors PSAK 118 transition work before the effective date', () {
      final summary = service.summarize(
        pack: _pack(),
        policy: AccountingPolicyProfiles.defaultProfile,
        asOf: DateTime(2026, 6, 1),
      );

      expect(summary.nextStandardReference, 'PSAK 118 / IFRS 18');
      expect(summary.daysUntilEffective, 214);
      expect(summary.readyCount, 6);
      expect(summary.monitorCount, 1);
      expect(summary.actionRequiredCount, 0);
      expect(summary.overdueCount, 0);
      expect(summary.headline, 'PSAK 118 transition is in monitoring.');
      expect(summary.nextAction, contains('PSAK 118 effective-date watch'));
      expect(
        summary.items.map((item) => item.status),
        contains(FinancialReportStandardTransitionStatus.monitor),
      );
    });

    test('escalates missing transition work close to the effective date', () {
      final summary = service.summarize(
        pack: _pack(
          hasComparatives: false,
          hasCashFlowBuckets: false,
          hasFinanceClassification: false,
          hasManagementPerformanceMeasureNote: false,
          hasPsak118Note: false,
        ),
        policy: AccountingPolicyProfiles.defaultProfile,
        asOf: DateTime(2026, 10, 1),
      );

      expect(summary.actionRequiredCount, greaterThan(0));
      expect(summary.hasBlockingTransitionRisk, isTrue);
      expect(
        summary.headline,
        'PSAK 118 transition needs implementation work.',
      );
      expect(summary.nextAction, contains('Cash flow presentation impact'));
    });

    test('marks non-general SAK frameworks outside transition scope', () {
      final summary = service.summarize(
        pack: _pack(),
        policy: AccountingPolicyProfiles.defaultProfile.copyWith(
          framework: AccountingPolicyFramework.sakEmkm,
        ),
        asOf: DateTime(2026, 6, 1),
      );

      expect(summary.notApplicableCount, 1);
      expect(summary.readinessRatio, 1);
      expect(
        summary.headline,
        'PSAK 118 transition is outside the selected framework scope.',
      );
    });
  });
}

FinancialReportPack _pack({
  bool hasComparatives = true,
  bool hasCashFlowBuckets = true,
  bool hasFinanceClassification = true,
  bool hasManagementPerformanceMeasureNote = true,
  bool hasPsak118Note = true,
}) {
  return FinancialReportPack(
    entityName: 'Kaysir Demo',
    frameworkName: 'SAK Indonesia / IFRS aligned',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'FY 2026',
    asOfLabel: 'Dec 31, 2026',
    comparativePeriodLabel: hasComparatives ? 'FY 2025' : null,
    comparativeAsOfLabel: hasComparatives ? 'Dec 31, 2025' : null,
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 12, 31),
    generatedAt: DateTime(2026, 12, 31, 18),
    statements: [
      FinancialReportStatement(
        kind: FinancialReportStatementKind.profitOrLossAndOci,
        title: 'Statement of Profit or Loss and OCI',
        subtitle: 'For FY 2026',
        standardReferences: const ['PSAK 201', 'PSAK 118 ready'],
        lines: [
          const FinancialReportLine(
            label: 'Operating expenses',
            type: FinancialReportLineType.section,
          ),
          if (hasFinanceClassification)
            const FinancialReportLine(
              label: 'Finance costs',
              type: FinancialReportLineType.section,
            ),
          FinancialReportLine(
            label: 'Operating profit (loss)',
            amount: 120,
            comparativeAmount: hasComparatives ? 100 : null,
          ),
          FinancialReportLine(
            label: 'Profit (loss) before financing and income tax',
            amount: 120,
            comparativeAmount: hasComparatives ? 100 : null,
          ),
          FinancialReportLine(
            label: 'Profit (loss) before tax',
            amount: 100,
            comparativeAmount: hasComparatives ? 90 : null,
          ),
        ],
      ),
      FinancialReportStatement(
        kind: FinancialReportStatementKind.cashFlows,
        title: 'Statement of Cash Flows',
        subtitle: 'For FY 2026',
        lines:
            hasCashFlowBuckets
                ? [
                  FinancialReportLine(
                    label: 'Net cash from operating activities',
                    amount: 300,
                    comparativeAmount: hasComparatives ? 250 : null,
                  ),
                  FinancialReportLine(
                    label: 'Net cash from investing activities',
                    amount: -80,
                    comparativeAmount: hasComparatives ? -60 : null,
                  ),
                  FinancialReportLine(
                    label: 'Net cash from financing activities',
                    amount: -20,
                    comparativeAmount: hasComparatives ? -30 : null,
                  ),
                ]
                : const [],
      ),
    ],
    notes: [
      if (hasPsak118Note)
        const FinancialReportDisclosureNote(
          number: '5',
          title: 'PSAK 118 readiness',
          body: 'Transition note prepared for presentation changes.',
          standardReferences: ['PSAK 118'],
        ),
      if (hasManagementPerformanceMeasureNote)
        const FinancialReportDisclosureNote(
          number: '6',
          title: 'UKTM / management performance measures',
          body: 'Management performance measure reconciled to PSAK 118.',
          standardReferences: ['PSAK 118', 'UKTM'],
        ),
    ],
    complianceItems: const [],
    metrics: const [],
  );
}
