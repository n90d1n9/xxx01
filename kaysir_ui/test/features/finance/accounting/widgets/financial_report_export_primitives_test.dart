import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_export.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_export_context_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_export_option_components.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  group('financial report export primitives', () {
    testWidgets('renders header and metric badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FinancialReportExportHeader(
                  title: 'Share Board Pack',
                  subtitle: 'Choose a clean handoff format.',
                ),
                FinancialReportExportMetricBadge(
                  label: 'Readiness',
                  value: '92%',
                  icon: Icons.verified_outlined,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Share Board Pack'), findsOneWidget);
      expect(find.text('Choose a clean handoff format.'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('Readiness'), findsOneWidget);
    });

    testWidgets('renders direct option tile and exposes format visuals', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportExportOptionTile(
              format: FinancialReportExportFormat.csv,
              isLoading: false,
              isDisabled: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('CSV Workbook Data'), findsOneWidget);
      expect(find.byType(AppSurface), findsOneWidget);
      expect(
        financialReportExportFormatTitle(FinancialReportExportFormat.pdf),
        'PDF Report Pack',
      );
      expect(
        financialReportExportFormatIcon(FinancialReportExportFormat.csv),
        Icons.table_chart_rounded,
      );

      await tester.tap(find.text('CSV Workbook Data'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
