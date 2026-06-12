import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_management_measure.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_fingerprint.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_package_integrity.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_control.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_distribution.dart';
import 'package:kaysir/features/finance/accounting/models/financial_report_release_signoff.dart';
import 'package:kaysir/features/finance/accounting/services/financial_report_release_control_service.dart';

void main() {
  group('FinancialReportReleaseControlService', () {
    const service = FinancialReportReleaseControlService();

    test('summarizes blocked package integrity before release work', () {
      final summary = service.summarize(
        signOffItems: [_signedSignOff],
        distributionItems: [_acknowledgedDistribution],
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.notClosed,
        ),
        asOf: DateTime(2026, 2, 1),
      );

      expect(summary.releaseComplete, isFalse);
      expect(summary.completionRatio, closeTo(2 / 3, 0.001));
      expect(
        summary.nextAction,
        'Close the period to certify this report package.',
      );
      expect(
        summary.stages.first.status,
        FinancialReportReleaseControlStageStatus.blocked,
      );
    });

    test('points to sign-offs before distribution', () {
      final summary = service.summarize(
        signOffItems: [_signedSignOff, _pendingSignOff],
        distributionItems: [_pendingDistribution],
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
        ),
        asOf: DateTime(2026, 2, 1),
      );

      expect(summary.signOffComplete, isFalse);
      expect(summary.distributionComplete, isFalse);
      expect(summary.nextAction, 'Complete all required release sign-offs.');
      expect(
        summary.stages[1].status,
        FinancialReportReleaseControlStageStatus.actionNeeded,
      );
      expect(
        summary.stages.last.status,
        FinancialReportReleaseControlStageStatus.blocked,
      );
    });

    test('marks release complete when all stages are finished', () {
      final summary = service.summarize(
        signOffItems: [_signedSignOff],
        distributionItems: [_acknowledgedDistribution],
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
        ),
        asOf: DateTime(2026, 2, 1),
      );

      expect(summary.releaseComplete, isTrue);
      expect(summary.completionRatio, 1);
      expect(summary.headline, 'Ready to release');
      expect(
        summary.nextAction,
        'Release controls are complete. Archive the release evidence pack.',
      );
      expect(
        summary.stages.map((stage) => stage.status),
        everyElement(FinancialReportReleaseControlStageStatus.complete),
      );
    });

    test('adds UKTM readiness before distribution release completion', () {
      final summary = service.summarize(
        signOffItems: [_signedSignOff],
        distributionItems: [_acknowledgedDistribution],
        packageIntegrity: _integrity(
          FinancialReportPackageIntegrityStatus.verified,
        ),
        managementMeasureReconciliations: [_draftManagementMeasure],
        asOf: DateTime(2026, 2, 1),
      );

      expect(summary.releaseComplete, isFalse);
      expect(summary.completionRatio, closeTo(3 / 4, 0.001));
      expect(
        summary.nextAction,
        'Approve 1 UKTM management measure(s) before distribution.',
      );
      expect(
        summary.stages.map((stage) => stage.kind),
        contains(FinancialReportReleaseControlStageKind.managementMeasures),
      );
      expect(
        summary.stages[1].status,
        FinancialReportReleaseControlStageStatus.actionNeeded,
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
  requirement: _requirement('reviewed-by-controller'),
);

final _acknowledgedDistribution = FinancialReportReleaseDistributionItem(
  recipient: _recipient('board-owners'),
  resolution: FinancialReportReleaseDistributionResolution(
    recipientId: 'board-owners',
    status: FinancialReportReleaseDistributionStatus.acknowledged,
    owner: 'Controller',
    updatedAt: DateTime(2026, 2, 1, 12),
    note: 'Acknowledged.',
  ),
);

final _pendingDistribution = FinancialReportReleaseDistributionItem(
  recipient: _recipient('board-owners'),
);

const _draftManagementMeasure = FinancialReportManagementMeasureReconciliation(
  measure: FinancialReportManagementMeasure(
    id: 'uktm-operating-performance',
    label: 'management operating performance',
    owner: 'Controller',
    approvalStatus: FinancialReportManagementMeasureApprovalStatus.draft,
  ),
  subtotalAmount: 3800,
  measureAmount: 3800,
  adjustmentTotal: 0,
);

FinancialReportReleaseSignOffRequirement _requirement(String id) {
  return FinancialReportReleaseSignOffRequirement(
    id: id,
    role: FinancialReportReleaseSignOffRole.approver,
    title: id,
    description: 'Release approval.',
    owner: 'Finance lead',
    reference: 'Release control',
  );
}

FinancialReportReleaseDistributionRecipient _recipient(String id) {
  return FinancialReportReleaseDistributionRecipient(
    id: id,
    name: 'Board / owners',
    role: 'Governance recipients',
    organization: 'Kaysir Advisory',
    channel: FinancialReportReleaseDistributionChannel.secureLink,
    requiresAcknowledgement: true,
    dueDate: DateTime(2026, 2, 3),
    purpose: 'Governance review and formal distribution record.',
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
