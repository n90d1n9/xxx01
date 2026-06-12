import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive_retention.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_archive_retention_service.dart';

void main() {
  group('FinancialReportReleaseArchiveRetentionService', () {
    const service = FinancialReportReleaseArchiveRetentionService();

    test('waits for archive register before retention monitoring', () {
      final summary = service.summarize(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        record: null,
        asOf: DateTime(2026, 2, 1),
      );

      expect(
        summary.status,
        FinancialReportReleaseArchiveRetentionStatus.notArchived,
      );
      expect(summary.hasArchive, isFalse);
      expect(summary.checkpoints, isEmpty);
      expect(summary.nextAction, contains('Create the release archive'));
    });

    test('marks active retention before the review window', () {
      final summary = service.summarize(
        periodKey: _record.periodKey,
        periodLabel: _record.periodLabel,
        record: _record,
        asOf: DateTime(2026, 5, 1),
      );

      expect(
        summary.status,
        FinancialReportReleaseArchiveRetentionStatus.active,
      );
      expect(summary.isCurrent, isTrue);
      expect(summary.retainUntil, DateTime(2036, 1, 31));
      expect(summary.nextReviewDate, DateTime(2027, 2, 1));
      expect(summary.daysRemaining, greaterThan(3000));
      expect(summary.daysUntilReview, greaterThan(90));
      expect(summary.checkpoints, hasLength(3));
    });

    test('flags annual custody review inside the review window', () {
      final summary = service.summarize(
        periodKey: _record.periodKey,
        periodLabel: _record.periodLabel,
        record: _record,
        asOf: DateTime(2027, 1, 10),
      );

      expect(
        summary.status,
        FinancialReportReleaseArchiveRetentionStatus.reviewDue,
      );
      expect(summary.nextReviewDate, DateTime(2027, 2, 1));
      expect(summary.daysUntilReview, 22);
      expect(summary.nextAction, contains('custody review'));
    });

    test('moves next review forward from latest retention review event', () {
      final summary = service.summarize(
        periodKey: _record.periodKey,
        periodLabel: _record.periodLabel,
        record: _record,
        asOf: DateTime(2027, 2, 10),
        auditEvents: [
          FinancialReportReleaseArchiveAuditEvent(
            id: 'archive-review-1',
            periodKey: _record.periodKey,
            periodLabel: _record.periodLabel,
            archiveId: _record.archiveId,
            action: FinancialReportReleaseArchiveAuditAction.retentionReviewed,
            occurredAt: DateTime(2027, 1, 10, 9),
            actor: 'Controller',
            note: 'Custody reviewed.',
          ),
        ],
      );

      expect(
        summary.status,
        FinancialReportReleaseArchiveRetentionStatus.active,
      );
      expect(summary.lastReviewAt, DateTime(2027, 1, 10));
      expect(summary.lastReviewActor, 'Controller');
      expect(summary.nextReviewDate, DateTime(2028, 1, 10));
      expect(summary.daysUntilReview, greaterThan(300));
    });

    test('flags expired retention after retain until date', () {
      final summary = service.summarize(
        periodKey: _record.periodKey,
        periodLabel: _record.periodLabel,
        record: _record,
        asOf: DateTime(2036, 2, 2),
      );

      expect(
        summary.status,
        FinancialReportReleaseArchiveRetentionStatus.expired,
      );
      expect(summary.daysRemaining, -2);
      expect(summary.nextAction, contains('passed its retention deadline'));
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
