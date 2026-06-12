import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure_release_readiness.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_fingerprint.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_action_queue.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_archive_retention.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_control.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_evidence_manifest.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_statutory_filing.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_action_queue_service.dart';

void main() {
  group('FinancialReportReleaseActionQueueService', () {
    const service = FinancialReportReleaseActionQueueService();

    test('prioritizes open release work across control areas', () {
      final summary = service.summarize(
        controlSummary: _controlSummary(releaseComplete: false),
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.changed,
        ),
        signOffItems: [_returnedSignOff],
        distributionItems: [_overdueDistribution],
        evidenceManifest: _evidenceManifest,
        archiveSummary: _archiveSummary(
          FinancialReportReleaseArchiveStatus.ready,
        ),
        retentionSummary: _retentionSummary(
          FinancialReportReleaseArchiveRetentionStatus.reviewDue,
        ),
        statutoryFilingSummary: _statutoryFilingSummary,
        asOf: DateTime(2026, 2, 10),
      );

      expect(summary.totalCount, 7);
      expect(summary.criticalCount, 2);
      expect(summary.highCount, 4);
      expect(summary.overdueCount, 1);
      expect(summary.blockedCount, 3);
      expect(summary.nextAction, contains('Clear overdue distribution'));
      expect(
        summary.items.first.area,
        FinancialReportReleaseActionArea.distribution,
      );
      expect(
        summary.items.map((item) => item.title),
        isNot(contains('Management release copy')),
      );
      expect(
        summary.items.map((item) => item.title),
        contains('SPT Tahunan Badan support pack'),
      );
      final actionsByTitle = {
        for (final item in summary.items) item.title: item,
      };
      expect(
        actionsByTitle['Certify report package']?.destination,
        FinancialReportReleaseActionDestination.reportPack,
      );
      expect(
        actionsByTitle['Resolve returned sign-off: reviewed-by-controller']
            ?.destination,
        FinancialReportReleaseActionDestination.signOff,
      );
      expect(
        actionsByTitle['Prepare Sign-off audit trail']?.destination,
        FinancialReportReleaseActionDestination.evidenceManifest,
      );
      expect(
        actionsByTitle['Clear overdue distribution: Board / owners']
            ?.destination,
        FinancialReportReleaseActionDestination.distribution,
      );
      expect(
        actionsByTitle['Create release archive register']?.destination,
        FinancialReportReleaseActionDestination.archive,
      );
      expect(
        actionsByTitle['Complete archive retention review']?.destination,
        FinancialReportReleaseActionDestination.retention,
      );
      expect(
        actionsByTitle['SPT Tahunan Badan support pack']?.destination,
        FinancialReportReleaseActionDestination.statutoryFiling,
      );
    });

    test(
      'adds UKTM readiness actions for unreconciled management measures',
      () {
        final summary = service.summarize(
          controlSummary: _controlSummary(releaseComplete: false),
          packageIntegrity: _integrity(
            FinancialReportPackageIntegrityStatus.verified,
          ),
          managementMeasureReconciliations: [_unreconciledManagementMeasure],
          signOffItems: [_signedSignOff],
          distributionItems: [_acknowledgedDistribution],
          evidenceManifest: _readyEvidenceManifest,
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

        expect(summary.totalCount, 1);
        expect(summary.criticalCount, 1);
        expect(summary.blockedCount, 1);
        expect(
          summary.items.single.area,
          FinancialReportReleaseActionArea.managementMeasures,
        );
        expect(
          summary.items.single.title,
          'Resolve UKTM variance: adjusted operating performance',
        );
        expect(
          summary.items.single.destination,
          FinancialReportReleaseActionDestination
              .managementMeasureReconciliationCheck,
        );
        expect(summary.nextAction, contains('Variance 300'));
      },
    );

    test('uses the UKTM release checklist as the queue source of truth', () {
      final summary = service.summarize(
        controlSummary: _controlSummary(releaseComplete: false),
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
        ),
        managementMeasureReconciliations: [_unreconciledManagementMeasure],
        managementMeasureReleaseReadiness: _blockedManagementMeasureReadiness,
        signOffItems: [_signedSignOff],
        distributionItems: [_acknowledgedDistribution],
        evidenceManifest: _readyEvidenceManifest,
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

      expect(summary.totalCount, 4);
      expect(summary.criticalCount, 2);
      expect(summary.highCount, 2);
      expect(summary.blockedCount, 4);
      expect(
        summary.items.map((item) => item.title),
        containsAll([
          'Complete UKTM audit trail',
          'Complete UKTM approval',
          'Resolve UKTM reconciliation',
          'Prepare UKTM export evidence',
        ]),
      );
      expect(
        summary.items.map((item) => item.title),
        isNot(
          contains('Resolve UKTM variance: adjusted operating performance'),
        ),
      );
      expect(
        summary.items
            .firstWhere((item) => item.title == 'Complete UKTM audit trail')
            .destination,
        FinancialReportReleaseActionDestination.managementMeasureAuditTrail,
      );
      final destinations = {
        for (final item in summary.items) item.title: item.destination,
      };
      expect(
        destinations['Complete UKTM approval'],
        FinancialReportReleaseActionDestination.managementMeasureApprovalCheck,
      );
      expect(
        destinations['Resolve UKTM reconciliation'],
        FinancialReportReleaseActionDestination
            .managementMeasureReconciliationCheck,
      );
      expect(
        destinations['Prepare UKTM export evidence'],
        FinancialReportReleaseActionDestination
            .managementMeasureExportEvidenceCheck,
      );
      expect(summary.nextAction, startsWith('Complete UKTM audit trail:'));
    });

    test('returns a clear queue when release work is complete', () {
      final summary = service.summarize(
        controlSummary: _controlSummary(releaseComplete: true),
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
        ),
        signOffItems: [_signedSignOff],
        distributionItems: [_acknowledgedDistribution],
        evidenceManifest: _readyEvidenceManifest,
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

      expect(summary.isClear, isTrue);
      expect(summary.nextAction, 'Release action queue is clear.');
    });
  });
}

