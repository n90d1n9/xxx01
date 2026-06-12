import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_portfolio_item.dart';
import '../services/project_resource_capacity_service.dart';

class ProjectResourceCapacityPanel extends StatelessWidget {
  const ProjectResourceCapacityPanel({
    required this.summary,
    this.maxItems = 6,
    this.onOpenProject,
    super.key,
  });

  final ProjectResourceCapacitySummary summary;
  final int maxItems;
  final ValueChanged<String>? onOpenProject;

  @override
  Widget build(BuildContext context) {
    if (summary.contributorCount == 0) {
      return const AppEmptyState(
        icon: Icons.groups_outlined,
        title: 'No capacity data',
        message: 'Project team allocation will appear here once assigned.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final visibleItems = summary.prioritizedItems.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppMetricGrid(
          minTileWidth: 150,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Contributors',
              value: summary.contributorCount.toString(),
              icon: Icons.groups_outlined,
              accentColor: colorScheme.primary,
            ),
            AppMetricGridItem(
              title: 'Overallocated',
              value: summary.overallocatedCount.toString(),
              icon: ProjectResourceCapacityState.overallocated.icon,
              accentColor:
                  summary.overallocatedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: 'Focused',
              value: summary.focusedCount.toString(),
              icon: ProjectResourceCapacityState.focused.icon,
              accentColor:
                  summary.focusedCount == 0
                      ? colorScheme.primary
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Avg Load',
              value: '${summary.averageAllocationPercent}%',
              icon: Icons.speed_outlined,
              accentColor: colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProjectResourceCapacityTile(
            item: visibleItems[index],
            onOpenProject: onOpenProject,
          ),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProjectResourceCapacityTile extends StatelessWidget {
  const _ProjectResourceCapacityTile({
    required this.item,
    required this.onOpenProject,
  });

  final ProjectResourceCapacityItem item;
  final ValueChanged<String>? onOpenProject;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stateColor = item.state.color(colorScheme);
    final primaryAssignment = item.primaryAssignment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: item.name,
          subtitle:
              '${item.primaryRole} - ${projectResourceCapacityDetail(item)}',
          icon: item.state.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: stateColor.withValues(alpha: 0.12),
          iconForegroundColor: stateColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppStatusPill(
                label: item.state.label,
                icon: item.state.icon,
                color: stateColor,
                maxWidth: 136,
              ),
              AppStatusPill(
                label: '${item.allocationPercent}%',
                icon: Icons.pie_chart_outline,
                color: colorScheme.primary,
                maxWidth: 96,
              ),
            ],
          ),
        ),
        if (primaryAssignment != null) ...[
          const SizedBox(height: 8),
          _ProjectResourceAssignmentRow(
            assignment: primaryAssignment,
            onOpenProject: onOpenProject,
          ),
        ],
      ],
    );
  }
}

class _ProjectResourceAssignmentRow extends StatelessWidget {
  const _ProjectResourceAssignmentRow({
    required this.assignment,
    required this.onOpenProject,
  });

  final ProjectResourceAssignment assignment;
  final ValueChanged<String>? onOpenProject;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final healthColor = assignment.health.color(colorScheme);

    return AppInfoRow(
      title: assignment.projectName,
      subtitle:
          '${assignment.role} - ${(assignment.allocation * 100).round()}% assignment',
      icon: assignment.health.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: healthColor.withValues(alpha: 0.12),
      iconForegroundColor: healthColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: assignment.health.label,
            icon: assignment.health.icon,
            color: healthColor,
            maxWidth: 118,
          ),
          if (onOpenProject != null)
            AppActionButton(
              label: 'Open',
              icon: Icons.open_in_new_rounded,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: () => onOpenProject!(assignment.projectId),
            ),
        ],
      ),
    );
  }
}
