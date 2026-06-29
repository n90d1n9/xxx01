import 'payroll_archive_models.dart';
import 'payroll_audit_trail_models.dart';
import 'payroll_controls_evidence_matrix_models.dart';
import 'payroll_report_distribution_models.dart';
import 'payroll_reports_hub_models.dart';

/// Defines the reviewer readiness state for the payroll audit package.
enum PayrollAuditPackReviewStatus {
  blocked('Blocked'),
  ready('Ready'),
  retained('Retained');

  final String label;

  const PayrollAuditPackReviewStatus(this.label);
}

/// Represents one review checkpoint for a retained payroll audit package.
class PayrollAuditPackReviewCheckpoint {
  final String id;
  final String title;
  final String owner;
  final String evidenceLabel;
  final bool isComplete;
  final List<String> blockers;

  const PayrollAuditPackReviewCheckpoint({
    required this.id,
    required this.title,
    required this.owner,
    required this.evidenceLabel,
    required this.isComplete,
    required this.blockers,
  });

  bool get hasBlockers => blockers.isNotEmpty;

  bool get isReady => !isComplete && blockers.isEmpty;

  PayrollAuditPackReviewStatus get status {
    if (hasBlockers) return PayrollAuditPackReviewStatus.blocked;
    if (isComplete) return PayrollAuditPackReviewStatus.retained;
    return PayrollAuditPackReviewStatus.ready;
  }

  String get statusLabel => status.label;
}

/// Summarizes whether the payroll close package is reviewer-ready.
class PayrollAuditPackReviewSummary {
  final String reviewId;
  final String periodLabel;
  final DateTime retentionUntil;
  final List<PayrollAuditPackReviewCheckpoint> checkpoints;

  const PayrollAuditPackReviewSummary({
    required this.reviewId,
    required this.periodLabel,
    required this.retentionUntil,
    required this.checkpoints,
  });

  factory PayrollAuditPackReviewSummary.fromAuditSignals({
    required PayrollArchivePackageSummary archivePackage,
    required PayrollReportsHubSummary reportsHub,
    required PayrollReportDistributionSummary reportDistribution,
    required PayrollControlsEvidenceMatrixSummary controlsMatrix,
    required PayrollAuditTrailSummary auditTrail,
  }) {
    return PayrollAuditPackReviewSummary(
      reviewId: 'APR-${archivePackage.packageId.replaceAll('AR-', '')}',
      periodLabel: archivePackage.periodLabel,
      retentionUntil: archivePackage.retentionUntil,
      checkpoints: [
        PayrollAuditPackReviewCheckpoint(
          id: 'archive-retention',
          title: 'Archive retention',
          owner: 'Payroll Controller',
          evidenceLabel:
              '${archivePackage.capturedCount}/${archivePackage.evidenceItems.length} archive items retained',
          isComplete:
              archivePackage.status == PayrollArchivePackageStatus.archived,
          blockers: [
            if (archivePackage.status != PayrollArchivePackageStatus.archived)
              archivePackage.nextAction,
          ],
        ),
        PayrollAuditPackReviewCheckpoint(
          id: 'report-artifacts',
          title: 'Report artifacts',
          owner: 'Finance Controller',
          evidenceLabel:
              '${reportsHub.completeCount}/${reportsHub.items.length} report artifacts complete',
          isComplete: reportsHub.completeCount == reportsHub.items.length,
          blockers: [
            if (reportsHub.blockedCount > 0) reportsHub.nextAction,
            if (reportsHub.readyCount > 0) reportsHub.nextAction,
          ],
        ),
        PayrollAuditPackReviewCheckpoint(
          id: 'distribution-receipts',
          title: 'Distribution receipts',
          owner: 'Payroll Controller',
          evidenceLabel:
              '${reportDistribution.deliveredCount}/${reportDistribution.lines.length} packages delivered',
          isComplete:
              reportDistribution.deliveredCount ==
              reportDistribution.lines.length,
          blockers: [
            if (reportDistribution.blockedCount > 0)
              reportDistribution.nextAction,
            if (reportDistribution.readyCount > 0)
              reportDistribution.nextAction,
          ],
        ),
        PayrollAuditPackReviewCheckpoint(
          id: 'control-evidence',
          title: 'Control evidence matrix',
          owner: 'Internal Audit',
          evidenceLabel:
              '${controlsMatrix.completeCount}/${controlsMatrix.lines.length} controls traced',
          isComplete:
              controlsMatrix.status ==
              PayrollControlsEvidenceMatrixStatus.complete,
          blockers: [
            if (controlsMatrix.status !=
                PayrollControlsEvidenceMatrixStatus.complete)
              controlsMatrix.nextAction,
          ],
        ),
        PayrollAuditPackReviewCheckpoint(
          id: 'audit-trail',
          title: 'Audit trail completeness',
          owner: 'Payroll Controller',
          evidenceLabel:
              '${auditTrail.completedCount}/${auditTrail.events.length} events complete',
          isComplete: auditTrail.attentionCount == 0,
          blockers: [if (auditTrail.attentionCount > 0) auditTrail.nextAction],
        ),
      ],
    );
  }

  int get blockedCount =>
      checkpoints.where((checkpoint) => checkpoint.hasBlockers).length;

  int get readyCount =>
      checkpoints.where((checkpoint) => checkpoint.isReady).length;

  int get retainedCount =>
      checkpoints.where((checkpoint) => checkpoint.isComplete).length;

  double get readinessRate {
    if (checkpoints.isEmpty) return 0;
    return retainedCount / checkpoints.length;
  }

  PayrollAuditPackReviewStatus get status {
    if (blockedCount > 0) return PayrollAuditPackReviewStatus.blocked;
    if (retainedCount == checkpoints.length) {
      return PayrollAuditPackReviewStatus.retained;
    }
    return PayrollAuditPackReviewStatus.ready;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount audit pack review blockers.';
    }
    if (readyCount > 0) return 'Retain $readyCount audit review checkpoints.';
    return 'Payroll audit pack is retained and reviewer-ready.';
  }
}
