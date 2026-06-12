import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_supporting_schedule_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_supporting_schedules_panel.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';
import 'package:kaysir/widgets/ui/app_surface.dart';

void main() {
  group('FinancialReportSupportingSchedulesPanel', () {
    testWidgets('summarizes schedule coverage before cards', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FinancialReportSupportingSchedulesPanel(
                  pack: _pack(),
                  isDarkMode: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Supporting Schedules'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(find.text('Schedules'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Lines'), findsOneWidget);
      expect(find.text('Evidence'), findsOneWidget);
      expect(find.text('Ready'), findsOneWidget);
      expect(find.text('Cash roll-forward'), findsOneWidget);
      expect(find.text('Empty income tax detail'), findsOneWidget);
    });

    testWidgets('surfaces evidence follow-up when schedules have risk', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FinancialReportSupportingSchedulesPanel(
                  pack: _packWithEvidenceRisk(),
                  isDarkMode: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Evidence'), findsOneWidget);
      expect(find.text('Action'), findsWidgets);
      expect(find.text('Evidence follow-up'), findsOneWidget);
      expect(find.text('Bank Reconciliation Evidence'), findsWidgets);
      expect(
        find.textContaining('Resolve 1 critical evidence signal'),
        findsWidgets,
      );
      expect(find.textContaining('Monitor 2 watch signal'), findsWidgets);
      expect(find.text('1 critical'), findsOneWidget);
      expect(find.text('2 watch'), findsOneWidget);
      expect(find.text('Close Evidence Tasks'), findsOneWidget);
      expect(find.textContaining('evidence follow-up'), findsWidgets);
      expect(find.text('Treasury / Cash accountant'), findsOneWidget);
      expect(find.text('Controller'), findsOneWidget);
      expect(find.text('PSAK 207 / PSAK 201'), findsOneWidget);
      expect(find.text('Blocks close'), findsOneWidget);
    });
  });

  group('FinancialReportSupportingScheduleCard', () {
    testWidgets('renders wide comparative source columns', (tester) async {
      await tester.binding.setSurfaceSize(const Size(980, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: FinancialReportSupportingScheduleCard(
                schedule: _cashSchedule(),
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Cash roll-forward'), findsOneWidget);
      expect(find.text('PSAK 2'), findsOneWidget);
      expect(find.text('Source line'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Comparative'), findsOneWidget);
      expect(find.text('Variance'), findsOneWidget);
      expect(find.text('Cash receipts'), findsOneWidget);
      expect(find.text('Operating cash - Note 7'), findsOneWidget);
      expect(find.text(r'$12,000.00'), findsOneWidget);
      expect(find.text(r'$10,000.00'), findsOneWidget);
      expect(find.text(r'$2,000.00'), findsOneWidget);
      expect(find.text('Net cash movement'), findsOneWidget);
      expect(find.byType(AppSurface), findsOneWidget);
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(2),
      );
    });

    testWidgets('stacks comparative amounts on compact widths', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: FinancialReportSupportingScheduleCard(
                schedule: _cashSchedule(),
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Source line'), findsNothing);
      expect(find.text('Cash receipts'), findsOneWidget);
      expect(find.text(r'Current $12,000.00'), findsOneWidget);
      expect(find.text(r'Comparative $10,000.00'), findsOneWidget);
      expect(find.text(r'Variance $2,000.00'), findsOneWidget);
    });

    testWidgets('expands structured schedule evidence into chips', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: FinancialReportSupportingScheduleCard(
                schedule: _timingReviewEvidenceSchedule(),
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Timing PAY-002 - Outstanding payment'), findsOneWidget);
      expect(find.text('Stale timing difference'), findsOneWidget);
      expect(find.text('Escalate'), findsOneWidget);
      expect(find.text('Overdue'), findsOneWidget);
      expect(find.text('Review Cleared'), findsOneWidget);
      expect(find.text('Owner Controller'), findsOneWidget);
      expect(find.text('Reviewed Jan 31, 2026'), findsOneWidget);
      expect(find.text('Cleared on Feb bank statement.'), findsOneWidget);
      expect(find.text('Note 3'), findsOneWidget);
    });

    testWidgets('handles schedules without source lines', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialReportSupportingScheduleCard(
              schedule: _emptySchedule(),
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Empty income tax detail'), findsOneWidget);
      expect(
        find.text('No source lines are attached to this schedule yet.'),
        findsOneWidget,
      );
      expect(find.text('Total income tax movements'), findsOneWidget);
      expect(find.text(r'Current $0.00'), findsOneWidget);
    });
  });
}

FinancialReportPack _pack() {
  return FinancialReportPack(
    entityName: 'Kaysir Advisory',
    frameworkName: 'SAK Indonesia',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'FY 2026',
    asOfLabel: '31 Dec 2026',
    periodStart: DateTime(2026),
    periodEnd: DateTime(2026, 12, 31),
    generatedAt: DateTime(2026, 12, 31, 18),
    statements: const [],
    notes: const [],
    supportingSchedules: [_cashSchedule(), _emptySchedule()],
    complianceItems: const [],
    metrics: const [],
  );
}

FinancialReportPack _packWithEvidenceRisk() {
  return FinancialReportPack(
    entityName: 'Kaysir Advisory',
    frameworkName: 'SAK Indonesia',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'FY 2026',
    asOfLabel: '31 Dec 2026',
    periodStart: DateTime(2026),
    periodEnd: DateTime(2026, 12, 31),
    generatedAt: DateTime(2026, 12, 31, 18),
    statements: const [],
    notes: const [],
    supportingSchedules: [_timingReviewMetricSchedule()],
    complianceItems: const [],
    metrics: const [],
  );
}

FinancialReportSupportingSchedule _cashSchedule() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.cashRollForward,
    title: 'Cash roll-forward',
    subtitle: 'Movement in cash and bank balances.',
    totalLabel: 'Net cash movement',
    standardReferences: ['PSAK 2'],
    metrics: [
      FinancialReportScheduleMetric(
        label: 'Matched',
        value: '98%',
        helperText: 'Bank statement lines matched to ledger entries.',
      ),
    ],
    lines: [
      FinancialReportScheduleLine(
        label: 'Cash receipts',
        amount: 12000,
        comparativeAmount: 10000,
        sourceCategory: 'Operating cash',
        noteReference: '7',
      ),
      FinancialReportScheduleLine(
        label: 'Cash payments',
        amount: -4000,
        comparativeAmount: -3000,
        sourceCategory: 'Operating cash',
      ),
    ],
  );
}

FinancialReportSupportingSchedule _timingReviewMetricSchedule() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.bankReconciliation,
    title: 'Bank Reconciliation Evidence',
    subtitle: 'Bank statement and GL cash/bank tie-out.',
    totalLabel: 'Bank reconciliation variance',
    lines: [],
    metrics: [
      FinancialReportScheduleMetric(
        label: 'Timing deadline risk',
        value: '1 overdue / 1 due soon',
        helperText: 'Clear-by deadline risk.',
      ),
      FinancialReportScheduleMetric(
        label: 'Timing review gaps',
        value: '1 unreviewed / 0 owner gaps / 0 overdue unresolved',
        helperText: 'Open documentation, owner, and overdue review gaps.',
      ),
      FinancialReportScheduleMetric(
        label: 'Timing review action',
        value: 'Document 1 open review(s)',
        helperText: 'Review follow-up.',
      ),
    ],
  );
}

FinancialReportSupportingSchedule _timingReviewEvidenceSchedule() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.bankReconciliation,
    title: 'Bank Reconciliation Evidence',
    subtitle: 'Bank statement and GL cash/bank tie-out.',
    totalLabel: 'Bank reconciliation variance',
    standardReferences: ['PSAK 201', 'PSAK 207'],
    lines: [
      FinancialReportScheduleLine(
        label: 'Timing PAY-002 - Outstanding payment',
        amount: -300,
        sourceCategory:
            'Stale timing difference / Escalate / Clear by Jan 29, 2026 / '
            'Overdue / Review Cleared / Owner Controller / '
            'Reviewed Jan 31, 2026 / Cleared on Feb bank statement.',
        noteReference: '3',
      ),
    ],
  );
}

FinancialReportSupportingSchedule _emptySchedule() {
  return const FinancialReportSupportingSchedule(
    kind: FinancialReportSupportingScheduleKind.incomeTax,
    title: 'Empty income tax detail',
    subtitle: 'Awaiting tax settlement source lines.',
    totalLabel: 'Total income tax movements',
    lines: [],
  );
}
