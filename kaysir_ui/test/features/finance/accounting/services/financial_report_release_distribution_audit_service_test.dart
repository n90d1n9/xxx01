import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_distribution_audit_service.dart';

void main() {
  group('FinancialReportReleaseDistributionAuditService', () {
    test('creates sent, acknowledged, and exception audit events', () {
      var sequence = 0;
      final service = FinancialReportReleaseDistributionAuditService(
        nextId: () => 'audit-${++sequence}',
      );

      final sent = service.resolutionSaved(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        item: _item,
        resolution: _resolution(
          status: FinancialReportReleaseDistributionStatus.sent,
          updatedAt: DateTime(2026, 2, 1, 10),
        ),
      );
      final acknowledged = service.resolutionSaved(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        item: _item,
        resolution: _resolution(
          status: FinancialReportReleaseDistributionStatus.acknowledged,
          updatedAt: DateTime(2026, 2, 1, 11),
        ),
      );
      final exception = service.resolutionSaved(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        item: _item,
        resolution: _resolution(
          status: FinancialReportReleaseDistributionStatus.exception,
          updatedAt: DateTime(2026, 2, 1, 12),
        ),
      );

      expect(sent.id, 'audit-1');
      expect(sent.action, FinancialReportReleaseDistributionAuditAction.sent);
      expect(sent.recipientName, 'Board / owners');
      expect(sent.channel, FinancialReportReleaseDistributionChannel.email);

      expect(acknowledged.id, 'audit-2');
      expect(
        acknowledged.action,
        FinancialReportReleaseDistributionAuditAction.acknowledged,
      );
      expect(
        acknowledged.status,
        FinancialReportReleaseDistributionStatus.acknowledged,
      );

      expect(exception.id, 'audit-3');
      expect(
        exception.action,
        FinancialReportReleaseDistributionAuditAction.exception,
      );
    });

    test('creates clear audit events and sorts newest first', () {
      var sequence = 0;
      final service = FinancialReportReleaseDistributionAuditService(
        nextId: () => 'audit-${++sequence}',
      );

      final older = service.cleared(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        item: _item,
        actor: 'Controller',
        occurredAt: DateTime(2026, 2, 1, 9),
      );
      final newer = service.resolutionSaved(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        item: _item,
        resolution: _resolution(
          status: FinancialReportReleaseDistributionStatus.acknowledged,
          updatedAt: DateTime(2026, 2, 1, 10),
        ),
      );

      expect(
        older.action,
        FinancialReportReleaseDistributionAuditAction.cleared,
      );
      expect(older.status, isNull);
      expect(older.actor, 'Controller');

      final sorted = service.newestFirst([older, newer]);
      expect(sorted.first, newer);
      expect(sorted.last, older);
    });
  });
}

final _item = FinancialReportReleaseDistributionItem(
  recipient: FinancialReportReleaseDistributionRecipient(
    id: 'board-owners',
    name: 'Board / owners',
    role: 'Governance recipients',
    organization: 'Kaysir Advisory',
    channel: FinancialReportReleaseDistributionChannel.email,
    requiresAcknowledgement: true,
    dueDate: DateTime(2026, 2, 3),
    purpose: 'Governance review and formal distribution record.',
  ),
);

FinancialReportReleaseDistributionResolution _resolution({
  required FinancialReportReleaseDistributionStatus status,
  required DateTime updatedAt,
}) {
  return FinancialReportReleaseDistributionResolution(
    recipientId: 'board-owners',
    status: status,
    owner: 'Finance Lead',
    updatedAt: updatedAt,
    note: 'Distribution updated.',
    evidenceReference: 'DIST-BOARD',
  );
}
