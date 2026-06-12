import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_panel_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report panel components', () {
    testWidgets('renders shared panel surface header and badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportPanelSurface(
              isDarkMode: false,
              child: FinancialReportPanelHeader(
                title: 'Report Surface',
                subtitle: 'Reusable chrome for report-pack panels.',
                icon: Icons.dashboard_customize_rounded,
                accentColor: Colors.teal,
                isDarkMode: false,
                trailing: const FinancialReportPanelBadge(
                  label: '3 ready',
                  color: Colors.teal,
                  icon: Icons.verified_rounded,
                  isDarkMode: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Report Surface'), findsOneWidget);
      expect(
        find.text('Reusable chrome for report-pack panels.'),
        findsOneWidget,
      );
      expect(find.text('3 ready'), findsOneWidget);
      expect(find.byType(FinancialReportTintedSurface), findsOneWidget);
      expect(financialReportPanelBackground(false), Colors.white);
      expect(financialReportPanelBackground(false, muted: true), isNotNull);
      expect(financialReportPanelBorder(false), isNotNull);
    });

    testWidgets('renders reusable contained empty state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialReportPanelEmptyState(
              title: 'No report evidence yet',
              message: 'Attach schedules before sharing the pack.',
              icon: Icons.playlist_add_check_rounded,
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('No report evidence yet'), findsOneWidget);
      expect(
        find.text('Attach schedules before sharing the pack.'),
        findsOneWidget,
      );
      expect(find.byType(FinancialReportTintedSurface), findsOneWidget);
    });
  });
}
