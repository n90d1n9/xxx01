import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_ledger_summary_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_finance_action_queue_panel.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';

void main() {
  testWidgets('finance action queue panel renders prioritized actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 880,
              child: ProjectFinanceActionQueuePanel(
                summary: buildProjectFinanceLedgerSummary(
                  projectId: 'warehouse-automation',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppMetricGrid), findsOneWidget);
    expect(find.text('Finance blocks need action'), findsOneWidget);
    expect(find.text('4 Actions'), findsOneWidget);
    expect(find.text('Critical'), findsOneWidget);
    expect(
      find.text('Unblock petty cash: Fulfillment floor float'),
      findsOneWidget,
    );
    expect(find.text('Resolve block'), findsWidgets);
    expect(find.textContaining('Due 24 Jun 2026'), findsWidgets);
  });
}
