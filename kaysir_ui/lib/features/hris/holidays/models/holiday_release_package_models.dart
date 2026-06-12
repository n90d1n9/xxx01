import 'holiday_audit_models.dart';
import 'holiday_communication_models.dart';
import 'holiday_coverage_models.dart';
import 'holiday_models.dart';
import 'holiday_policy_models.dart';
import 'holiday_publish_models.dart';
import 'holiday_release_approval_models.dart';

enum HolidayReleasePackageStatus {
  blocked('Package blocked'),
  assembling('Package assembling'),
  ready('Package ready');

  final String label;

  const HolidayReleasePackageStatus(this.label);
}

enum HolidayReleaseEvidenceStatus {
  blocked('Blocked'),
  attention('Review'),
  complete('Complete');

  final String label;

  const HolidayReleaseEvidenceStatus(this.label);
}

class HolidayReleaseEvidenceItem {
  final String id;
  final String title;
  final String owner;
  final String detail;
  final String action;
  final HolidayReleaseEvidenceStatus status;

  const HolidayReleaseEvidenceItem({
    required this.id,
    required this.title,
    required this.owner,
    required this.detail,
    required this.action,
    required this.status,
  });
}

class HolidayReleasePackage {
  final String packageId;
  final DateTime generatedAt;
  final HolidayReleasePackageStatus status;
  final String releaseWindow;
  final String nextAction;
  final List<HolidayReleaseEvidenceItem> evidence;

  const HolidayReleasePackage({
    required this.packageId,
    required this.generatedAt,
    required this.status,
    required this.releaseWindow,
    required this.nextAction,
    required this.evidence,
  });

  factory HolidayReleasePackage.fromSignals({
    required HolidaySummary summary,
    required HolidayPublishReadiness readiness,
    required HolidayReleaseApprovalPlan approvalPlan,
    required HolidayCoveragePlan coveragePlan,
    required HolidayPolicyReview policyReview,
    required HolidayCommunicationPlan communicationPlan,
    required HolidayAuditSummary auditSummary,
    required DateTime asOfDate,
  }) {
    final evidence = [
      _inventoryEvidence(summary),
      _readinessEvidence(readiness),
      _approvalEvidence(approvalPlan),
      _operationsEvidence(coveragePlan),
      _policyEvidence(policyReview),
      _communicationsEvidence(communicationPlan),
      _auditEvidence(auditSummary),
    ];

    return HolidayReleasePackage(
      packageId: _packageId(summary, asOfDate),
      generatedAt: asOfDate,
      status: _packageStatus(evidence),
      releaseWindow: _releaseWindow(summary),
      nextAction: _nextAction(evidence),
      evidence: evidence,
    );
  }

  int get blockedCount => _countStatus(HolidayReleaseEvidenceStatus.blocked);

  int get attentionCount =>
      _countStatus(HolidayReleaseEvidenceStatus.attention);

  int get completeCount => _countStatus(HolidayReleaseEvidenceStatus.complete);

  int get evidenceCount => evidence.length;

  int get packageScore {
    final score = 100 - (blockedCount * 18) - (attentionCount * 8);
    return score.clamp(0, 100).toInt();
  }

  bool get isReady => status == HolidayReleasePackageStatus.ready;

  int _countStatus(HolidayReleaseEvidenceStatus status) {
    return evidence.where((item) => item.status == status).length;
  }
}

HolidayReleaseEvidenceItem _inventoryEvidence(HolidaySummary summary) {
  if (summary.totalCount == 0) {
    return const HolidayReleaseEvidenceItem(
      id: 'inventory',
      title: 'Calendar inventory',
      owner: 'HR Operations',
      detail: 'No holiday rules are available for the package.',
      action: 'Add holiday rules before preparing a release package.',
      status: HolidayReleaseEvidenceStatus.blocked,
    );
  }

  return HolidayReleaseEvidenceItem(
    id: 'inventory',
    title: 'Calendar inventory',
    owner: 'HR Operations',
    detail:
        '${summary.totalCount} rules, ${summary.upcomingCount} upcoming in 60 days.',
    action: 'Attach the current holiday inventory to the release record.',
    status: HolidayReleaseEvidenceStatus.complete,
  );
}

