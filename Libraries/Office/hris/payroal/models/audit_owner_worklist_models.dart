import 'audit_pack_findings_models.dart';
import 'payroll_audit_pack_review_models.dart';
import 'payroll_controls_evidence_matrix_models.dart';
import 'payroll_report_distribution_models.dart';

/// Defines the current action state for an owner worklist item.
enum AuditOwnerWorklistStatus {
  blocked('Blocked'),
  actionNeeded('Action needed'),
  readyReview('Ready review');

  final String label;

  const AuditOwnerWorklistStatus(this.label);
}

/// Represents one audit close action assigned to an owner.
class AuditOwnerWorklistItem {
  final String id;
  final String owner;
  final String title;
  final String source;
  final String nextAction;
  final AuditOwnerWorklistStatus status;

  const AuditOwnerWorklistItem({
    required this.id,
    required this.owner,
    required this.title,
    required this.source,
    required this.nextAction,
    required this.status,
  });

  bool get isBlocked => status == AuditOwnerWorklistStatus.blocked;

  bool get needsAction => status == AuditOwnerWorklistStatus.actionNeeded;

  bool get isReadyReview => status == AuditOwnerWorklistStatus.readyReview;
}

/// Groups audit close actions for one responsible owner.
class AuditOwnerWorklistGroup {
  final String owner;
  final List<AuditOwnerWorklistItem> items;

  const AuditOwnerWorklistGroup({required this.owner, required this.items});

  int get blockedCount => items.where((item) => item.isBlocked).length;

  int get actionCount => items.where((item) => item.needsAction).length;

  int get readyReviewCount => items.where((item) => item.isReadyReview).length;

  AuditOwnerWorklistItem? get firstItem => items.isEmpty ? null : items.first;
}

/// Summarizes all owner-assigned audit close work for the payroll period.
class AuditOwnerWorklistSummary {
  final String periodLabel;
  final List<AuditOwnerWorklistGroup> groups;

  const AuditOwnerWorklistSummary({
    required this.periodLabel,
    required this.groups,
  });

  factory AuditOwnerWorklistSummary.fromAuditSignals({
    required String periodLabel,
    required AuditPackFindingsSummary findings,
    required PayrollAuditPackReviewSummary auditPackReview,
    required PayrollControlsEvidenceMatrixSummary controlsMatrix,
    required PayrollReportDistributionSummary reportDistribution,
  }) {
    final items = <AuditOwnerWorklistItem>[
      for (final finding in findings.findings)
        if (!finding.isClosed)
          AuditOwnerWorklistItem(
            id: 'finding-${finding.id}',
            owner: finding.owner,
            title: finding.title,
            source: 'Audit finding',
            nextAction: finding.nextAction,
            status:
                finding.isRemediated
                    ? AuditOwnerWorklistStatus.readyReview
                    : AuditOwnerWorklistStatus.actionNeeded,
          ),
      for (final checkpoint in auditPackReview.checkpoints)
        if (checkpoint.hasBlockers)
          AuditOwnerWorklistItem(
            id: 'review-${checkpoint.id}',
            owner: checkpoint.owner,
            title: checkpoint.title,
            source: 'Audit pack review',
            nextAction: checkpoint.blockers.first,
            status: AuditOwnerWorklistStatus.blocked,
          ),
      for (final line in controlsMatrix.lines)
        if (line.status == PayrollControlsEvidenceMatrixStatus.blocked ||
            line.status == PayrollControlsEvidenceMatrixStatus.missing)
          AuditOwnerWorklistItem(
            id: 'control-${line.control.id}',
            owner: line.control.owner,
            title: line.control.title,
            source: 'Control evidence',
            nextAction:
                line.blockers.isEmpty
                    ? controlsMatrix.nextAction
                    : line.blockers.first,
            status: AuditOwnerWorklistStatus.blocked,
          ),
      for (final line in reportDistribution.lines)
        if (line.status != PayrollReportDistributionStatus.delivered)
          AuditOwnerWorklistItem(
            id: 'distribution-${line.report.id}',
            owner: line.report.owner,
            title: line.report.title,
            source: 'Report distribution',
            nextAction: line.nextAction,
            status:
                line.status == PayrollReportDistributionStatus.blocked
                    ? AuditOwnerWorklistStatus.blocked
                    : AuditOwnerWorklistStatus.actionNeeded,
          ),
    ];

    final itemsByOwner = <String, List<AuditOwnerWorklistItem>>{};
    for (final item in items) {
      itemsByOwner
          .putIfAbsent(item.owner, () => <AuditOwnerWorklistItem>[])
          .add(item);
    }

    final groups =
        itemsByOwner.entries
            .map(
              (entry) => AuditOwnerWorklistGroup(
                owner: entry.key,
                items: entry.value..sort(_compareItems),
              ),
            )
            .toList()
          ..sort((left, right) {
            final blocked = right.blockedCount.compareTo(left.blockedCount);
            if (blocked != 0) return blocked;
            final action = right.actionCount.compareTo(left.actionCount);
            if (action != 0) return action;
            return left.owner.compareTo(right.owner);
          });

    return AuditOwnerWorklistSummary(periodLabel: periodLabel, groups: groups);
  }

  int get ownerCount => groups.length;

  int get totalItemCount =>
      groups.fold(0, (total, group) => total + group.items.length);

  int get blockedCount =>
      groups.fold(0, (total, group) => total + group.blockedCount);

  int get actionCount =>
      groups.fold(0, (total, group) => total + group.actionCount);

  int get readyReviewCount =>
      groups.fold(0, (total, group) => total + group.readyReviewCount);

  bool get isClear => totalItemCount == 0;

  String get nextAction {
    if (blockedCount > 0) return 'Resolve $blockedCount owner blockers.';
    if (actionCount > 0) return 'Complete $actionCount owner actions.';
    if (readyReviewCount > 0) {
      return 'Review $readyReviewCount remediated owner actions.';
    }
    return 'No owner actions remain for audit close.';
  }
}

int _compareItems(AuditOwnerWorklistItem left, AuditOwnerWorklistItem right) {
  final status = left.status.index.compareTo(right.status.index);
  if (status != 0) return status;
  return left.title.compareTo(right.title);
}
