import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_milestone.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  testWidgets('renders release milestone calendar metrics and tiles', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FinancialReportReleaseMilestonePanel(summary: _summary),
          ),
        ),
      ),
    );

    expect(find.text('Release Milestone Calendar'), findsOneWidget);
    expect(find.text('1/5 milestones complete'), findsOneWidget);
    expect(find.text('1 due soon'), findsOneWidget);
    expect(find.text('1 overdue'), findsOneWidget);
    expect(find.text('1 blocked'), findsOneWidget);
    expect(find.text('1 upcoming'), findsOneWidget);
    expect(find.text('Closed package certification'), findsOneWidget);
    expect(find.text('SPT Tahunan Badan support pack'), findsOneWidget);
    expect(find.textContaining('Tax / statutory archive'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      find.byType(
        FinancialReportResponsiveWrapGrid<FinancialReportReleaseMilestoneItem>,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'renders milestone tile date badge with the shared tint surface',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportReleaseMilestoneTile(
              item: _summary.items.first,
            ),
          ),
        ),
      );

      expect(find.text('FEB'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsNWidgets(4));
    },
  );
}

final _summary = FinancialReportReleaseMilestoneSummary(
  items: [
    FinancialReportReleaseMilestoneItem(
      id: 'package-integrity',
      area: FinancialReportReleaseMilestoneArea.packageIntegrity,
      title: 'Closed package certification',
      status: FinancialReportReleaseMilestoneStatus.blocked,
      dueDate: DateTime(2026, 2, 1),
      owner: 'Controller',
      reference: 'Package changed',
      detail: 'Package fingerprint changed after close.',
    ),
    FinancialReportReleaseMilestoneItem(
      id: 'distribution-board',
      area: FinancialReportReleaseMilestoneArea.distribution,
      title: 'Board / owners',
      status: FinancialReportReleaseMilestoneStatus.overdue,
      dueDate: DateTime(2026, 2, 3),
      owner: 'Governance recipients',
      reference: 'Secure link / acknowledgement required',
      detail: 'Governance distribution evidence is overdue.',
    ),
    FinancialReportReleaseMilestoneItem(
      id: 'statutory-tax',
      area: FinancialReportReleaseMilestoneArea.statutoryFiling,
      title: 'SPT Tahunan Badan support pack',
      status: FinancialReportReleaseMilestoneStatus.dueSoon,
      dueDate: DateTime(2026, 5, 31),
      owner: 'Tax / statutory archive',
      reference: 'DJP annual tax support',
      detail: 'Prepare annual corporate return support.',
    ),
    FinancialReportReleaseMilestoneItem(
      id: 'archive',
      area: FinancialReportReleaseMilestoneArea.archive,
      title: 'Release archive register',
      status: FinancialReportReleaseMilestoneStatus.complete,
      dueDate: DateTime(2026, 2, 6),
      owner: 'Finance archive owner',
      reference: '6/6 evidence item(s) ready',
      detail: 'Archive register created.',
    ),
    FinancialReportReleaseMilestoneItem(
      id: 'retention-review',
      area: FinancialReportReleaseMilestoneArea.retention,
      title: 'Archive retention review',
      status: FinancialReportReleaseMilestoneStatus.upcoming,
      dueDate: DateTime(2027, 2, 1),
      owner: 'Finance archive owner',
      reference: 'Jan 2026',
      detail: 'Archive custody is current.',
    ),
  ],
  completeCount: 1,
  upcomingCount: 1,
  dueSoonCount: 1,
  overdueCount: 1,
  blockedCount: 1,
  completionRatio: 0.25,
  nextAction:
      'Closed package certification: Package fingerprint changed after close.',
);
