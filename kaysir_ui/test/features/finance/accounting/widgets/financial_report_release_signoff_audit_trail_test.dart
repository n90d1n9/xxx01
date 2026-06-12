import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_audit_trail_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';

void main() {
  testWidgets('renders release sign-off audit trail with older event count', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseSignOffAuditTrail(
            events: _auditEvents,
            isDarkMode: false,
          ),
        ),
      ),
    );

    expect(find.text('Release Audit Trail'), findsOneWidget);
    expect(find.text('Signed: Approved for release'), findsNWidgets(5));
    expect(
      find.text('Finance Lead / Jan 31, 2026 09:00 / Signed / SIGNOFF-1'),
      findsOneWidget,
    );
    expect(find.text('Approver / Jan 2026'), findsNWidgets(5));
    expect(find.text('Release event 1'), findsOneWidget);
    expect(find.text('+1 older event(s)'), findsOneWidget);
    expect(
      find.byType(
        FinancialReportAuditTrailPanel<FinancialReportReleaseSignOffAuditEvent>,
      ),
      findsOneWidget,
    );
  });
}

final _auditEvents = List<FinancialReportReleaseSignOffAuditEvent>.generate(
  6,
  (index) => FinancialReportReleaseSignOffAuditEvent(
    id: 'audit-$index',
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    requirementId: 'approved-for-release',
    requirementTitle: 'Approved for release',
    role: FinancialReportReleaseSignOffRole.approver,
    action: FinancialReportReleaseSignOffAuditAction.signed,
    occurredAt: DateTime(2026, 1, 31, 9, index),
    actor: 'Finance Lead',
    status: FinancialReportReleaseSignOffStatus.signed,
    note: 'Release event ${index + 1}',
    evidenceReference: 'SIGNOFF-${index + 1}',
  ),
);