HolidayReleaseEvidenceItem _readinessEvidence(
  HolidayPublishReadiness readiness,
) {
  return HolidayReleaseEvidenceItem(
    id: 'readiness',
    title: 'Release checklist',
    owner: 'People Operations',
    detail:
        '${readiness.readyCount} ready, ${readiness.attentionCount} review, ${readiness.blockedCount} blocked.',
    action: readiness.nextAction,
    status: _evidenceStatusFromPublish(readiness.status),
  );
}

HolidayReleaseEvidenceItem _approvalEvidence(
  HolidayReleaseApprovalPlan approvalPlan,
) {
  if (approvalPlan.blockedCount > 0) {
    return HolidayReleaseEvidenceItem(
      id: 'approvals',
      title: 'Approval gate',
      owner: 'HR Leadership',
      detail:
          '${approvalPlan.blockedCount} blocked, ${approvalPlan.approvedCount}/${approvalPlan.totalStepCount} approved.',
      action: approvalPlan.nextAction,
      status: HolidayReleaseEvidenceStatus.blocked,
    );
  }

  if (!approvalPlan.isFullyApproved) {
    return HolidayReleaseEvidenceItem(
      id: 'approvals',
      title: 'Approval gate',
      owner: 'HR Leadership',
      detail:
          '${approvalPlan.pendingCount} pending and ${approvalPlan.waitingCount} waiting approvals.',
      action: approvalPlan.nextAction,
      status: HolidayReleaseEvidenceStatus.attention,
    );
  }

  return const HolidayReleaseEvidenceItem(
    id: 'approvals',
    title: 'Approval gate',
    owner: 'HR Leadership',
    detail: 'All approval gates are signed off.',
    action: 'Keep approvals attached to the publish record.',
    status: HolidayReleaseEvidenceStatus.complete,
  );
}

HolidayReleaseEvidenceItem _operationsEvidence(HolidayCoveragePlan plan) {
  if (plan.urgentCount > 0) {
    return HolidayReleaseEvidenceItem(
      id: 'operations',
      title: 'Operations coverage',
      owner: 'Operations',
      detail: '${plan.urgentCount} urgent coverage items remain open.',
      action: 'Assign coverage owners before release.',
      status: HolidayReleaseEvidenceStatus.blocked,
    );
  }

  if (plan.items.isNotEmpty) {
    return HolidayReleaseEvidenceItem(
      id: 'operations',
      title: 'Operations coverage',
      owner: 'Operations',
      detail: '${plan.items.length} coverage plans need manager review.',
      action: 'Confirm coverage plans with managers.',
      status: HolidayReleaseEvidenceStatus.attention,
    );
  }

  return const HolidayReleaseEvidenceItem(
    id: 'operations',
    title: 'Operations coverage',
    owner: 'Operations',
    detail: 'No coverage-sensitive holidays in the release horizon.',
    action: 'No operations coverage action required.',
    status: HolidayReleaseEvidenceStatus.complete,
  );
}

HolidayReleaseEvidenceItem _policyEvidence(HolidayPolicyReview review) {
  if (review.criticalCount > 0) {
    return HolidayReleaseEvidenceItem(
      id: 'policy',
      title: 'Policy evidence',
      owner: 'HR Compliance',
      detail: '${review.criticalCount} critical policy issues remain.',
      action: 'Resolve critical policy checks before release.',
      status: HolidayReleaseEvidenceStatus.blocked,
    );
  }

  if (review.warningCount > 0 || review.advisoryCount > 0) {
    return HolidayReleaseEvidenceItem(
      id: 'policy',
      title: 'Policy evidence',
      owner: 'HR Compliance',
      detail:
          '${review.warningCount} warnings and ${review.advisoryCount} advisories remain.',
      action: 'Document policy decisions in the release notes.',
      status: HolidayReleaseEvidenceStatus.attention,
    );
  }

  return const HolidayReleaseEvidenceItem(
    id: 'policy',
    title: 'Policy evidence',
    owner: 'HR Compliance',
    detail: 'No policy issues detected.',
    action: 'Attach policy checks to the package.',
    status: HolidayReleaseEvidenceStatus.complete,
  );
}

