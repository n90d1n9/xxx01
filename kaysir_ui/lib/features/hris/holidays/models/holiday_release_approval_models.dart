import 'holiday_publish_models.dart';

enum HolidayReleaseApprovalStatus {
  blocked('Blocked'),
  waiting('Waiting'),
  pending('Pending'),
  approved('Approved');

  final String label;

  const HolidayReleaseApprovalStatus(this.label);
}

class HolidayReleaseApprovalStep {
  final String id;
  final String title;
  final String owner;
  final String requirement;
  final String action;
  final HolidayPublishStatus readinessStatus;
  final HolidayReleaseApprovalStatus status;

  const HolidayReleaseApprovalStep({
    required this.id,
    required this.title,
    required this.owner,
    required this.requirement,
    required this.action,
    required this.readinessStatus,
    required this.status,
  });

  bool get canApprove => status == HolidayReleaseApprovalStatus.pending;

  bool get canRevoke => status == HolidayReleaseApprovalStatus.approved;
}

class HolidayReleaseApprovalPlan {
  final List<HolidayReleaseApprovalStep> steps;

  const HolidayReleaseApprovalPlan({required this.steps});

  factory HolidayReleaseApprovalPlan.fromReadiness({
    required HolidayPublishReadiness readiness,
    required Set<String> approvedStepIds,
  }) {
    return HolidayReleaseApprovalPlan(
      steps:
          readiness.items.map((item) {
            return HolidayReleaseApprovalStep(
              id: item.id,
              title: item.title,
              owner: _ownerForItem(item),
              requirement: item.detail,
              action: item.action,
              readinessStatus: item.status,
              status: _approvalStatus(item, approvedStepIds),
            );
          }).toList(),
    );
  }

  int get totalStepCount => steps.length;

  int get approvedCount => _countStatus(HolidayReleaseApprovalStatus.approved);

  int get pendingCount => _countStatus(HolidayReleaseApprovalStatus.pending);

  int get waitingCount => _countStatus(HolidayReleaseApprovalStatus.waiting);

  int get blockedCount => _countStatus(HolidayReleaseApprovalStatus.blocked);

  int get approvableCount {
    return steps.where((step) => step.canApprove).length;
  }

  int get approvalScore {
    if (totalStepCount == 0) return 100;
    return ((approvedCount / totalStepCount) * 100).round();
  }

  bool get isFullyApproved {
    return totalStepCount > 0 &&
        approvedCount == totalStepCount &&
        blockedCount == 0 &&
        waitingCount == 0 &&
        pendingCount == 0;
  }

  HolidayReleaseApprovalStep? get nextStep {
    final blocked = _firstStatus(HolidayReleaseApprovalStatus.blocked);
    if (blocked != null) return blocked;

    final waiting = _firstStatus(HolidayReleaseApprovalStatus.waiting);
    if (waiting != null) return waiting;

    return _firstStatus(HolidayReleaseApprovalStatus.pending);
  }

  String get nextAction {
    final step = nextStep;
    if (step == null) return 'All release approvals are complete.';
    if (step.status == HolidayReleaseApprovalStatus.pending) {
      return 'Approve ${step.owner} release gate.';
    }

    return step.action;
  }

  int _countStatus(HolidayReleaseApprovalStatus status) {
    return steps.where((step) => step.status == status).length;
  }

  HolidayReleaseApprovalStep? _firstStatus(
    HolidayReleaseApprovalStatus status,
  ) {
    for (final step in steps) {
      if (step.status == status) return step;
    }

    return null;
  }
}

HolidayReleaseApprovalStatus _approvalStatus(
  HolidayPublishChecklistItem item,
  Set<String> approvedStepIds,
) {
  if (item.status == HolidayPublishStatus.blocked) {
    return HolidayReleaseApprovalStatus.blocked;
  }
  if (item.status == HolidayPublishStatus.attention) {
    return HolidayReleaseApprovalStatus.waiting;
  }
  if (approvedStepIds.contains(item.id)) {
    return HolidayReleaseApprovalStatus.approved;
  }

  return HolidayReleaseApprovalStatus.pending;
}

String _ownerForItem(HolidayPublishChecklistItem item) {
  return switch (item.id) {
    'calendar-inventory' => 'HR Operations',
    'policy-controls' => 'HR Compliance',
    'coverage-planning' => 'Operations',
    'communication-readiness' => 'People Communications',
    'payroll-impact' => 'Payroll',
    _ => 'People Operations',
  };
}
