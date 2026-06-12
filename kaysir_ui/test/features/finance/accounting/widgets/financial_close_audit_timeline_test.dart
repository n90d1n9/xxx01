import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close_audit.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_close_audit_timeline.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_audit_trail_components.dart';

void main() {
  group('financial close audit timeline', () {
    testWidgets('renders close audit trail with shared audit panel shell', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FinancialCloseAuditTimeline(
              events: _events,
              isDarkMode: false,
            ),
          ),
        ),
      );

      expect(find.text('Close Audit Trail'), findsOneWidget);
      expect(find.text('Closed by Controller'), findsNWidgets(5));
      expect(find.text('Package fingerprint ABCDEF123456'), findsNWidgets(5));
      expect(find.text('Closing entry JE-2026-001'), findsNWidgets(5));
      expect(find.text('Ready for board reporting.'), findsOneWidget);
      expect(find.text('+1 older event(s)'), findsOneWidget);
      expect(
        find.byType(
          FinancialReportAuditTrailPanel<FinancialPeriodCloseAuditEvent>,
        ),
        findsOneWidget,
      );
    });

    testWidgets('hides timeline when there are no audit events', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FinancialCloseAuditTimeline(events: [], isDarkMode: false),
          ),
        ),
      );

      expect(find.text('Close Audit Trail'), findsNothing);
      expect(
        find.byType(
          FinancialReportAuditTrailPanel<FinancialPeriodCloseAuditEvent>,
        ),
        findsNothing,
      );
    });
  });
}

final _events = List<FinancialPeriodCloseAuditEvent>.generate(
  6,
  (index) => FinancialPeriodCloseAuditEvent(
    id: 'audit-$index',
    periodKey: '2026-01',
    periodLabel: 'Jan 2026',
    action: FinancialPeriodCloseAuditAction.closed,
    occurredAt: DateTime(2026, 1, 31, 17, index),
    actor: 'Controller',
    reason: index == 0 ? 'Ready for board reporting.' : null,
    checklistReadinessRatio: 1,
    blockerCount: 0,
    reportPackageHash: 'abcdef1234567890',
    closingEntryReference: 'JE-2026-001',
  ),
);
