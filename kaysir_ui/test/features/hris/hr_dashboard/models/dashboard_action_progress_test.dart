import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_progress.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_status.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';

void main() {
  const actions = [
    DashboardActionRecommendation(
      id: 'done-action',
      title: 'Done action',
      description: 'Already completed',
      metricLabel: 'Done',
      metricValue: '1',
      actionLabel: 'Review',
      ownerLabel: 'HR Ops',
      dueLabel: 'Today',
      icon: Icons.check_rounded,
      priority: DashboardActionPriority.medium,
    ),
    DashboardActionRecommendation(
      id: 'active-action',
      title: 'Active action',
      description: 'Currently moving',
      metricLabel: 'Active',
      metricValue: '1',
      actionLabel: 'Review',
      ownerLabel: 'People Ops',
      dueLabel: 'This week',
      icon: Icons.play_arrow_rounded,
      priority: DashboardActionPriority.high,
    ),
    DashboardActionRecommendation(
      id: 'open-action',
      title: 'Open action',
      description: 'Not started',
      metricLabel: 'Open',
      metricValue: '1',
      actionLabel: 'Review',
      ownerLabel: 'HR Analytics',
      dueLabel: 'Next sync',
      icon: Icons.radio_button_unchecked_rounded,
      priority: DashboardActionPriority.low,
    ),
  ];

  test('dashboard action progress counts recommendation statuses', () {
    final progress = DashboardActionProgress.fromRecommendations(
      recommendations: actions,
      statuses: const {
        'done-action': DashboardActionStatus.done,
        'active-action': DashboardActionStatus.inProgress,
      },
    );

    expect(progress.openCount, 1);
    expect(progress.inProgressCount, 1);
    expect(progress.doneCount, 1);
    expect(progress.totalCount, 3);
    expect(progress.completionRatio, closeTo(1 / 3, 0.001));
  });

  test('dashboard actions order active, open, then done', () {
    final ordered = orderDashboardActionsByStatus(
      recommendations: actions,
      statuses: const {
        'done-action': DashboardActionStatus.done,
        'active-action': DashboardActionStatus.inProgress,
      },
    );

    expect(ordered.map((action) => action.id), [
      'active-action',
      'open-action',
      'done-action',
    ]);
  });
}
