import 'package:flutter/material.dart';

import 'dashboard_analytics.dart';

enum DashboardActionPriority {
  critical('Critical'),
  high('High'),
  medium('Medium'),
  low('Low');

  final String label;

  const DashboardActionPriority(this.label);
}

class DashboardActionRecommendation {
  final String id;
  final String title;
  final String description;
  final String metricLabel;
  final String metricValue;
  final String actionLabel;
  final String ownerLabel;
  final String dueLabel;
  final IconData icon;
  final DashboardActionPriority priority;
  final String? route;

  const DashboardActionRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.metricLabel,
    required this.metricValue,
    required this.actionLabel,
    required this.ownerLabel,
    required this.dueLabel,
    required this.icon,
    required this.priority,
    this.route,
  });
}

class DashboardActionSummary {
  final List<DashboardActionRecommendation> recommendations;

  const DashboardActionSummary({required this.recommendations});

  bool get isEmpty => recommendations.isEmpty;

  DashboardActionRecommendation? get primary {
    return recommendations.isEmpty ? null : recommendations.first;
  }

  factory DashboardActionSummary.fromSignals({
    required DashboardInsightSummary insightSummary,
    required DashboardRiskRollup riskRollup,
  }) {
    final recommendations = <DashboardActionRecommendation>[];
    final topRisk =
        riskRollup.rankedItems.isEmpty ? null : riskRollup.rankedItems.first;

    if (topRisk != null && riskRollup.criticalWorkspaceCount > 0) {
      recommendations.add(
        DashboardActionRecommendation(
          id: 'critical-risk',
          title: 'Stabilize ${topRisk.label}',
          description:
              '${riskRollup.criticalWorkspaceCount} critical workspaces and '
              '${riskRollup.totalRisks} total risks need leadership attention.',
          metricLabel: 'Critical',
          metricValue: '${riskRollup.criticalWorkspaceCount}',
          actionLabel: 'Open workspace',
          ownerLabel: 'HR leadership',
          dueLabel: 'Today',
          icon: Icons.priority_high_rounded,
          priority: DashboardActionPriority.critical,
          route: topRisk.route,
        ),
      );
    }

    if (riskRollup.timeSensitiveRisks > 0) {
      recommendations.add(
        DashboardActionRecommendation(
          id: 'time-sensitive',
          title: 'Clear time-sensitive HR work',
          description:
              '${riskRollup.timeSensitiveRisks} due signals are spread across '
              '${riskRollup.workspaceCount} workspaces.',
          metricLabel: 'Due soon',
          metricValue: '${riskRollup.timeSensitiveRisks}',
          actionLabel: 'Review queue',
          ownerLabel: 'People Ops',
          dueLabel: 'This week',
          icon: Icons.schedule_rounded,
          priority: DashboardActionPriority.high,
        ),
      );
    }

    final hasMomentum = insightSummary.improvedMetricCount >= 3;
    recommendations.add(
      DashboardActionRecommendation(
        id: hasMomentum ? 'scale-momentum' : 'recover-momentum',
        title: hasMomentum ? 'Scale what is working' : 'Recover KPI momentum',
        description:
            hasMomentum
                ? '${insightSummary.improvedMetricCount} KPIs improved; reuse '
                    'plays from ${insightSummary.fastestImprovingDepartment} '
                    'and ${insightSummary.strongestDepartment}.'
                : 'Only ${insightSummary.improvedMetricCount} KPIs improved; '
                    'review drivers before the next dashboard refresh.',
        metricLabel: hasMomentum ? 'Improved' : 'Needs review',
        metricValue: '${insightSummary.improvedMetricCount}',
        actionLabel: 'Review pulse',
        ownerLabel: hasMomentum ? 'HR Analytics' : 'HR leadership',
        dueLabel: hasMomentum ? 'Next sync' : '48 hours',
        icon: hasMomentum ? Icons.trending_up_rounded : Icons.insights_outlined,
        priority:
            hasMomentum
                ? DashboardActionPriority.medium
                : DashboardActionPriority.high,
      ),
    );

    return DashboardActionSummary(
      recommendations: recommendations.take(3).toList(),
    );
  }
}
