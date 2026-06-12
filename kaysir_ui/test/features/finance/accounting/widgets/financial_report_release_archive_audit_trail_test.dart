import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_audit_trail_components.dart';
import 'package:kaysir/features/finance/accounting/widgets/financial_report_release_signoff_components.dart';

void main() {
  testWidgets('renders archive audit trail with older event count', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FinancialReportReleaseArchiveAuditTrail(
            events: _auditEvents,
            isDarkMode: false,
          ),
        ),
      ),
    );

    expect(find.text('Archive Audit Trail'), findsOneWidget);
    expect(
      find.text('Archived: FR-ARCH-2026010120260131-ABCDEF123456'),
      findsNWidgets(5),
    );
    expect(
      find.textContaining('Finance Lead / Jan 31, 2026 09:00'),
      findsOneWidget,
    );
    expect(find.textContaining('/ ABCDEF123456 /'), findsNWidgets(5));
    expect(find.textContaining('retain until Jan 31, 2036'), findsNWidgets(5));
    expect(find.text('Archive event 1'), findsOneWidget);
    expect(find.text('+1 older event(s)'), findsOneWidget);
    expect(
      find.byType(
        FinancialReportAuditTrailPanel<FinancialReportReleaseArchiveAuditEvent>,
      ),
      findsOneWidget,
    );
  });
}

final _auditEvents = List<FinancialReportReleaseArchiveAuditEvent>.generate(
  6,
  (index) => FinancialReportReleaseArchiveAuditEvent(
    id: 'archive-audit-$index',
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    archiveId: 'FR-ARCH-2026010120260131-ABCDEF123456',
    action: FinancialReportReleaseArchiveAuditAction.archived,
    occurredAt: DateTime(2026, 1, 31, 9, index),
    actor: 'Finance Lead',
    custodian: 'Finance archive owner',
    storageLocation: 'Encrypted archive vault',
    retentionPolicy: 'Indonesia statutory/tax archive policy',
    retainUntil: DateTime(2036, 1, 31),
    packageFingerprint: 'abcdef1234567890',
    note: 'Archive event ${index + 1}',
  ),
);
