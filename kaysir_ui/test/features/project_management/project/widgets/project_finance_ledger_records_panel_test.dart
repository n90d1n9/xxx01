import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_ledger_summary_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_ledger_records_panel.dart';

void main() {
  testWidgets('finance ledger records panel renders and filters records', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 880,
              child: ProjectFinanceLedgerRecordsPanel(
                summary: buildProjectFinanceLedgerSummary(
                  projectId: 'retail-modernization',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('7 ledger records tracked'), findsOneWidget);
    expect(find.text('Pilot store project float'), findsOneWidget);
    expect(find.text('Pilot branch training materials'), findsOneWidget);
    expect(find.text('Store operations rollout'), findsOneWidget);
    expect(find.text('Training delivery proof'), findsOneWidget);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Pilot store project float'), findsOneWidget);
    expect(find.text('Pilot branch training materials'), findsOneWidget);
    expect(find.text('Training delivery proof'), findsOneWidget);
    expect(find.text('Store operations rollout'), findsNothing);
  });
}
