import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_fingerprint.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_evidence_manifest.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_evidence_manifest_service.dart';

void main() {
  group('FinancialReportReleaseEvidenceManifestService', () {
    const service = FinancialReportReleaseEvidenceManifestService();

    test('marks archive incomplete when required evidence is missing', () {
      final summary = service.buildManifest(
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.notClosed,
        ),
        signOffItems: [_pendingSignOff],
        signOffAuditEvents: const [],
        distributionItems: const [],
        distributionAuditEvents: const [],
      );

      expect(summary.archiveReady, isFalse);
      expect(summary.missingCount, greaterThan(0));
      expect(
        summary.nextAction,
        'Period close certificate: Close the period to create the release certificate.',
      );
      expect(
        summary.items.first.status,
        FinancialReportReleaseEvidenceStatus.missing,
      );
    });

    test('marks archive ready when all release evidence is available', () {
      final summary = service.buildManifest(
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
          closeRecord: _closedRecord(),
        ),
        signOffItems: [_signedSignOff],
        signOffAuditEvents: [_signOffAuditEvent],
        managementMeasureAuditEvents: [_managementMeasureAuditEvent],
        distributionItems: [_acknowledgedDistribution],
        distributionAuditEvents: [_distributionAuditEvent],
      );

      expect(summary.archiveReady, isTrue);
      expect(summary.readyCount, summary.items.length);
      expect(summary.attentionCount, 0);
      expect(summary.missingCount, 0);
      expect(summary.completionRatio, 1);
      expect(
        summary.nextAction,
        'Release evidence manifest is complete. Archive it with the report pack.',
      );
    });

    test('requires UKTM audit trail before archive', () {
      final summary = service.buildManifest(
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
          closeRecord: _closedRecord(),
        ),
        signOffItems: [_signedSignOff],
        signOffAuditEvents: [_signOffAuditEvent],
        distributionItems: [_acknowledgedDistribution],
        distributionAuditEvents: [_distributionAuditEvent],
      );

      final uktmItem = summary.items.firstWhere(
        (item) =>
            item.kind ==
            FinancialReportReleaseEvidenceKind.managementMeasureAuditTrail,
      );

      expect(summary.archiveReady, isFalse);
      expect(uktmItem.status, FinancialReportReleaseEvidenceStatus.missing);
      expect(
        summary.nextAction,
        'UKTM audit trail: Capture UKTM approval audit events before archive.',
      );
    });
  });
}

final _signedSignOff = FinancialReportReleaseSignOffItem(
  requirement: _requirement('approved-for-release'),
  resolution: FinancialReportReleaseSignOffResolution(
    requirementId: 'approved-for-release',
    status: FinancialReportReleaseSignOffStatus.signed,
    signer: 'Finance Lead',
    signedAt: DateTime(2026, 2, 1, 10),
    note: 'Signed.',
  ),
);

final _pendingSignOff = FinancialReportReleaseSignOffItem(
  requirement: _requirement('approved-for-release'),
);

final _signOffAuditEvent = FinancialReportReleaseSignOffAuditEvent(
  id: 'signoff-audit-1',
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  requirementId: 'approved-for-release',
  requirementTitle: 'Approved for release',
  role: FinancialReportReleaseSignOffRole.approver,
  action: FinancialReportReleaseSignOffAuditAction.signed,
  occurredAt: DateTime(2026, 2, 1, 10),
  actor: 'Finance Lead',
  status: FinancialReportReleaseSignOffStatus.signed,
  note: 'Signed.',
);

final _managementMeasureAuditEvent = FinancialReportManagementMeasureAuditEvent(
  id: 'uktm-audit-1',
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  measureId: 'uktm-adjusted-operating-performance',
  measureLabel: 'Adjusted operating performance',
  action: FinancialReportManagementMeasureAuditAction.approved,
  occurredAt: DateTime(2026, 2, 1, 11),
  actor: 'Finance Lead',
  status: FinancialReportManagementMeasureApprovalStatus.approved,
  note: 'Approved for release.',
);

final _acknowledgedDistribution = FinancialReportReleaseDistributionItem(
  recipient: _recipient,
  resolution: FinancialReportReleaseDistributionResolution(
    recipientId: 'board-owners',
    status: FinancialReportReleaseDistributionStatus.acknowledged,
    owner: 'Finance Lead',
    updatedAt: DateTime(2026, 2, 1, 13),
    note: 'Acknowledged.',
  ),
);

final _distributionAuditEvent = FinancialReportReleaseDistributionAuditEvent(
  id: 'distribution-audit-1',
  periodKey: '20260101-20260131',
  periodLabel: 'Jan 2026',
  recipientId: 'board-owners',
  recipientName: 'Board / owners',
  channel: FinancialReportReleaseDistributionChannel.secureLink,
  action: FinancialReportReleaseDistributionAuditAction.acknowledged,
  occurredAt: DateTime(2026, 2, 1, 13),
  actor: 'Finance Lead',
  status: FinancialReportReleaseDistributionStatus.acknowledged,
  note: 'Acknowledged.',
);

FinancialReportReleaseSignOffRequirement _requirement(String id) {
  return FinancialReportReleaseSignOffRequirement(
    id: id,
    role: FinancialReportReleaseSignOffRole.approver,
    title: 'Approved for release',
    description: 'Approve report pack release.',
    owner: 'Finance director',
    reference: 'Release control',
  );
}

final _recipient = FinancialReportReleaseDistributionRecipient(
  id: 'board-owners',
  name: 'Board / owners',
  role: 'Governance recipients',
  organization: 'Kaysir Advisory',
  channel: FinancialReportReleaseDistributionChannel.secureLink,
  requiresAcknowledgement: true,
  dueDate: DateTime(2026, 2, 3),
  purpose: 'Governance review and formal distribution record.',
);

FinancialReportPackageIntegrity _integrity(
  FinancialReportPackageIntegrityStatus status, {
  FinancialPeriodCloseRecord? closeRecord,
}) {
  return FinancialReportPackageIntegrity(
    status: status,
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
