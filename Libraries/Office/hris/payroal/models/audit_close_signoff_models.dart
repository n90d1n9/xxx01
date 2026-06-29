import 'audit_owner_worklist_models.dart';
import 'audit_pack_findings_models.dart';
import 'payroll_audit_pack_review_models.dart';
import 'payroll_audit_trail_models.dart';
import 'payroll_controls_evidence_matrix_models.dart';
import 'payroll_report_distribution_models.dart';

/// Defines the readiness state for an audit close sign-off gate.
enum AuditCloseSignoffGateStatus {
  blocked('Blocked'),
  actionNeeded('Action needed'),
  ready('Ready');

  final String label;

  const AuditCloseSignoffGateStatus(this.label);
}

/// Represents one auditable gate required before payroll audit sign-off.
class AuditCloseSignoffGate {
  final String id;
  final String title;
  final String owner;
  final String evidenceLabel;
  final String nextAction;
  final AuditCloseSignoffGateStatus status;

  const AuditCloseSignoffGate({
    required this.id,
    required this.title,
    required this.owner,
    required this.evidenceLabel,
    required this.nextAction,
    required this.status,
  });

  bool get isBlocked => status == AuditCloseSignoffGateStatus.blocked;

  bool get needsAction => status == AuditCloseSignoffGateStatus.actionNeeded;

  bool get isReady => status == AuditCloseSignoffGateStatus.ready;
}

/// Summarizes final audit close readiness for the payroll period.
class AuditCloseSignoffSummary {
  final String periodLabel;
  final List<AuditCloseSignoffGate> gates;

  const AuditCloseSignoffSummary({
    required this.periodLabel,
    required this.gates,
  });

  factory AuditCloseSignoffSummary.fromAuditReadiness({
    required String periodLabel,
    required AuditOwnerWorklistSummary ownerWorklist,
    required AuditPackFindingsSummary findings,
    required PayrollAuditPackReviewSummary auditPackReview,
    required PayrollControlsEvidenceMatrixSummary controlsMatrix,
    required PayrollReportDistributionSummary reportDistribution,
    required PayrollAuditTrailSummary auditTrail,
  }) {
    final gates = <AuditCloseSignoffGate>[
      AuditCloseSignoffGate(
        id: 'owner-actions',
        title: 'Owner action clearance',
        owner: 'Payroll Controller',
        evidenceLabel:
            '${ownerWorklist.totalItemCount} owner actions across ${ownerWorklist.ownerCount} owners',
        nextAction: ownerWorklist.nextAction,
        status: _statusFromCounts(
          blockedCount: ownerWorklist.blockedCount,
          actionCount:
              ownerWorklist.actionCount + ownerWorklist.readyReviewCount,
        ),
      ),
      AuditCloseSignoffGate(
        id: 'finding-closure',
        title: 'Audit finding closure',
        owner: 'Internal Audit',
        evidenceLabel:
            '${findings.closedCount}/${findings.findings.length} findings closed',
        nextAction: findings.nextAction,
        status: _statusFromCounts(
          blockedCount: 0,
          actionCount: findings.findings.length - findings.closedCount,
        ),
      ),
      AuditCloseSignoffGate(
        id: 'review-retention',
        title: 'Audit pack retention',
        owner: 'Payroll Controller',
        evidenceLabel:
            '${auditPackReview.retainedCount}/${auditPackReview.checkpoints.length} checkpoints retained',
        nextAction: auditPackReview.nextAction,
        status: _statusFromCounts(
          blockedCount: auditPackReview.blockedCount,
          actionCount: auditPackReview.readyCount,
        ),
      ),
      AuditCloseSignoffGate(
        id: 'control-evidence',
        title: 'Control evidence sign-off',
        owner: 'Internal Audit',
        evidenceLabel:
            '${controlsMatrix.completeCount}/${controlsMatrix.lines.length} controls complete',
        nextAction: controlsMatrix.nextAction,
        status: _statusFromCounts(
          blockedCount:
              controlsMatrix.blockedCount + controlsMatrix.missingCount,
          actionCount: controlsMatrix.readyCount,
        ),
      ),
      AuditCloseSignoffGate(
        id: 'distribution-receipts',
        title: 'Report receipt retention',
        owner: 'Finance Controller',
        evidenceLabel:
            '${reportDistribution.deliveredCount}/${reportDistribution.lines.length} receipts retained',
        nextAction: reportDistribution.nextAction,
        status: _statusFromCounts(
          blockedCount: reportDistribution.blockedCount,
          actionCount: reportDistribution.readyCount,
        ),
      ),
      AuditCloseSignoffGate(
        id: 'audit-trail',
        title: 'Audit trail completeness',
        owner: 'Payroll Controller',
        evidenceLabel:
            '${auditTrail.completedCount}/${auditTrail.events.length} events complete',
        nextAction: auditTrail.nextAction,
        status: _statusFromCounts(
          blockedCount: auditTrail.attentionCount,
          actionCount: 0,
        ),
      ),
    ]..sort(_compareGates);

    return AuditCloseSignoffSummary(periodLabel: periodLabel, gates: gates);
  }

  int get blockedCount => gates.where((gate) => gate.isBlocked).length;

  int get actionCount => gates.where((gate) => gate.needsAction).length;

  int get readyCount => gates.where((gate) => gate.isReady).length;

  bool get canSignOff => gates.isNotEmpty && readyCount == gates.length;

  double get readinessRate {
    if (gates.isEmpty) return 0;
    return readyCount / gates.length;
  }

  String get nextAction {
    if (blockedCount > 0) return 'Resolve $blockedCount sign-off blockers.';
    if (actionCount > 0) return 'Complete $actionCount sign-off actions.';
    return 'Payroll audit close is ready for final sign-off.';
  }
}

AuditCloseSignoffGateStatus _statusFromCounts({
  required int blockedCount,
  required int actionCount,
}) {
  if (blockedCount > 0) return AuditCloseSignoffGateStatus.blocked;
  if (actionCount > 0) return AuditCloseSignoffGateStatus.actionNeeded;
  return AuditCloseSignoffGateStatus.ready;
}

int _compareGates(AuditCloseSignoffGate left, AuditCloseSignoffGate right) {
  final status = left.status.index.compareTo(right.status.index);
  if (status != 0) return status;
  return left.title.compareTo(right.title);
}
