import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_pack.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_fingerprint.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive_retention.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_milestone.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_statutory_filing.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_milestone_service.dart';

void main() {
  group('FinancialReportReleaseMilestoneService', () {
    const service = FinancialReportReleaseMilestoneService();

    test('builds dated release milestones across post-close work', () {
      final summary = service.summarize(
        pack: _pack(),
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.changed,
        ),
        signOffItems: [_returnedSignOff],
        distributionItems: [_overdueDistribution],
        archiveSummary: _archiveSummary(
          FinancialReportReleaseArchiveStatus.ready,
        ),
        retentionSummary: _retentionSummary(
          FinancialReportReleaseArchiveRetentionStatus.active,
          record: _archiveRecord,
        ),
        statutoryFilingSummary: _statutoryFilingSummary,
        asOf: DateTime(2026, 2, 10),
      );

      expect(summary.totalCount, 6);
      expect(summary.blockedCount, 2);
      expect(summary.overdueCount, 2);
      expect(summary.dueSoonCount, 1);
      expect(summary.upcomingCount, 1);
      expect(summary.completeCount, 0);
      expect(summary.nextAction, contains('Closed package certification'));
      expect(
        summary.items.first.status,
        FinancialReportReleaseMilestoneStatus.blocked,
      );
      expect(
        summary.items.map((item) => item.title),
        contains('SPT Tahunan Badan support pack'),
      );
    });

    test('keeps active retention as a future milestone', () {
      final summary = service.summarize(
        pack: _pack(),
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
        ),
        signOffItems: [_signedSignOff],
        distributionItems: [_acknowledgedDistribution],
        archiveSummary: _archiveSummary(
          FinancialReportReleaseArchiveStatus.archived,
          record: _archiveRecord,
        ),
        retentionSummary: _retentionSummary(
          FinancialReportReleaseArchiveRetentionStatus.active,
          record: _archiveRecord,
        ),
        statutoryFilingSummary: _completeStatutoryFilingSummary,
        asOf: DateTime(2026, 2, 10),
      );

      expect(summary.totalCount, 6);
      expect(summary.completeCount, 5);
      expect(summary.upcomingCount, 1);
      expect(summary.nextAction, contains('Archive retention review'));
    });
  });
}

FinancialReportPack _pack() {
  return FinancialReportPack(
    entityName: 'Kaysir Demo',
    frameworkName: 'SAK Indonesia / IFRS aligned',
    jurisdiction: 'Indonesia',
    presentationCurrency: 'IDR',
    periodLabel: 'Jan 2026',
    asOfLabel: 'Jan 31, 2026',
    periodStart: DateTime(2026, 1, 1),
    periodEnd: DateTime(2026, 1, 31),
    generatedAt: DateTime(2026, 2, 1, 9),
    statements: const [],
    notes: const [],
    complianceItems: const [],
    metrics: const [],
  );
}

FinancialReportPackageIntegrity _integrity(
  FinancialReportPackageIntegrityStatus status,
) {
  return FinancialReportPackageIntegrity(
    status: status,
    closeRecord: null,
    currentFingerprint: const FinancialReportPackageFingerprint(
      algorithm: 'SHA-256',
      hash: 'abcdef1234567890',
    ),
  );
}

final _returnedSignOff = FinancialReportReleaseSignOffItem(
  requirement: _requirement('approved-for-release'),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'approved-for-release',
    status: FinancialReportReleaseSignOffStatus.returned,
    signer: 'Finance lead',
    signedAt: DateTime(2026, 2, 2),
    note: 'Release approval returned for follow-up.',
  ),
);

final _signedSignOff = FinancialReportReleaseSignOffItem(
  requirement: _requirement('approved-for-release'),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'approved-for-release',
    status: FinancialReportReleaseSignOffStatus.signed,
    signer: 'Finance lead',
    signedAt: DateTime(2026, 2, 2),
    note: 'Approved.',
  ),
);

FinancialReportReleaseSignOffRequirement _requirement(String id) {
  return FinancialReportReleaseSignOffRequirement(
    id: id,
    role: FinancialReportReleaseSignOffRole.approver,
    title: 'Approved for release',
    description: 'Approve report pack release.',
    owner: 'Finance director',
    reference: 'Indonesia release approval',
  );
}

