import 'holiday_communication_models.dart';
import 'holiday_coverage_models.dart';
import 'holiday_models.dart';
import 'holiday_policy_models.dart';

enum HolidayPublishStatus {
  blocked('Blocked'),
  attention('Needs review'),
  ready('Ready');

  final String label;

  const HolidayPublishStatus(this.label);
}

class HolidayPublishChecklistItem {
  final String id;
  final String title;
  final String detail;
  final String action;
  final HolidayPublishStatus status;

  const HolidayPublishChecklistItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.action,
    required this.status,
  });
}

class HolidayPublishReadiness {
  final List<HolidayPublishChecklistItem> items;

  const HolidayPublishReadiness({required this.items});

  factory HolidayPublishReadiness.fromSignals({
    required HolidaySummary summary,
    required HolidayRiskSummary risks,
    required HolidayCoveragePlan coveragePlan,
    required HolidayPolicyReview policyReview,
    required HolidayCommunicationPlan communicationPlan,
  }) {
    return HolidayPublishReadiness(
      items: [
        _calendarInventoryItem(summary),
        _policyControlsItem(policyReview),
        _coveragePlanningItem(coveragePlan),
        _communicationReadinessItem(communicationPlan),
        _payrollImpactItem(risks, communicationPlan),
      ],
    );
  }

  int get blockedCount {
    return items
        .where((item) => item.status == HolidayPublishStatus.blocked)
        .length;
  }

  int get attentionCount {
    return items
        .where((item) => item.status == HolidayPublishStatus.attention)
        .length;
  }

  int get readyCount {
    return items
        .where((item) => item.status == HolidayPublishStatus.ready)
        .length;
  }

  int get readinessScore {
    final score = 100 - (blockedCount * 25) - (attentionCount * 12);

    return score.clamp(0, 100).toInt();
  }

  HolidayPublishStatus get status {
    if (blockedCount > 0) return HolidayPublishStatus.blocked;
    if (attentionCount > 0) return HolidayPublishStatus.attention;
    return HolidayPublishStatus.ready;
  }

  String get nextAction {
    final blocked = items.where(
      (item) => item.status == HolidayPublishStatus.blocked,
    );
    if (blocked.isNotEmpty) return blocked.first.action;

    final attention = items.where(
      (item) => item.status == HolidayPublishStatus.attention,
    );
    if (attention.isNotEmpty) return attention.first.action;

    return 'Publish the holiday calendar.';
  }

  bool get isPublishable => status == HolidayPublishStatus.ready;
}

HolidayPublishChecklistItem _calendarInventoryItem(HolidaySummary summary) {
  if (summary.totalCount == 0) {
    return const HolidayPublishChecklistItem(
      id: 'calendar-inventory',
      title: 'Calendar inventory',
      detail: 'No holiday rules are configured.',
      action: 'Add at least one holiday rule before publishing.',
      status: HolidayPublishStatus.blocked,
    );
  }

  return HolidayPublishChecklistItem(
    id: 'calendar-inventory',
    title: 'Calendar inventory',
    detail:
        '${summary.totalCount} rules, ${summary.upcomingCount} upcoming within 60 days.',
    action: 'Confirm the rule inventory is complete for the period.',
    status: HolidayPublishStatus.ready,
  );
}

HolidayPublishChecklistItem _policyControlsItem(
  HolidayPolicyReview policyReview,
) {
  if (policyReview.criticalCount > 0) {
    return HolidayPublishChecklistItem(
      id: 'policy-controls',
      title: 'Policy controls',
      detail:
          '${policyReview.criticalCount} critical policy checks need resolution.',
      action: 'Resolve critical policy issues before publishing.',
      status: HolidayPublishStatus.blocked,
    );
  }

  if (policyReview.warningCount > 0 || policyReview.advisoryCount > 0) {
    return HolidayPublishChecklistItem(
      id: 'policy-controls',
      title: 'Policy controls',
      detail:
          '${policyReview.warningCount} warnings and ${policyReview.advisoryCount} advisories remain.',
      action: 'Review policy advisories and document the decision.',
      status: HolidayPublishStatus.attention,
    );
  }

  return const HolidayPublishChecklistItem(
    id: 'policy-controls',
    title: 'Policy controls',
    detail: 'No policy issues detected.',
    action: 'Keep policy checks attached to the publish record.',
    status: HolidayPublishStatus.ready,
  );
}

