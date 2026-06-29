import 'audit_close_attestation_models.dart';
import 'audit_owner_worklist_models.dart';

/// Defines the readiness state for one audit handoff package line.
enum AuditHandoffPackageLineStatus {
  blocked('Blocked'),
  pending('Pending'),
  ready('Ready');

  final String label;

  const AuditHandoffPackageLineStatus(this.label);
}

/// Represents one artifact or action included in the audit handoff package.
class AuditHandoffPackageLine {
  final String id;
  final String title;
  final String owner;
  final String detail;
  final String nextAction;
  final AuditHandoffPackageLineStatus status;

  const AuditHandoffPackageLine({
    required this.id,
    required this.title,
    required this.owner,
    required this.detail,
    required this.nextAction,
    required this.status,
  });

  bool get isBlocked => status == AuditHandoffPackageLineStatus.blocked;

  bool get isPending => status == AuditHandoffPackageLineStatus.pending;

  bool get isReady => status == AuditHandoffPackageLineStatus.ready;
}

/// Summarizes the payroll audit package prepared for reviewer handoff.
class AuditHandoffPackageSummary {
  final String packageId;
  final String periodLabel;
  final List<String> recipients;
  final List<AuditHandoffPackageLine> lines;

  const AuditHandoffPackageSummary({
    required this.packageId,
    required this.periodLabel,
    required this.recipients,
    required this.lines,
  });

  factory AuditHandoffPackageSummary.fromAuditClose({
    required String periodLabel,
    required AuditCloseAttestationSummary attestation,
    required AuditOwnerWorklistSummary ownerWorklist,
  }) {
    final signoff = attestation.signoff;
    final packageId =
        'AHP-${periodLabel.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]+'), '-')}';

    return AuditHandoffPackageSummary(
      packageId: packageId,
      periodLabel: periodLabel,
      recipients: const [
        'Internal Audit',
        'Finance Controller',
        'Payroll Controller',
      ],
      lines: [
        AuditHandoffPackageLine(
          id: 'signoff-gates',
          title: 'Sign-off gate summary',
          owner: 'Payroll Controller',
          detail:
              '${signoff.readyCount}/${signoff.gates.length} gates reviewer-ready',
          nextAction: signoff.nextAction,
          status: _statusFromCounts(
            blockedCount: signoff.blockedCount,
            pendingCount: signoff.actionCount,
          ),
        ),
        AuditHandoffPackageLine(
          id: 'owner-actions',
          title: 'Owner action log',
          owner: 'Payroll Controller',
          detail:
              '${ownerWorklist.totalItemCount} actions across ${ownerWorklist.ownerCount} owners',
          nextAction: ownerWorklist.nextAction,
          status: _statusFromCounts(
            blockedCount: ownerWorklist.blockedCount,
            pendingCount:
                ownerWorklist.actionCount + ownerWorklist.readyReviewCount,
          ),
        ),
        AuditHandoffPackageLine(
          id: 'final-attestation',
          title: 'Final attestation',
          owner: attestation.record?.role ?? 'Payroll Controller',
          detail:
              attestation.isSigned
                  ? 'Signed by ${attestation.record!.signedBy}'
                  : attestation.statusLabel,
          nextAction: attestation.nextAction,
          status:
              attestation.isSigned
                  ? AuditHandoffPackageLineStatus.ready
                  : signoff.canSignOff
                  ? AuditHandoffPackageLineStatus.pending
                  : AuditHandoffPackageLineStatus.blocked,
        ),
        AuditHandoffPackageLine(
          id: 'retention-index',
          title: 'Retention index',
          owner: 'Internal Audit',
          detail: '${signoff.readyCount} retained gate references',
          nextAction:
              signoff.canSignOff
                  ? 'Retention index is reviewer-ready.'
                  : signoff.nextAction,
          status:
              signoff.canSignOff
                  ? AuditHandoffPackageLineStatus.ready
                  : AuditHandoffPackageLineStatus.blocked,
        ),
        AuditHandoffPackageLine(
          id: 'reviewer-route',
          title: 'Reviewer route',
          owner: 'Internal Audit',
          detail: 'Recipients: Internal Audit, Finance Controller',
          nextAction:
              attestation.isSigned
                  ? 'Route package to audit reviewers.'
                  : attestation.nextAction,
          status:
              attestation.isSigned
                  ? AuditHandoffPackageLineStatus.ready
                  : AuditHandoffPackageLineStatus.pending,
        ),
      ],
    );
  }

  int get blockedCount => lines.where((line) => line.isBlocked).length;

  int get pendingCount => lines.where((line) => line.isPending).length;

  int get readyCount => lines.where((line) => line.isReady).length;

  bool get canHandoff => lines.isNotEmpty && readyCount == lines.length;

  double get readinessRate {
    if (lines.isEmpty) return 0;
    return readyCount / lines.length;
  }

  String get recipientLabel => recipients.join(', ');

  String get nextAction {
    if (blockedCount > 0) return 'Resolve $blockedCount handoff blockers.';
    if (pendingCount > 0) return 'Complete $pendingCount handoff items.';
    return 'Audit handoff package is ready for reviewer routing.';
  }
}

AuditHandoffPackageLineStatus _statusFromCounts({
  required int blockedCount,
  required int pendingCount,
}) {
  if (blockedCount > 0) return AuditHandoffPackageLineStatus.blocked;
  if (pendingCount > 0) return AuditHandoffPackageLineStatus.pending;
  return AuditHandoffPackageLineStatus.ready;
}
