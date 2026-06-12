import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_management_measure_dialog.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  testWidgets('management measure dialog captures overrides and evidence', (
    tester,
  ) async {
    FinancialReportManagementMeasure? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<FinancialReportManagementMeasure>(
                      context: context,
                      builder:
                          (context) =>
                              const FinancialReportManagementMeasureDialog(),
                    );
                  },
                  child: const Text('Open'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Add UKTM Measure'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Measure label'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Adjustment amount'),
      findsOneWidget,
    );
    expect(find.byType(AppSurface), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Measure label'),
      'adjusted operating performance',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Owner'), 'CFO');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Measure amount override'),
      '4,000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adjustment label'),
      'Non-recurring setup cost',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Source reference'),
      'MGMT-ADJ-001',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adjustment amount'),
      '200',
    );
    await tester.tap(find.text('Add Measure'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 'uktm-adjusted-operating-performance');
    expect(result!.owner, 'CFO');
    expect(result!.amountOverride, 4000);
    expect(
      result!.approvalStatus,
      FinancialReportManagementMeasureApprovalStatus.draft,
    );
    expect(result!.adjustments, hasLength(1));
    expect(result!.adjustments.single.label, 'Non-recurring setup cost');
    expect(result!.adjustments.single.amount, 200);
    expect(result!.adjustments.single.sourceReference, 'MGMT-ADJ-001');
  });

  testWidgets('editing a measure preserves id and resets approval', (
    tester,
  ) async {
    FinancialReportManagementMeasure? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<FinancialReportManagementMeasure>(
                      context: context,
                      builder:
                          (context) =>
                              const FinancialReportManagementMeasureDialog(
                                initialMeasure: _approvedMeasure,
                              ),
                    );
                  },
                  child: const Text('Open'),
                ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Owner'),
      'Reporting controller',
    );
    await tester.tap(find.text('Save Measure'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, _approvedMeasure.id);
    expect(result!.owner, 'Reporting controller');
    expect(
      result!.approvalStatus,
      FinancialReportManagementMeasureApprovalStatus.draft,
    );
    expect(result!.reviewNote, 'Updated - submit for review before release.');
  });
}

const _approvedMeasure = FinancialReportManagementMeasure(
  id: 'uktm-operating-performance',
  label: 'management operating performance',
  owner: 'Financial reporting lead',
  amountOverride: 3800,
  approvalStatus: FinancialReportManagementMeasureApprovalStatus.approved,
);
