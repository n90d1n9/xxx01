import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_workspace_service.dart';
import 'package:kaysir/features/project_management/project/services/project_funding_release_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_funding_release_request_intake_panel.dart';

void main() {
  testWidgets('funding release request panel validates and queues a release', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final project = const ProjectPortfolioRepository().findById(
      'warehouse-automation',
    );
    final financeWorkspace = buildProjectFinanceWorkspaceSummary(project!);
    final summary = buildProjectFundingReleaseSummary(financeWorkspace);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 960,
              child: ProjectFundingReleaseRequestIntakePanel(summary: summary),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Funding release request flow'), findsOneWidget);
    expect(find.text('Funding release queue empty'), findsOneWidget);

    await tester.ensureVisible(find.text('Queue Release'));
    await tester.tap(find.text('Queue Release'));
    await tester.pump();

    expect(find.text('Release title is required.'), findsOneWidget);
    expect(find.text('Release amount is required.'), findsOneWidget);
    expect(find.text('Gate note is required.'), findsOneWidget);
    expect(find.text('Evidence note is required.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('funding-release-request-title')),
      'Sensor installation release window',
    );
    await tester.enterText(
      find.byKey(const ValueKey('funding-release-request-owner')),
      'Supply Chain Sponsor',
    );
    await tester.enterText(
      find.byKey(const ValueKey('funding-release-request-amount')),
      '45000000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('funding-release-request-gate')),
      'Release only after scanner delivery confirmation and blocked freight exception review are cleared.',
    );
    await tester.enterText(
      find.byKey(const ValueKey('funding-release-request-evidence')),
      'Attach supplier delivery note, sponsor approval, release checklist, and cash-flow owner confirmation.',
    );
    await tester.ensureVisible(find.text('Queue Release'));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.text('Queue Release'));
    await tester.pump();

    expect(find.text('Queued'), findsOneWidget);
    expect(find.text('Funding release queue empty'), findsNothing);
  });
}
