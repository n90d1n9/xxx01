import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_detail.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_status.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';

const hrisDashboardCriticalActionId = 'critical-risk';
const hrisDashboardTimeSensitiveActionId = 'time-sensitive';
const hrisDashboardScaleMomentumActionId = 'scale-momentum';

const hrisDashboardCriticalActionTitle = 'Stabilize Manager';
const hrisDashboardTimeSensitiveActionTitle = 'Clear time-sensitive HR work';
const hrisDashboardScaleMomentumActionTitle = 'Scale what is working';

const hrisDashboardCriticalActionLabel = 'Open workspace';
const hrisDashboardTimeSensitiveActionLabel = 'Review queue';
const hrisDashboardScaleMomentumActionLabel = 'Review pulse';

const hrisDashboardCriticalOwnerLabel = 'HR leadership';
const hrisDashboardTimeSensitiveOwnerLabel = 'People Ops';
const hrisDashboardScaleMomentumOwnerLabel = 'HR Analytics';

const hrisDashboardCriticalDueLabel = 'Today';
const hrisDashboardTimeSensitiveDueLabel = 'This week';
const hrisDashboardScaleMomentumDueLabel = 'Next sync';

const hrisDashboardCriticalAction = DashboardActionRecommendation(
  id: hrisDashboardCriticalActionId,
  title: hrisDashboardCriticalActionTitle,
  description: '5 critical workspaces need leadership attention.',
  metricLabel: 'Critical',
  metricValue: '5',
  actionLabel: hrisDashboardCriticalActionLabel,
  ownerLabel: hrisDashboardCriticalOwnerLabel,
  dueLabel: hrisDashboardCriticalDueLabel,
  icon: Icons.priority_high_rounded,
  priority: DashboardActionPriority.critical,
  route: '/manager',
);

const hrisDashboardTimeSensitiveAction = DashboardActionRecommendation(
  id: hrisDashboardTimeSensitiveActionId,
  title: hrisDashboardTimeSensitiveActionTitle,
  description: '56 due signals are spread across 15 workspaces.',
  metricLabel: 'Due soon',
  metricValue: '56',
  actionLabel: hrisDashboardTimeSensitiveActionLabel,
  ownerLabel: hrisDashboardTimeSensitiveOwnerLabel,
  dueLabel: hrisDashboardTimeSensitiveDueLabel,
  icon: Icons.schedule_rounded,
  priority: DashboardActionPriority.high,
);

const hrisDashboardScaleMomentumAction = DashboardActionRecommendation(
  id: hrisDashboardScaleMomentumActionId,
  title: hrisDashboardScaleMomentumActionTitle,
  description: '4 KPIs improved; reuse the best plays.',
  metricLabel: 'Improved',
  metricValue: '4',
  actionLabel: hrisDashboardScaleMomentumActionLabel,
  ownerLabel: hrisDashboardScaleMomentumOwnerLabel,
  dueLabel: hrisDashboardScaleMomentumDueLabel,
  icon: Icons.trending_up_rounded,
  priority: DashboardActionPriority.medium,
);

const hrisDashboardActionRecommendations = [
  hrisDashboardTimeSensitiveAction,
  hrisDashboardCriticalAction,
  hrisDashboardScaleMomentumAction,
];

const hrisDashboardActionSummary = DashboardActionSummary(
  recommendations: hrisDashboardActionRecommendations,
);

const hrisDashboardCriticalActionSummary = DashboardActionSummary(
  recommendations: [hrisDashboardCriticalAction],
);

const hrisDashboardCriticalInProgressStatuses = <String, DashboardActionStatus>{
  hrisDashboardCriticalActionId: DashboardActionStatus.inProgress,
};

const hrisDashboardTimeSensitiveDoneStatuses = <String, DashboardActionStatus>{
  hrisDashboardTimeSensitiveActionId: DashboardActionStatus.done,
};

const hrisDashboardScaleMomentumDoneStatuses = <String, DashboardActionStatus>{
  hrisDashboardScaleMomentumActionId: DashboardActionStatus.done,
};

const hrisDashboardCriticalDoneStatuses = <String, DashboardActionStatus>{
  hrisDashboardCriticalActionId: DashboardActionStatus.done,
};

const hrisDashboardCriticalActiveTimeSensitiveDoneStatuses =
    <String, DashboardActionStatus>{
      hrisDashboardCriticalActionId: DashboardActionStatus.inProgress,
      hrisDashboardTimeSensitiveActionId: DashboardActionStatus.done,
    };

DashboardActionDetail hrisDashboardCriticalDetail({
  DashboardActionStatus status = DashboardActionStatus.inProgress,
}) {
  return DashboardActionDetail.fromRecommendation(
    action: hrisDashboardCriticalAction,
    status: status,
  );
}
