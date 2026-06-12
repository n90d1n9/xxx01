import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_management_measure_audit_trail.dart';

void main() {
  testWidgets('renders UKTM audit trail events', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportManagementMeasureAuditTrail(
            events: [_approvedEvent],
            isDarkMode: false,
          ),
        ),
      ),
    );

    expect(find.text('UKTM Audit Trail'), findsOneWidget);
    expect(
      find.text('Approved: adjusted operating performance'),
      findsOneWidget,
    );
    expect(find.textContaining('Finance lead'), findsOneWidget);
    expect(find.textContaining('Approved for release.'), findsOneWidget);
  });

  testWidgets('renders empty state when focused before audit events exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FinancialReportManagementMeasureAuditTrail(
            events: [],
            isDarkMode: false,
          ),
        ),
      ),
    );

    expect(find.text('UKTM Audit Trail'), findsOneWidget);
    expect(
      find.text('No UKTM audit events captured for this period yet.'),
      findsOneWidget,
    );
  });

  testWidgets('exposes create evidence action for empty audit trail', (
    tester,
  ) async {
    var created = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportManagementMeasureAuditTrail(
            events: const [],
            isDarkMode: false,
            emptyActionLabel: 'Approve UKTM Evidence',
            onCreateAuditEvidence: () => created = true,
          ),
        ),
      ),
    );

    expect(find.text('Approve UKTM Evidence'), findsOneWidget);

    await tester.tap(find.text('Approve UKTM Evidence'));
    await tester.pump();

    expect(created, isTrue);
  });
}

final _approvedEvent = FinancialReportManagementMeasureAuditEvent(
  id: 'audit-1',
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  measureId: 'uktm-adjusted',
  measureLabel: 'adjusted operating performance',
  action: FinancialReportManagementMeasureAuditAction.approved,
  occurredAt: _occurredAt,
  actor: 'Finance lead',
  status: FinancialReportManagementMeasureApprovalStatus.approved,
  note: 'Approved for release.',
);

final _occurredAt = DateTime(2026, 2, 1, 10);