FinancialReportReleaseControlSummary _controlSummary({
  required bool releaseComplete,
}) {
  return FinancialReportReleaseControlSummary(
    packageVerified: releaseComplete,
    signOffComplete: releaseComplete,
    distributionComplete: releaseComplete,
    releaseComplete: releaseComplete,
    completionRatio: releaseComplete ? 1 : 0.3,
    headline: releaseComplete ? 'Ready to release' : 'Release in progress',
    nextAction: 'Complete all required release controls.',
    stages: const [],
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
  requirement: _requirement('reviewed-by-controller'),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'reviewed-by-controller',
    status: FinancialReportReleaseSignOffStatus.returned,
    signer: 'Controller',
    signedAt: DateTime(2026, 2, 2),
    note: 'Variance explanation needs follow-up.',
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
    role: FinancialReportReleaseSignOffRole.reviewer,
    title: id,
    description: 'Release sign-off.',
    owner: 'Controller',
    reference: 'Release approval',
  );
}

final _overdueDistribution = FinancialReportReleaseDistributionItem(
  recipient: _recipient('board-owners', DateTime(2026, 2, 3)),
);

final _acknowledgedDistribution = FinancialReportReleaseDistributionItem(
  recipient: _recipient('board-owners', DateTime(2026, 2, 3)),
  resolution: FinancialReportReleaseDistributionResolution(
    recipientId: 'board-owners',
    status: FinancialReportReleaseDistributionStatus.acknowledged,
    owner: 'Controller',
    updatedAt: DateTime(2026, 2, 2),
    note: 'Acknowledged.',
  ),
);

const _unreconciledManagementMeasure =
    FinancialReportManagementMeasureReconciliation(
      measure: FinancialReportManagementMeasure(
        id: 'uktm-adjusted-operating-performance',
        label: 'adjusted operating performance',
        owner: 'Controller',
        approvalStatus: FinancialReportManagementMeasureApprovalStatus.approved,
      ),
      subtotalAmount: 3800,
      measureAmount: 4100,
      adjustmentTotal: 0,
    );

