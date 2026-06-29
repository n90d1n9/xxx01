import 'package:flutter/material.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_insight_models.dart';
import 'employee_directory_insights_tiles.dart';

class EmployeeDirectoryInsightsPanel extends StatelessWidget {
  final EmployeeDirectoryInsights insights;

  const EmployeeDirectoryInsightsPanel({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      key: const ValueKey('employee-directory-insights-panel'),
      icon: Icons.psychology_alt_outlined,
      title: 'Workforce insights',
      subtitle:
          '${insights.visibleCount} visible profiles, ${insights.attentionProfileCount} needing HR attention',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Health',
              value: '${insights.healthScore}%',
            ),
            HrisMetricStripItem(
              label: 'Attention',
              value: '${insights.attentionProfileCount}',
            ),
            HrisMetricStripItem(
              label: 'Onboarding',
              value: '${insights.onboardingCount}',
            ),
            HrisMetricStripItem(
              label: 'Manager load',
              value: '${insights.managerLoadAlertCount}',
            ),
          ],
        ),
        HrisResponsivePanelGrid(
          breakpoint: 820,
          panels: [
            EmployeeDirectoryInsightSignalTile(
              key: const ValueKey('employee-directory-insight-health'),
              icon: Icons.health_and_safety_outlined,
              color: _healthColor(insights.healthScore),
              label: 'Directory health',
              value: insights.healthLabel,
              detail:
                  insights.visibleCount == 0
                      ? 'No profiles in current table'
                      : '${insights.healthScore}% profiles are clear',
            ),
            EmployeeDirectoryInsightSignalTile(
              key: const ValueKey('employee-directory-insight-department'),
              icon: Icons.account_tree_outlined,
              color: const Color(0xFF7C3AED),
              label: 'Attention department',
              value: insights.topAttentionDepartment,
              detail: 'Highest combined HR signal score',
            ),
            EmployeeDirectoryInsightSignalTile(
              key: const ValueKey('employee-directory-insight-coverage'),
              icon: Icons.public_outlined,
              color: const Color(0xFF0F766E),
              label: 'Coverage footprint',
              value: '${insights.locationCount} locations',
              detail: '${insights.averageTenureMonths} mo avg tenure',
            ),
            EmployeeDirectoryInsightSignalTile(
              key: const ValueKey('employee-directory-insight-performance'),
              icon: Icons.insights_outlined,
              color: const Color(0xFFD97706),
              label: 'Performance support',
              value: '${insights.lowPerformanceCount} profiles',
              detail: 'Below directory support threshold',
            ),
          ],
        ),
        ...insights.actions.map(
          (action) => EmployeeDirectoryInsightActionTile(
            key: ValueKey('employee-directory-insight-action-${action.title}'),
            action: action,
          ),
        ),
      ],
    );
  }
}

Color _healthColor(int score) {
  if (score >= 80) return const Color(0xFF15803D);
  if (score >= 60) return const Color(0xFFD97706);
  return const Color(0xFFB91C1C);
}
