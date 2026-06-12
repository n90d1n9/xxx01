import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_control.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  testWidgets('renders release control summary stages and next action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 960,
              child: FinancialReportReleaseControlSummaryPanel(
                summary: _summary,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Release Control Summary'), findsOneWidget);
    expect(find.text('Release in progress'), findsOneWidget);
    expect(
      find.text('Complete all required release sign-offs.'),
      findsOneWidget,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Package integrity'), findsOneWidget);
    expect(find.text('Release sign-offs'), findsOneWidget);
    expect(find.text('Distribution'), findsOneWidget);
    expect(find.text('Complete'), findsOneWidget);
    expect(find.text('Action needed'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(
      find.byType(
        FinancialReportResponsiveWrapGrid<FinancialReportReleaseControlStage>,
      ),
      findsOneWidget,
    );
    expect(find.byType(FinancialReportTintedSurface), findsAtLeastNWidgets(3));
  });
}

const _summary = FinancialReportReleaseControlSummary(
  packageVerified: true,
  signOffComplete: false,
  distributionComplete: false,
  releaseComplete: false,
  completionRatio: 1 / 3,
  headline: 'Release in progress',
  nextAction: 'Complete all required release sign-offs.',
  stages: [
    FinancialReportReleaseControlStage(
      kind: FinancialReportReleaseControlStageKind.packageIntegrity,
      title: 'Package integrity',
      status: FinancialReportReleaseControlStageStatus.complete,
      detail: 'The displayed report package matches the closed package.',
    ),
    FinancialReportReleaseControlStage(
      kind: FinancialReportReleaseControlStageKind.signOff,
      title: 'Release sign-offs',
      status: FinancialReportReleaseControlStageStatus.actionNeeded,
      detail: '1/2 required sign-off(s) complete.',
    ),
    FinancialReportReleaseControlStage(
      kind: FinancialReportReleaseControlStageKind.distribution,
      title: 'Distribution',
      status: FinancialReportReleaseControlStageStatus.blocked,
      detail: '0/2 distribution item(s) complete, 0 acknowledged.',
    ),
  ],
);
