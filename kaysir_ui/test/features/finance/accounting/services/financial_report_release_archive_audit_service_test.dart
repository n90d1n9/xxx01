import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_archive_audit_service.dart';

void main() {
  group('FinancialReportReleaseArchiveAuditService', () {
    test('records archive creation from the sealed record', () {
      final service = FinancialReportReleaseArchiveAuditService(
        nextId: () => 'archive-audit-1',
      );

      final event = service.archived(_record);

      expect(event.id, 'archive-audit-1');
      expect(event.action, FinancialReportReleaseArchiveAuditAction.archived);
      expect(event.archiveId, _record.archiveId);
      expect(event.actor, 'Controller');
      expect(event.custodian, 'Finance archive owner');
      expect(event.storageLocation, 'Encrypted archive vault');
      expect(event.retainUntil, DateTime(2036, 1, 31));
      expect(event.shortFingerprint, 'ABCDEF123456');
      expect(event.note, 'Release file archived.');
    });

    test('records clearing and sorts newest events first', () {
      var next = 0;
      final service = FinancialReportReleaseArchiveAuditService(
        nextId: () => 'archive-audit-${++next}',
      );

      final archived = service.archived(_record);
      final cleared = service.cleared(
        periodKey: _record.periodKey,
        periodLabel: _record.periodLabel,
        actor: 'Controller',
        record: _record,
        occurredAt: DateTime(2026, 2, 2, 9),
      );

      expect(cleared.action, FinancialReportReleaseArchiveAuditAction.cleared);
      expect(cleared.archiveId, _record.archiveId);
      expect(cleared.note, '${_record.archiveId} archive record cleared.');
      expect(service.newestFirst([archived, cleared]), [cleared, archived]);
    });

    test('records retention review and next review date', () {
      final service = FinancialReportReleaseArchiveAuditService(
        nextId: () => 'archive-review-1',
      );

      final event = service.retentionReviewed(
        record: _record,
        actor: 'Controller',
        note: 'Custody reviewed.',
        occurredAt: DateTime(2027, 1, 10, 9),
      );

      expect(
        event.action,
        FinancialReportReleaseArchiveAuditAction.retentionReviewed,
      );
      expect(event.nextReviewDate, DateTime(2028, 1, 10));
      expect(event.note, 'Custody reviewed.');
    });

    test('records disposal review request', () {
      final service = FinancialReportReleaseArchiveAuditService(
        nextId: () => 'archive-disposal-1',
      );

      final event = service.disposalReviewRequested(
        record: _record,
        actor: 'Controller',
        note: '',
        occurredAt: DateTime(2036, 2, 1, 9),
      );

      expect(
        event.action,
        FinancialReportReleaseArchiveAuditAction.disposalReviewRequested,
      );
      expect(event.note, contains('disposal or legal-hold review'));
      expect(event.retainUntil, DateTime(2036, 1, 31));
    });
  });
}

final _record = FinancialReportReleaseArchiveRecord(
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  archiveId: 'FR-ARCH-2026010120260131-ABCDEF123456',
  archivedAt: DateTime(2026, 2, 1, 14),
  archivedBy: 'Controller',
  custodian: 'Finance archive owner',
  storageLocation: 'Encrypted archive vault',
  retentionPolicy: 'Indonesia statutory/tax archive policy',
  retainUntil: DateTime(2036, 1, 31),
  packageFingerprint: 'abcdef1234567890',
  packageFingerprintAlgorithm: 'SHA-256',
  evidenceItemCount: 2,
  note: 'Release file archived.',
);
