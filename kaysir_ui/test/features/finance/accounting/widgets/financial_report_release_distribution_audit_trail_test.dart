import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_audit_trail_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';

void main() {
  testWidgets('renders distribution audit trail with older event count', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseDistributionAuditTrail(
            events: _auditEvents,
            isDarkMode: false,
          ),
        ),
      ),
    );

    expect(find.text('Distribution Audit Trail'), findsOneWidget);
    expect(find.text('Acknowledged: Board / owners'), findsNWidgets(5));
    expect(
      find.text('Finance Lead / Jan 31, 2026 09:00 / Acknowledged / DIST-1'),
      findsOneWidget,
    );
    expect(find.text('Email / Jan 2026'), findsNWidgets(5));
    expect(find.text('Distribution event 1'), findsOneWidget);
    expect(find.text('+1 older event(s)'), findsOneWidget);
    expect(
      find.byType(
        FinancialReportAuditTrailPanel<
          FinancialReportReleaseDistributionAuditEvent
        >,
      ),
      findsOneWidget,
    );
  });
}

final _auditEvents =
    List<FinancialReportReleaseDistributionAuditEvent>.generate(
      6,
      (index) => FinancialReportReleaseDistributionAuditEvent(
        id: 'audit-$index',
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        recipientId: 'board-owners',
        recipientName: 'Board / owners',
        channel: FinancialReportReleaseDistributionChannel.email,
        action: FinancialReportReleaseDistributionAuditAction.acknowledged,
        occurredAt: DateTime(2026, 1, 31, 9, index),
        actor: 'Finance Lead',
        status: FinancialReportReleaseDistributionStatus.acknowledged,
        note: 'Distribution event ${index + 1}',
        evidenceReference: 'DIST-${index + 1}',
      ),
    );
