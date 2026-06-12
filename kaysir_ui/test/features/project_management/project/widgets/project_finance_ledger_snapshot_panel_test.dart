import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_ledger_summary_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_ledger_snapshot_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('finance ledger snapshot panel renders ledger totals', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 780,
              child: ProjectFinanceLedgerSnapshotPanel(
                summary: buildProjectFinanceLedgerSummary(
                  projectId: 'retail-modernization',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Ledger active'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Committed'), findsOneWidget);
    expect(find.text('Spent'), findsOneWidget);
    expect(find.text('Open Items'), findsOneWidget);
    expect(find.text('255.0M'), findsOneWidget);
    expect(find.text('150.0M'), findsOneWidget);
    expect(find.text('128.0M'), findsOneWidget);
    expect(find.text('Checkout and inventory systems (57%)'), findsOneWidget);
    expect(find.text('Store operations rollout (52%)'), findsOneWidget);
  });
}
