import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_management_measure_service.dart';

void main() {
  group('FinancialReportManagementMeasureService', () {
    const service = FinancialReportManagementMeasureService();

    test(
      'creates a default operating performance measure when register is empty',
      () {
        final reconciliations = service.reconcileAll(
          profitOrLoss: _profitOrLoss(),
          measures: const [],
        );

        expect(reconciliations, hasLength(1));
        expect(
          reconciliations.single.measure.label,
          'management operating performance',
        );
        expect(reconciliations.single.measureAmount, 3800);
        expect(reconciliations.single.variance, 0);
        expect(reconciliations.single.isBalanced, isTrue);
      },
    );

    test(
      'reconciles custom UKTM measures against subtotal and adjustments',
      () {
        final reconciliation = service.reconcile(
          profitOrLoss: _profitOrLoss(),
          measure: const FinancialReportManagementMeasure(
            id: 'uktm-adjusted-operating-performance',
            label: 'adjusted operating performance',
            owner: 'CFO',
            amountOverride: 4000,
            comparativeAmountOverride: 2500,
            approvalStatus:
                FinancialReportManagementMeasureApprovalStatus.approved,
            adjustments: [
              FinancialReportManagementMeasureAdjustment(
                label: 'Non-recurring setup cost',
                amount: 200,
                comparativeAmount: 100,
                sourceReference: 'Management adjustment register',
              ),
            ],
          ),
        );

        expect(reconciliation.subtotalAmount, 3800);
        expect(reconciliation.measureAmount, 4000);
        expect(reconciliation.adjustmentTotal, 200);
        expect(reconciliation.variance, 0);
        expect(reconciliation.comparativeVariance, 0);
        expect(reconciliation.isApproved, isTrue);
      },
    );

    test('summarizes UKTM release readiness gates', () {
      final draft = service.reconcile(
        profitOrLoss: _profitOrLoss(),
        measure:
            const FinancialReportManagementMeasure.defaultOperatingPerformance(),
      );
      final variance = service.reconcile(
        profitOrLoss: _profitOrLoss(),
        measure: const FinancialReportManagementMeasure(
          id: 'uktm-variance',
          label: 'adjusted operating performance',
          owner: 'Controller',
          amountOverride: 4100,
          approvalStatus:
              FinancialReportManagementMeasureApprovalStatus.approved,
        ),
      );

      expect(service.releaseReady([draft]), isFalse);
      expect(
        service.releaseLockedReason([draft]),
        'Approve 1 UKTM management measure(s) before distribution.',
      );
      expect(variance.hasOpenVariance, isTrue);
      expect(
        service.releaseLockedReason([variance]),
        'Resolve 1 UKTM management measure variance(s) before distribution.',
      );
    });
  });
}

FinancialReportStatement _profitOrLoss() {
  return const FinancialReportStatement(
    kind: FinancialReportStatementKind.profitOrLossAndOci,
    title: 'Profit or Loss and OCI',
    subtitle: 'Jan 2026',
    lines: [
      FinancialReportLine(
        label: 'Profit (loss) before financing and income tax',
        amount: 3800,
        comparativeAmount: 2400,
      ),
    ],
  );
}
