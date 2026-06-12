import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/states/fin_statement/financial_report_pack_provider.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_export_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_export_dialog.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

void main() {
  testWidgets('financial report export dialog composes modern export widgets', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(860, 680));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [financialReportPackProvider.overrideWithValue(_pack)],
        child: const MaterialApp(
          home: Scaffold(body: Center(child: FinancialReportExportDialog())),
        ),
      ),
    );

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Export Report Pack'), findsOneWidget);
    expect(find.byType(FinancialReportExportHeader), findsOneWidget);
    expect(find.byType(FinancialReportExportContextPanel), findsOneWidget);
    expect(find.byType(FinancialReportExportReadinessPanel), findsOneWidget);
    expect(find.byType(FinancialReportExportOptionList), findsOneWidget);
    expect(find.byType(FinancialReportExportOptionTile), findsNWidgets(2));
    expect(find.byType(AppActionButton), findsOneWidget);
    expect(find.text('Kaysir Advisory'), findsOneWidget);
    expect(find.text('Export Readiness'), findsOneWidget);
    expect(find.text('PDF Report Pack'), findsOneWidget);
    expect(find.text('CSV Workbook Data'), findsOneWidget);
  });
}

final _pack = FinancialReportPack(
  entityName: 'Kaysir Advisory',
  frameworkName: 'SAK Indonesia',
  jurisdiction: 'Indonesia',
  presentationCurrency: 'IDR',
  periodLabel: 'FY 2026',
  asOfLabel: '31 Dec 2026',
  periodStart: DateTime(2026),
  periodEnd: DateTime(2026, 12, 31),
  generatedAt: DateTime(2026, 12, 31, 18),
  statements: const [
    FinancialReportStatement(
      kind: FinancialReportStatementKind.financialPosition,
      title: 'Statement of Financial Position',
      subtitle: 'As of 31 Dec 2026',
      lines: [],
    ),
  ],
  notes: const [
    FinancialReportDisclosureNote(
      number: '1',
      title: 'Basis of preparation',
      body: 'Prepared for management review.',
    ),
  ],
  supportingSchedules: const [],
  complianceItems: const [
    FinancialReportComplianceItem(
      id: 'ready',
      title: 'Primary statements prepared',
      description: 'All primary statements are available.',
      standardReference: 'PSAK 1',
      isSatisfied: true,
    ),
  ],
  metrics: const [],
);
