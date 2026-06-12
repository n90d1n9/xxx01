import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close_workflow.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_period_close_workflow_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_responsive_grid_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_tinted_surface_components.dart';

void main() {
  group('financial period close workflow components', () {
    testWidgets('renders step tracker with shared responsive grid', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1180, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1100,
              child: FinancialPeriodCloseStepTracker(
                snapshot: _snapshot(),
                isDarkMode: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Period selected'), findsOneWidget);
      expect(find.text('Checklist ready'), findsOneWidget);
      expect(find.text('Closing entry'), findsOneWidget);
      expect(find.text('Archive package'), findsOneWidget);
      expect(find.text('TB'), findsOneWidget);
      expect(find.text('Complete'), findsNWidgets(2));
      expect(find.text('Blocked'), findsOneWidget);
      expect(
        find.byType(
          FinancialReportResponsiveWrapGrid<FinancialPeriodCloseWorkflowStep>,
        ),
        findsOneWidget,
      );
      expect(
        find.byType(FinancialReportTintedSurface),
        findsAtLeastNWidgets(5),
      );
      expect(
        tester.getSize(find.byType(FinancialPeriodCloseStepCard).first).width,
        moreOrLessEquals(212, epsilon: 0.01),
      );
    });

    testWidgets('renders header progress and available actions', (
      tester,
    ) async {
      var didClose = false;

      await tester.binding.setSurfaceSize(const Size(1180, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 1100,
                child: FinancialPeriodCloseWorkflowHeader(
                  snapshot: _snapshot(canClosePeriod: true, blockerCount: 0),
                  onPostClosingEntry: null,
                  onClosePeriod: () => didClose = true,
                  onReopenPeriod: null,
                  isDarkMode: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Period Close Command Center'), findsOneWidget);
      expect(find.text('FY 2026 | Ready to close'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
      expect(find.text('2/5 steps'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Close Period'));
      await tester.pump();

      expect(didClose, isTrue);
    });
  });
}

FinancialPeriodCloseWorkflowSnapshot _snapshot({
  bool canClosePeriod = false,
  int blockerCount = 1,
}) {
  return FinancialPeriodCloseWorkflowSnapshot(
    periodLabel: 'FY 2026',
    hasBoundedPeriod: true,
    isClosed: false,
    isReopened: false,
    closingEntryRequired: true,
    closingEntryPosted: false,
    canPostClosingEntry: false,
    canClosePeriod: canClosePeriod,
    canReopenPeriod: false,
    readinessRatio: 0.8,
    blockerCount: blockerCount,
    reviewCount: 1,
    auditEventCount: 3,
    attentionItems: const ['Resolve blocked evidence.'],
    steps: const [
      FinancialPeriodCloseWorkflowStep(
        id: 'period',
        title: 'Period selected',
        description: 'A bounded close period is active.',
        status: FinancialPeriodCloseWorkflowStepStatus.complete,
        reference: 'PERIOD',
      ),
      FinancialPeriodCloseWorkflowStep(
        id: 'checklist',
        title: 'Checklist ready',
        description: 'Readiness checks are mostly complete.',
        status: FinancialPeriodCloseWorkflowStepStatus.complete,
        reference: 'TB',
      ),
      FinancialPeriodCloseWorkflowStep(
        id: 'closing-entry',
        title: 'Closing entry',
        description: 'Closing journal is waiting for evidence.',
        status: FinancialPeriodCloseWorkflowStepStatus.blocked,
        reference: 'JE',
        isBlocking: true,
      ),
      FinancialPeriodCloseWorkflowStep(
        id: 'close-period',
        title: 'Close period',
        description: 'Lock accounting activity for the period.',
        status: FinancialPeriodCloseWorkflowStepStatus.active,
        reference: 'LOCK',
      ),
      FinancialPeriodCloseWorkflowStep(
        id: 'archive',
        title: 'Archive package',
        description: 'Archive report package evidence.',
        status: FinancialPeriodCloseWorkflowStepStatus.queued,
        reference: 'PACK',
      ),
    ],
  );
}
