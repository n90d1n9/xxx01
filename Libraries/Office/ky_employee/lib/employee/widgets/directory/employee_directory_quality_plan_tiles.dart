import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_directory_quality_fix_models.dart';
import '../../models/employee_directory_quality_plan_models.dart';
import '../../models/employee_directory_quality_models.dart';
import 'employee_directory_quality_fix_fields.dart';

/// Severity lane card that summarizes the size and urgency of cleanup work.
class EmployeeDirectoryQualityPlanLaneCard extends StatelessWidget {
  final EmployeeDirectoryQualityPlanLane lane;

  const EmployeeDirectoryQualityPlanLaneCard({super.key, required this.lane});

  @override
  Widget build(BuildContext context) {
    final color = employeeDirectoryQualityFixSeverityColor(lane.severity);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanIcon(icon: _severityIcon(lane.severity), color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${lane.severity.label} cleanup',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: lane.etaLabel, color: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  lane.summaryLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 8),
                Text(
                  lane.actionLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee quality plan lane')
Widget employeeDirectoryQualityPlanLaneCardPreview() {
  return const MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: EmployeeDirectoryQualityPlanLaneCard(
          lane: EmployeeDirectoryQualityPlanLane(
            severity: EmployeeDirectoryQualitySeverity.critical,
            issueCount: 2,
            affectedProfileCount: 2,
            estimatedMinutes: 14,
          ),
        ),
      ),
    ),
  );
}

/// Recommended issue tile that lets HR focus the next fix immediately.
class EmployeeDirectoryQualityPlanRecommendationTile extends StatelessWidget {
  final EmployeeDirectoryQualityFixPlan plan;
  final ValueChanged<String> onIssueSelected;

  const EmployeeDirectoryQualityPlanRecommendationTile({
    super.key,
    required this.plan,
    required this.onIssueSelected,
  });

  @override
  Widget build(BuildContext context) {
    final issue = plan.recommendedIssue;
    if (issue == null) {
      return const HrisListSurface(
        child: Text('No quality fixes are waiting for action.'),
      );
    }

    final color = employeeDirectoryQualityFixSeverityColor(issue.severity);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanIcon(
            icon: employeeDirectoryQualityFixIssueIcon(issue.type),
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.recommendedActionLabel,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: issue.severity.label, color: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  plan.laneActionLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  key: const ValueKey(
                    'employee-directory-quality-plan-focus-button',
                  ),
                  onPressed: () => onIssueSelected(issue.fixKey),
                  icon: const Icon(Icons.center_focus_strong_outlined),
                  label: const Text('Focus first fix'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee quality plan recommendation')
Widget employeeDirectoryQualityPlanRecommendationTilePreview() {
  const issue = EmployeeDirectoryQualityIssue(
    type: EmployeeDirectoryQualityIssueType.duplicateEmail,
    severity: EmployeeDirectoryQualitySeverity.critical,
    employeeId: '2',
    employeeName: 'Maya Santoso',
    detail: 'maya@example.com appears on more than one profile.',
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryQualityPlanRecommendationTile(
          plan: const EmployeeDirectoryQualityFixPlan(
            memberCount: 3,
            issueCount: 3,
            affectedProfileCount: 2,
            estimatedMinutes: 19,
            targetReadinessScore: 67,
            recommendedIssue: issue,
            lanes: [
              EmployeeDirectoryQualityPlanLane(
                severity: EmployeeDirectoryQualitySeverity.critical,
                issueCount: 2,
                affectedProfileCount: 2,
                estimatedMinutes: 14,
              ),
            ],
            groups: [],
          ),
          onIssueSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Issue-type group tile used to batch similar roster cleanup work.
class EmployeeDirectoryQualityPlanGroupTile extends StatelessWidget {
  final EmployeeDirectoryQualityPlanGroup group;
  final ValueChanged<String> onIssueSelected;

  const EmployeeDirectoryQualityPlanGroupTile({
    super.key,
    required this.group,
    required this.onIssueSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = employeeDirectoryQualityFixSeverityColor(group.severity);

    return HrisListSurface(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanIcon(
            icon: employeeDirectoryQualityFixIssueIcon(group.type),
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.type.label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HrisStatusPill(label: group.etaLabel, color: color),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  group.summaryLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 5),
                Text(
                  group.profileLabel,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  key: ValueKey(
                    'employee-directory-quality-plan-group-${group.type.name}',
                  ),
                  onPressed: () => onIssueSelected(group.firstIssue.fixKey),
                  icon: const Icon(Icons.playlist_add_check_outlined),
                  label: const Text('Focus group'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Employee quality plan group')
Widget employeeDirectoryQualityPlanGroupTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: EmployeeDirectoryQualityPlanGroupTile(
          group: const EmployeeDirectoryQualityPlanGroup(
            type: EmployeeDirectoryQualityIssueType.duplicateEmail,
            severity: EmployeeDirectoryQualitySeverity.critical,
            issueCount: 2,
            affectedProfileCount: 2,
            estimatedMinutes: 14,
            employeeNames: ['Maya Santoso', 'Sarah Johnson'],
            firstIssue: EmployeeDirectoryQualityIssue(
              type: EmployeeDirectoryQualityIssueType.duplicateEmail,
              severity: EmployeeDirectoryQualitySeverity.critical,
              employeeId: '2',
              employeeName: 'Maya Santoso',
              detail: 'maya@example.com appears on more than one profile.',
            ),
          ),
          onIssueSelected: (_) {},
        ),
      ),
    ),
  );
}

/// Reusable icon container for the quality plan tiles.
class _PlanIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _PlanIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

IconData _severityIcon(EmployeeDirectoryQualitySeverity severity) {
  return switch (severity) {
    EmployeeDirectoryQualitySeverity.critical => Icons.priority_high_rounded,
    EmployeeDirectoryQualitySeverity.warning => Icons.report_problem_outlined,
    EmployeeDirectoryQualitySeverity.info => Icons.info_outline,
  };
}