const _blockedManagementMeasureReadiness =
    FinancialReportManagementMeasureReleaseReadinessSummary(
      items: [
        FinancialReportManagementMeasureReleaseCheckItem(
          kind: FinancialReportManagementMeasureReleaseCheckKind.auditTrail,
          title: 'Audit trail',
          status:
              FinancialReportManagementMeasureReleaseCheckStatus.actionRequired,
          metric: 'No event',
          detail:
              'Create UKTM approval or review audit evidence before archive.',
        ),
        FinancialReportManagementMeasureReleaseCheckItem(
          kind: FinancialReportManagementMeasureReleaseCheckKind.approval,
          title: 'Approval',
          status:
              FinancialReportManagementMeasureReleaseCheckStatus.actionRequired,
          metric: '0/1 approved',
          detail: 'Approve 1 UKTM management measure(s).',
        ),
        FinancialReportManagementMeasureReleaseCheckItem(
          kind: FinancialReportManagementMeasureReleaseCheckKind.reconciliation,
          title: 'Reconciliation',
          status:
              FinancialReportManagementMeasureReleaseCheckStatus.actionRequired,
          metric: '1 variance(s)',
          detail: 'Resolve 1 UKTM reconciliation variance(s).',
        ),
        FinancialReportManagementMeasureReleaseCheckItem(
          kind: FinancialReportManagementMeasureReleaseCheckKind.exportEvidence,
          title: 'Export evidence',
          status:
              FinancialReportManagementMeasureReleaseCheckStatus.actionRequired,
          metric: 'Blocked',
          detail:
              'Complete audit trail, approval, and reconciliation gates before export/archive.',
        ),
      ],
      readyCount: 0,
      actionRequiredCount: 4,
      readyForExport: false,
      completionRatio: 0,
      nextAction:
          'Audit trail: Create UKTM approval or review audit evidence before archive.',
    );

FinancialReportReleaseDistributionRecipient _recipient(
  String id,
  DateTime dueDate,
) {
  return FinancialReportReleaseDistributionRecipient(
    id: id,
    name: 'Board / owners',
    role: 'Governance recipients',
    organization: 'Kaysir Advisory',
    channel: FinancialReportReleaseDistributionChannel.secureLink,
    requiresAcknowledgement: true,
    dueDate: dueDate,
    purpose: 'Governance distribution evidence.',
  );
}

const _evidenceManifest = FinancialReportReleaseEvidenceManifestSummary(
  items: [
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.signOffAuditTrail,
      title: 'Sign-off audit trail',
      status: FinancialReportReleaseEvidenceStatus.missing,
      detail: 'Capture sign-off audit evidence.',
      reference: 'Release audit',
    ),
  ],
  readyCount: 0,
  attentionCount: 0,
  missingCount: 1,
  archiveReady: false,
  completionRatio: 0,
  nextAction: 'Capture sign-off audit evidence.',
);

const _readyEvidenceManifest = FinancialReportReleaseEvidenceManifestSummary(
  items: [
    FinancialReportReleaseEvidenceManifestItem(
      kind: FinancialReportReleaseEvidenceKind.signOffAuditTrail,
      title: 'Sign-off audit trail',
      status: FinancialReportReleaseEvidenceStatus.ready,
      detail: 'Ready.',
      reference: 'Release audit',
    ),
  ],
  readyCount: 1,
  attentionCount: 0,
  missingCount: 0,
  archiveReady: true,
  completionRatio: 1,
  nextAction: 'Ready.',
);

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
    evidenceItemCount: 2,
    readyEvidenceCount:
        status == FinancialReportReleaseArchiveStatus.blocked ? 1 : 2,
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
    nextReviewDate: DateTime(2026, 3, 1),
    daysRemaining: 3642,
    daysUntilReview: 19,
    reviewWindowDays: 90,
    nextAction: 'Archive custody review is due.',
    checkpoints: const [],
  );
}

final _statutoryFilingSummary = FinancialReportStatutoryFilingSummary(
  items: [
    FinancialReportStatutoryFilingItem(
      kind: FinancialReportStatutoryFilingKind.managementRelease,
      title: 'Management release copy',
      status: FinancialReportStatutoryFilingStatus.overdue,
      dueDate: DateTime(2026, 2, 2),
      owner: 'Controller',
      reference: 'Internal release',
      detail: 'Management release copy is late.',
      evidenceReference: '',
    ),
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
  overdueCount: 1,
  blockedCount: 0,
  completionRatio: 0,
  nextAction: 'Prepare annual corporate return support.',
);

const _completeStatutoryFilingSummary = FinancialReportStatutoryFilingSummary(
  items: [],
  completeCount: 0,
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
  evidenceItemCount: 2,
  note: 'Release file archived.',
);
