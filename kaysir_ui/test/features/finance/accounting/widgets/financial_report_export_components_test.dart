import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_export.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_export_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_panel_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  testWidgets('export context panel renders pack readiness and counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportExportContextPanel(pack: _samplePack),
        ),
      ),
    );

    expect(find.text('Kaysir Advisory'), findsOneWidget);
    expect(find.text('FY 2026 - IDR'), findsOneWidget);
    expect(find.text('Statements'), findsOneWidget);
    expect(find.text('Schedules'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Readiness'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.byType(FinancialReportPanelSurface), findsOneWidget);
    expect(find.byType(FinancialReportTintedSurface), findsNWidgets(4));
  });

  testWidgets(
    'export option list reports selected format and locks when busy',
    (tester) async {
      FinancialReportExportFormat? selectedFormat;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportExportOptionList(
              exportingFormat: null,
              isBusy: false,
              onExport: (format) => selectedFormat = format,
            ),
          ),
        ),
      );

      expect(find.text('PDF Report Pack'), findsOneWidget);
      expect(find.text('CSV Workbook Data'), findsOneWidget);

      await tester.tap(find.text('PDF Report Pack'));
      await tester.pump();

      expect(selectedFormat, FinancialReportExportFormat.pdf);

      selectedFormat = null;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportExportOptionList(
              exportingFormat: FinancialReportExportFormat.csv,
              isBusy: true,
              onExport: (format) => selectedFormat = format,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('PDF Report Pack'));
      await tester.pump();

      expect(selectedFormat, isNull);
    },
  );
}

final _samplePack = FinancialReportPack(
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
  supportingSchedules: const [
    FinancialReportSupportingSchedule(
      kind: FinancialReportSupportingScheduleKind.cashRollForward,
      title: 'Cash roll-forward',
      subtitle: 'Cash movement support',
      totalLabel: 'Closing cash',
      lines: [],
    ),
  ],
  complianceItems: const [
    FinancialReportComplianceItem(
      id: 'ready',
      title: 'Primary statements prepared',
      description: 'All primary statements are available.',
      standardReference: 'PSAK 1',
      isSatisfied: true,
    ),
    FinancialReportComplianceItem(
      id: 'review',
      title: 'Management review pending',
      description: 'Review sign-off is still pending.',
      standardReference: 'Internal control',
      isSatisfied: false,
    ),
  ],
  metrics: const [],
);