final _overdueDistribution = FinancialReportReleaseDistributionItem(
  recipient: _recipient(DateTime(2026, 2, 3)),
);

final _acknowledgedDistribution = FinancialReportReleaseDistributionItem(
  recipient: _recipient(DateTime(2026, 2, 3)),
  resolution: FinancialReportReleaseDistributionResolution(
    recipientId: 'board-owners',
    status: FinancialReportReleaseDistributionStatus.acknowledged,
    owner: 'Controller',
    updatedAt: DateTime(2026, 2, 2),
    note: 'Acknowledged.',
  ),
);

FinancialReportReleaseDistributionRecipient _recipient(DateTime dueDate) {
  return FinancialReportReleaseDistributionRecipient(
    id: 'board-owners',
    name: 'Board / owners',
    role: 'Governance recipients',
    organization: 'Kaysir Advisory',
    channel: FinancialReportReleaseDistributionChannel.secureLink,
    requiresAcknowledgement: true,
    dueDate: dueDate,
    purpose: 'Governance distribution evidence.',
  );
}

FinancialReportReleaseArchiveSummary _archiveSummary(
  FinancialReportReleaseArchiveStatus status, {
  FinancialReportReleaseArchiveRecord? record,
}) {
  return FinancialReportReleaseArchiveSummary(
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    status: status,
    record: record,
    evidenceReady: status != FinancialReportReleaseArchiveStatus.blocked,
    evidenceItemCount: 6,
    readyEvidenceCount:
        status == FinancialReportReleaseArchiveStatus.blocked ? 4 : 6,
    nextAction: 'Archive the release evidence pack.',
  );
}

FinancialReportReleaseArchiveRetentionSummary _retentionSummary(
  FinancialReportReleaseArchiveRetentionStatus status, {
  FinancialReportReleaseArchiveRecord? record,
}) {
  return FinancialReportReleaseArchiveRetentionSummary(
    periodKey: '20260101-20260131',
    periodLabel: 'Jan 2026',
    status: status,
    record: record,
    asOf: DateTime(2026, 2, 10),
    retainUntil: DateTime(2036, 1, 31),
    nextReviewDate: DateTime(2027, 2, 1),
    daysRemaining: 3642,
    daysUntilReview: 356,
    reviewWindowDays: 90,
    nextAction: 'Archive custody is current.',
    checkpoints: const [],
  );
}

final _statutoryFilingSummary = FinancialReportStatutoryFilingSummary(
  items: [
    FinancialReportStatutoryFilingItem(
      kind: FinancialReportStatutoryFilingKind.annualCorporateTaxSupport,
      title: 'SPT Tahunan Badan support pack',
      status: FinancialReportStatutoryFilingStatus.dueSoon,
      dueDate: DateTime(2026, 2, 18),
      owner: 'Tax / statutory archive',
      reference: 'DJP annual tax support',
      detail: 'Prepare annual corporate return support.',
      evidenceReference: '',
    ),
  ],
  completeCount: 0,
  dueSoonCount: 1,
  overdueCount: 0,
  blockedCount: 0,
  completionRatio: 0,
  nextAction: 'Prepare annual corporate return support.',
);

final _completeStatutoryFilingSummary = FinancialReportStatutoryFilingSummary(
  items: [
    FinancialReportStatutoryFilingItem(
      kind: FinancialReportStatutoryFilingKind.annualCorporateTaxSupport,
      title: 'SPT Tahunan Badan support pack',
      status: FinancialReportStatutoryFilingStatus.complete,
      dueDate: DateTime(2026, 5, 31),
      owner: 'Tax / statutory archive',
      reference: 'DJP annual tax support',
      detail: 'Tax support archive is ready.',
      evidenceReference: 'DIST-TAX',
    ),
  ],
  completeCount: 1,
  dueSoonCount: 0,
  overdueCount: 0,
  blockedCount: 0,
  completionRatio: 1,
  nextAction: 'Current.',
);

final _archiveRecord = FinancialReportReleaseArchiveRecord(
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
  evidenceItemCount: 6,
  note: 'Archived.',
);
