import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_signoff_audit_service.dart';

void main() {
  group('FinancialReportReleaseSignOffAuditService', () {
    test('creates signed and returned audit events from resolutions', () {
      var sequence = 0;
      final service = FinancialReportReleaseSignOffAuditService(
        nextId: () => 'audit-${++sequence}',
      );

      final signed = service.resolutionSaved(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        item: _item,
        resolution: _resolution(
          status: FinancialReportReleaseSignOffStatus.signed,
          signedAt: DateTime(2026, 2, 1, 10),
        ),
      );
      final returned = service.resolutionSaved(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        item: _item,
        resolution: _resolution(
          status: FinancialReportReleaseSignOffStatus.returned,
          signedAt: DateTime(2026, 2, 1, 11),
        ),
      );

      expect(signed.id, 'audit-1');
      expect(signed.action, FinancialReportReleaseSignOffAuditAction.signed);
      expect(signed.requirementTitle, 'Approved for release');
      expect(signed.actor, 'Finance Lead');
      expect(signed.status, FinancialReportReleaseSignOffStatus.signed);
      expect(signed.evidenceReference, 'SIGNOFF-APPROVER');

      expect(returned.id, 'audit-2');
      expect(
        returned.action,
        FinancialReportReleaseSignOffAuditAction.returned,
      );
      expect(returned.status, FinancialReportReleaseSignOffStatus.returned);
    });

    test('creates clear audit events and sorts newest first', () {
      var sequence = 0;
      final service = FinancialReportReleaseSignOffAuditService(
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
          status: FinancialReportReleaseSignOffStatus.signed,
          signedAt: DateTime(2026, 2, 1, 10),
        ),
      );

      expect(older.action, FinancialReportReleaseSignOffAuditAction.cleared);
      expect(older.status, isNull);
      expect(older.actor, 'Controller');

      final sorted = service.newestFirst([older, newer]);
      expect(sorted.first, newer);
      expect(sorted.last, older);
    });
  });
}

const _item = FinancialReportReleaseSignOffItem(
  requirement: FinancialReportReleaseSignOffRequirement(
    id: 'approved-for-release',
    role: FinancialReportReleaseSignOffRole.approver,
    title: 'Approved for release',
    description: 'Approve report pack release.',
    owner: 'Finance director',
    reference: 'Indonesia release approval',
  ),
);

FinancialReportReleaseSignOffResolution _resolution({
  required FinancialReportReleaseSignOffStatus status,
  required DateTime signedAt,
}) {
  return FinancialReportReleaseSignOffResolution(
    requirementId: 'approved-for-release',
    status: status,
    signer: 'Finance Lead',
    signedAt: signedAt,
    note: 'Release reviewed.',
    evidenceReference: 'SIGNOFF-APPROVER',
  );
}
