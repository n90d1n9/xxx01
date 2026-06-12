import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_fingerprint.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_evidence_manifest.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_archive_service.dart';

void main() {
  group('FinancialReportReleaseArchiveService', () {
    const service = FinancialReportReleaseArchiveService();

    test('blocks archive creation until evidence manifest is complete', () {
      final summary = service.summarize(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        evidenceManifest: _blockedManifest,
      );

      expect(summary.status, FinancialReportReleaseArchiveStatus.blocked);
      expect(summary.canArchive, isFalse);
      expect(summary.nextAction, contains('Distribution register'));
      expect(
        () => service.createRecord(
          periodKey: '20260101-20260131',
          periodLabel: 'Jan 2026',
          packageIntegrity: _integrity(),
          evidenceManifest: _blockedManifest,
          archivedBy: 'Controller',
        ),
        throwsStateError,
      );
    });

    test('creates a sealed archive register with retention deadline', () {
      final record = service.createRecord(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        packageIntegrity: _integrity(closeRecord: _closedRecord()),
        evidenceManifest: _readyManifest,
        archivedBy: 'Controller',
        custodian: 'Finance archive owner',
        storageLocation: 'Encrypted archive vault',
        note: 'Release file archived after board acknowledgement.',
        archivedAt: DateTime(2026, 2, 1, 14),
      );
      final summary = service.summarize(
        periodKey: '20260101-20260131',
        periodLabel: 'Jan 2026',
        evidenceManifest: _readyManifest,
        record: record,
      );

      expect(record.archiveId, 'FR-ARCH-2026010120260131-ABCDEF123456');
      expect(record.retainUntil, DateTime(2036, 1, 31));
      expect(record.custodian, 'Finance archive owner');
      expect(record.storageLocation, 'Encrypted archive vault');
      expect(record.evidenceItemCount, 2);
      expect(record.shortFingerprint, 'ABCDEF123456');
      expect(summary.status, FinancialReportReleaseArchiveStatus.archived);
      expect(summary.isArchived, isTrue);
      expect(summary.nextAction, contains(record.archiveId));
    });
  });
}

const _readyManifest = FinancialReportReleaseEvidenceManifestSummary(
  items: [
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.closeCertificate,
      title: 'Period close certificate',
      status: FinancialReportReleaseEvidenceStatus.ready,
      detail: 'Closed by Controller with 0 blocker(s).',
      reference: 'Close certificate',
    ),
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.packageFingerprint,
      title: 'Package fingerprint',
      status: FinancialReportReleaseEvidenceStatus.ready,
      detail: 'The displayed report package matches the closed package.',
      reference: 'ABCDEF123456',
    ),
  ],
  readyCount: 2,
  attentionCount: 0,
  missingCount: 0,
  archiveReady: true,
  completionRatio: 1,
  nextAction:
      'Release evidence manifest is complete. Archive it with the report pack.',
);

const _blockedManifest = FinancialReportReleaseEvidenceManifestSummary(
  items: [
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.distributionRegister,
      title: 'Distribution register',
      status: FinancialReportReleaseEvidenceStatus.missing,
      detail: 'Configure report pack recipients before archive.',
      reference: 'Release recipients',
    ),
  ],
  readyCount: 0,
  attentionCount: 0,
  missingCount: 1,
  archiveReady: false,
  completionRatio: 0,
  nextAction:
      'Distribution register: Configure report pack recipients before archive.',
);

FinancialReportPackageIntegrity _integrity({
  FinancialPeriodCloseRecord? closeRecord,
}) {
  return FinancialReportPackageIntegrity(
    status: FinancialReportPackageIntegrityStatus.verified,
    closeRecord: closeRecord,
    currentFingerprint: const FinancialReportPackageFingerprint(
      algorithm: 'SHA-256',
      hash: 'abcdef1234567890',
    ),
  );
}

FinancialPeriodCloseRecord _closedRecord() {
  return FinancialPeriodCloseRecord(
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    status: FinancialPeriodCloseStatus.closed,
    closedAt: DateTime(2026, 2, 1, 10),
    closedBy: 'Controller',
    reopenedAt: null,
    reopenedBy: null,
    reopenReason: null,
    checklistReadinessRatio: 1,
    blockerCount: 0,
    reportGeneratedAt: DateTime(2026, 2, 1, 9),
    reportPackageHash: 'abcdef1234567890',
    reportPackageHashAlgorithm: 'SHA-256',
  );
}