HolidayReleaseEvidenceItem _communicationsEvidence(
  HolidayCommunicationPlan plan,
) {
  if (plan.urgentCount > 0) {
    return HolidayReleaseEvidenceItem(
      id: 'communications',
      title: 'Communication packet',
      owner: 'People Communications',
      detail: '${plan.urgentCount} urgent communications need action.',
      action: 'Send urgent communications before release.',
      status: HolidayReleaseEvidenceStatus.blocked,
    );
  }

  if (plan.reviewCount > 0) {
    return HolidayReleaseEvidenceItem(
      id: 'communications',
      title: 'Communication packet',
      owner: 'People Communications',
      detail: '${plan.reviewCount} communication briefs need review.',
      action: 'Approve employee and manager messages.',
      status: HolidayReleaseEvidenceStatus.attention,
    );
  }

  return const HolidayReleaseEvidenceItem(
    id: 'communications',
    title: 'Communication packet',
    owner: 'People Communications',
    detail: 'Holiday communications are ready.',
    action: 'Schedule the announcement package.',
    status: HolidayReleaseEvidenceStatus.complete,
  );
}

HolidayReleaseEvidenceItem _auditEvidence(HolidayAuditSummary summary) {
  if (!summary.hasActivity) {
    return const HolidayReleaseEvidenceItem(
      id: 'audit',
      title: 'Change audit',
      owner: 'HR Operations',
      detail: 'No calendar changes have been recorded this session.',
      action: 'Capture final approval activity before publishing.',
      status: HolidayReleaseEvidenceStatus.attention,
    );
  }

  return HolidayReleaseEvidenceItem(
    id: 'audit',
    title: 'Change audit',
    owner: 'HR Operations',
    detail: '${summary.totalCount} recorded changes are attached.',
    action: 'Keep audit trail attached to the release package.',
    status: HolidayReleaseEvidenceStatus.complete,
  );
}

HolidayReleasePackageStatus _packageStatus(
  List<HolidayReleaseEvidenceItem> evidence,
) {
  if (evidence.any(
    (item) => item.status == HolidayReleaseEvidenceStatus.blocked,
  )) {
    return HolidayReleasePackageStatus.blocked;
  }
  if (evidence.any(
    (item) => item.status == HolidayReleaseEvidenceStatus.attention,
  )) {
    return HolidayReleasePackageStatus.assembling;
  }

  return HolidayReleasePackageStatus.ready;
}

HolidayReleaseEvidenceStatus _evidenceStatusFromPublish(
  HolidayPublishStatus status,
) {
  return switch (status) {
    HolidayPublishStatus.blocked => HolidayReleaseEvidenceStatus.blocked,
    HolidayPublishStatus.attention => HolidayReleaseEvidenceStatus.attention,
    HolidayPublishStatus.ready => HolidayReleaseEvidenceStatus.complete,
  };
}

String _nextAction(List<HolidayReleaseEvidenceItem> evidence) {
  for (final item in evidence) {
    if (item.status == HolidayReleaseEvidenceStatus.blocked) {
      return item.action;
    }
  }
  for (final item in evidence) {
    if (item.status == HolidayReleaseEvidenceStatus.attention) {
      return item.action;
    }
  }

  return 'Publish the holiday release package.';
}

String _packageId(HolidaySummary summary, DateTime asOfDate) {
  final count = summary.totalCount.toString().padLeft(3, '0');
  return 'HOL-${asOfDate.year}-$count';
}

String _releaseWindow(HolidaySummary summary) {
  final nextHoliday = summary.nextHoliday;
  if (nextHoliday == null) return 'No upcoming holiday inside 60 days.';

  return 'Next holiday: ${nextHoliday.name} on ${_formatDate(nextHoliday.effectiveDate)}.';
}

String _formatDate(DateTime value) {
  return '${_months[value.month - 1]} ${value.day}, ${value.year}';
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