HolidayPublishChecklistItem _coveragePlanningItem(
  HolidayCoveragePlan coveragePlan,
) {
  if (coveragePlan.urgentCount > 0) {
    return HolidayPublishChecklistItem(
      id: 'coverage-planning',
      title: 'Coverage planning',
      detail: '${coveragePlan.urgentCount} urgent coverage items are open.',
      action: 'Assign coverage owners before publishing.',
      status: HolidayPublishStatus.blocked,
    );
  }

  if (coveragePlan.items.isNotEmpty) {
    return HolidayPublishChecklistItem(
      id: 'coverage-planning',
      title: 'Coverage planning',
      detail: '${coveragePlan.items.length} coverage items need review.',
      action: 'Confirm coverage plans with managers.',
      status: HolidayPublishStatus.attention,
    );
  }

  return const HolidayPublishChecklistItem(
    id: 'coverage-planning',
    title: 'Coverage planning',
    detail: 'No coverage-sensitive holidays in the horizon.',
    action: 'No coverage action required.',
    status: HolidayPublishStatus.ready,
  );
}

HolidayPublishChecklistItem _communicationReadinessItem(
  HolidayCommunicationPlan communicationPlan,
) {
  if (communicationPlan.urgentCount > 0) {
    return HolidayPublishChecklistItem(
      id: 'communication-readiness',
      title: 'Communication readiness',
      detail: '${communicationPlan.urgentCount} urgent briefs need action.',
      action: 'Send urgent holiday communications before publishing.',
      status: HolidayPublishStatus.blocked,
    );
  }

  if (communicationPlan.reviewCount > 0) {
    return HolidayPublishChecklistItem(
      id: 'communication-readiness',
      title: 'Communication readiness',
      detail: '${communicationPlan.reviewCount} briefs need review.',
      action: 'Approve communication briefs with People Ops.',
      status: HolidayPublishStatus.attention,
    );
  }

  return const HolidayPublishChecklistItem(
    id: 'communication-readiness',
    title: 'Communication readiness',
    detail: 'Holiday communication briefs are ready.',
    action: 'Schedule the approved announcement package.',
    status: HolidayPublishStatus.ready,
  );
}

HolidayPublishChecklistItem _payrollImpactItem(
  HolidayRiskSummary risks,
  HolidayCommunicationPlan communicationPlan,
) {
  final hasCustomPayrollBrief = communicationPlan.briefs.any(
    (brief) => brief.holiday.type == HolidayType.custom,
  );

  if (risks.unpaidCustomDays > 0) {
    return HolidayPublishChecklistItem(
      id: 'payroll-impact',
      title: 'Payroll impact',
      detail:
          '${risks.unpaidCustomDays} unpaid custom days need payroll review.',
      action: 'Confirm unpaid treatment with payroll before publishing.',
      status: HolidayPublishStatus.blocked,
    );
  }

  if (hasCustomPayrollBrief) {
    return const HolidayPublishChecklistItem(
      id: 'payroll-impact',
      title: 'Payroll impact',
      detail: 'Custom holiday payroll treatment should be confirmed.',
      action: 'Confirm paid custom holiday treatment with payroll.',
      status: HolidayPublishStatus.attention,
    );
  }

  return const HolidayPublishChecklistItem(
    id: 'payroll-impact',
    title: 'Payroll impact',
    detail: 'No special payroll treatment detected.',
    action: 'Attach payroll confirmation to the publish record.',
    status: HolidayPublishStatus.ready,
  );
}
