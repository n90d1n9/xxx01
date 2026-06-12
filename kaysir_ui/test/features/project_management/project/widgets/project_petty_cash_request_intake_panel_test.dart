import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_petty_cash_workspace_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_petty_cash_request_intake_panel.dart';

void main() {
  testWidgets('petty cash request intake panel validates and queues a request', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final project = const ProjectPortfolioRepository().findById(
      'retail-modernization',
    );
    final financeWorkspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectPettyCashWorkspaceSummary(
      financeWorkspace,
      today: DateTime(2026, 6, 20),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 960,
              child: ProjectPettyCashRequestIntakePanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Petty cash request flow'), findsOneWidget);
    expect(find.text('Petty cash request queue empty'), findsOneWidget);

    await tester.ensureVisible(find.text('Queue Request'));
    await tester.tap(find.text('Queue Request'));
    await tester.pump();

    expect(find.text('Request title is required.'), findsOneWidget);
    expect(find.text('Amount is required.'), findsOneWidget);
    expect(find.text('Evidence note is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('petty-cash-request-title')),
      'Pilot store replenishment float',
    );
    await tester.enterText(
      find.byKey(const ValueKey('petty-cash-request-custodian')),
      'Maya Santoso',
    );
    await tester.enterText(
      find.byKey(const ValueKey('petty-cash-request-amount')),
      '1250000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('petty-cash-request-evidence')),
      'Receipts will be attached by store custodian with branch purpose and reconciliation date.',
    );
    await tester.ensureVisible(find.text('Queue Request'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Queue Request'));
    await tester.pump();

    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Petty cash request queue empty'), findsNothing);
  });
}
