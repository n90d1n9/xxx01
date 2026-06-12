import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_statutory_filing.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';

void main() {
  testWidgets('renders statutory filing tracker metrics and items', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportStatutoryFilingPanel(summary: _summary),
        ),
      ),
    );

    expect(find.text('Statutory Filing Tracker'), findsOneWidget);
    expect(find.text('1/3 complete'), findsOneWidget);
    expect(find.text('1 due soon'), findsOneWidget);
    expect(find.text('1 overdue'), findsOneWidget);
    expect(find.text('Management release copy'), findsOneWidget);
    expect(find.text('SPT Tahunan Badan support pack'), findsOneWidget);
    expect(find.textContaining('DJP annual tax support'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      find.byType(
        FinancialReportResponsiveWrapGrid<FinancialReportStatutoryFilingItem>,
      ),
      findsOneWidget,
    );
  });
}

final _summary = FinancialReportStatutoryFilingSummary(
  items: [
    FinancialReportStatutoryFilingItem(
      kind: FinancialReportStatutoryFilingKind.managementRelease,
      title: 'Management release copy',
      status: FinancialReportStatutoryFilingStatus.complete,
      dueDate: DateTime(2026, 2, 2),
      owner: 'Management release owner',
      reference: 'Internal management release',
      detail: 'Management evidence is complete.',
      evidenceReference: 'MGMT-001',
    ),
    FinancialReportStatutoryFilingItem(
      kind: FinancialReportStatutoryFilingKind.annualCorporateTaxSupport,
      title: 'SPT Tahunan Badan support pack',
      status: FinancialReportStatutoryFilingStatus.dueSoon,
      dueDate: DateTime(2026, 5, 31),
      owner: 'Tax / statutory archive',
      reference: 'DJP annual tax support',
      detail: 'Prepare annual corporate return support.',
      evidenceReference: '',
    ),
    FinancialReportStatutoryFilingItem(
      kind: FinancialReportStatutoryFilingKind.statutoryArchive,
      title: 'Indonesia statutory evidence archive',
      status: FinancialReportStatutoryFilingStatus.overdue,
      dueDate: DateTime(2026, 2, 6),
      owner: 'Finance controller',
      reference: 'Release archive and retention evidence',
      detail: 'Create the release archive register.',
      evidenceReference: '',
    ),
  ],
  completeCount: 1,
  dueSoonCount: 1,
  overdueCount: 1,
  blockedCount: 0,
  completionRatio: 1 / 3,
  nextAction:
      'Indonesia statutory evidence archive: Create the release archive register.',
);
