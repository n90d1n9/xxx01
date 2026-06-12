import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_status.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_urgency_summary.dart';

void main() {
  test('dashboard action urgency derives scan labels from due and status', () {
    final now = DashboardActionUrgency.fromAction(
      action: _action(dueLabel: 'Today'),
      status: DashboardActionStatus.open,
    );
    final soon = DashboardActionUrgency.fromAction(
      action: _action(dueLabel: 'This week'),
      status: DashboardActionStatus.inProgress,
    );
    final planned = DashboardActionUrgency.fromAction(
      action: _action(dueLabel: 'Next sync'),
      status: DashboardActionStatus.open,
    );
    final closed = DashboardActionUrgency.fromAction(
      action: _action(dueLabel: 'Today'),
      status: DashboardActionStatus.done,
    );

    expect(now.tier, DashboardActionUrgencyTier.now);
    expect(now.label, 'Due now');
    expect(soon.tier, DashboardActionUrgencyTier.soon);
    expect(soon.label, 'Due soon');
    expect(planned.tier, DashboardActionUrgencyTier.planned);
    expect(planned.label, 'Planned');
    expect(closed.tier, DashboardActionUrgencyTier.closed);
    expect(closed.label, 'Closed');
  });

  test('dashboard action urgency summaries count queue tiers', () {
    final summaries = buildDashboardActionUrgencySummaries(
      recommendations: [
        _action(id: 'now', dueLabel: 'Today'),
        _action(id: 'soon', dueLabel: 'This week'),
        _action(id: 'closed', dueLabel: 'Today'),
      ],
      statuses: const {'closed': DashboardActionStatus.done},
    );

    expect(summaries.map((summary) => summary.tier), [
      DashboardActionUrgencyTier.now,
      DashboardActionUrgencyTier.soon,
      DashboardActionUrgencyTier.closed,
    ]);
    expect(summaries.map((summary) => summary.totalCount), [1, 1, 1]);
  });
}

DashboardActionRecommendation _action({
  String id = 'sample',
  required String dueLabel,
}) {
  return DashboardActionRecommendation(
    id: id,
    title: 'Sample action',
    description: 'Sample action description.',
    metricLabel: 'Signal',
    metricValue: '1',
    actionLabel: 'Review',
    ownerLabel: 'People Ops',
    dueLabel: dueLabel,
    icon: Icons.schedule_rounded,
    priority: DashboardActionPriority.high,
  );
}
