import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_management_measure_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  testWidgets('management measure card exposes remove action when enabled', (
    tester,
  ) async {
    var removed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportManagementMeasureCard(
            reconciliation: _reconciliation,
            onEdit: () {},
            onRemove: () => removed = true,
            onApprove: () {},
            onMarkInReview: () {},
            onReturn: () {},
          ),
        ),
      ),
    );

    expect(find.text('Remove'), findsOneWidget);
    expect(find.byType(FinancialReportTintedSurface), findsNWidgets(4));

    await tester.tap(find.text('Remove'));
    await tester.pump();

    expect(removed, isTrue);
  });

  testWidgets('management measure card disables remove action when null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportManagementMeasureCard(
            reconciliation: _reconciliation,
            onEdit: () {},
            onRemove: null,
            onApprove: () {},
            onMarkInReview: () {},
            onReturn: () {},
          ),
        ),
      ),
    );

    final removeButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Remove'),
    );
    expect(removeButton.onPressed, isNull);
  });
}

const _reconciliation = FinancialReportManagementMeasureReconciliation(
  measure: FinancialReportManagementMeasure(
    id: 'uktm-adjusted-operating-performance',
    label: 'adjusted operating performance',
    owner: 'Controller',
    approvalStatus: FinancialReportManagementMeasureApprovalStatus.draft,
  ),
  subtotalAmount: 3800,
  measureAmount: 4000,
  adjustmentTotal: 200,
);
