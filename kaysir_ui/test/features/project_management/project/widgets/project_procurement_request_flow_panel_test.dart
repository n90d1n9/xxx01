import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_procurement_commitment_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_procurement_request_flow_panel.dart';

void main() {
  testWidgets('procurement request panel validates and queues a request', (
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
    final summary = buildProjectProcurementCommitmentSummary(workspace);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 980,
              child: ProjectProcurementRequestFlowPanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Procurement request flow'), findsOneWidget);
    expect(find.text('Procurement request queue empty'), findsOneWidget);

    await tester.ensureVisible(find.text('Queue Request'));
    await tester.tap(find.text('Queue Request'));
    await tester.pump();

    expect(find.text('Procurement request title is required.'), findsOneWidget);
    expect(find.text('Vendor or supplier is required.'), findsOneWidget);
    expect(find.text('Procurement amount is required.'), findsOneWidget);
    expect(find.text('Scope note is required.'), findsOneWidget);
    expect(find.text('Evidence note is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('procurement-request-title')),
      'Scanner supplier purchase request',
    );
    await tester.enterText(
      find.byKey(const ValueKey('procurement-request-vendor')),
      'PT Sensor Integrasi',
    );
    await tester.enterText(
      find.byKey(const ValueKey('procurement-request-owner')),
      'Supply Chain Owner',
    );
    await tester.enterText(
      find.byKey(const ValueKey('procurement-request-amount')),
      '45000000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('procurement-request-scope')),
      'Procure scanners, mounting accessories, freight handling, and onsite installation coordination.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('procurement-request-evidence')),
      'Attach supplier quotation, purchase reason, delivery lead time, and warehouse acceptance checklist.',
    );
    await tester.ensureVisible(find.text('Queue Request'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Queue Request'));
    await tester.pump();

    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Procurement request queue empty'), findsNothing);
  });
}
