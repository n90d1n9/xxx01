import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_schedule_evidence_health_service.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_schedule_evidence_health_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_supporting_schedule_panel_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial report supporting schedule panel components', () {
    testWidgets('renders reusable summary header pills', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportSupportingSchedulesHeader(
              scheduleCount: 4,
              activeCount: 3,
              sourceLineCount: 12,
              isDarkMode: false,
              evidenceHealth: _actionSummary,
            ),
          ),
        ),
      );

      expect(find.text('Supporting Schedules'), findsOneWidget);
      expect(find.text('Schedules'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Lines'), findsOneWidget);
      expect(find.text('Evidence'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(4),
      );
    });

    testWidgets('renders evidence health banner and schedule status rows', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportScheduleEvidenceHealthBanner(
              summary: _actionSummary,
              items: const [_actionItem],
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Evidence follow-up'), findsOneWidget);
      expect(
        find.textContaining('Resolve 1 critical evidence signal'),
        findsWidgets,
      );
      expect(find.text('1 critical'), findsOneWidget);
      expect(find.text('2 watch'), findsOneWidget);
      expect(find.text('Bank Reconciliation Evidence'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.textContaining('Assign owner'), findsWidgets);
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(5),
      );
    });
  });
}

const _actionSummary = FinancialReportScheduleEvidenceHealthSummary(
  criticalSignalCount: 1,
  watchSignalCount: 2,
  readySignalCount: 0,
  actions: ['Assign owner'],
);

const _actionItem = FinancialReportScheduleEvidenceHealthItem(
  scheduleKind: FinancialReportSupportingScheduleKind.bankReconciliation,
  scheduleTitle: 'Bank Reconciliation Evidence',
  summary: _actionSummary,
);
