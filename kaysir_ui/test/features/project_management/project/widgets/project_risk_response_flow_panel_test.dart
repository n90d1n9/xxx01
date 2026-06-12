import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_risk_issue_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_risk_response_flow_panel.dart';

void main() {
  testWidgets('risk response panel validates and queues a response', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final workspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectRiskIssueWorkspaceSummary(
      workspace,
      today: DateTime(2026, 6, 11),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 980,
              child: ProjectRiskResponseFlowPanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Risk response flow'), findsOneWidget);
    expect(find.text('Risk response queue empty'), findsOneWidget);

    await tester.ensureVisible(find.text('Queue Response'));
    await tester.tap(find.text('Queue Response'));
    await tester.pump();

    expect(find.text('Risk response title is required.'), findsOneWidget);
    expect(find.text('Response note is required.'), findsOneWidget);
    expect(find.text('Evidence note is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('risk-response-title')),
      'Scanner delivery recovery response',
    );
    await tester.enterText(
      find.byKey(const ValueKey('risk-response-owner')),
      'Delivery Sponsor',
    );
    await tester.enterText(
      find.byKey(const ValueKey('risk-response-note')),
      'Escalate supplier lead-time recovery, alternate sourcing, and warehouse cutover protection before the next gate.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('risk-response-evidence')),
      'Attach supplier recovery memo, alternate quotation, revised delivery date, and sponsor approval trail.',
    );
    await tester.ensureVisible(find.text('Queue Response'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Queue Response'));
    await tester.pump();

    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Risk response queue empty'), findsNothing);
  });
}
