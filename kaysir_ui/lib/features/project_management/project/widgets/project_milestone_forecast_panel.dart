import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_milestone_forecast_service.dart';

class ProjectMilestoneForecastPanel extends StatelessWidget {
  const ProjectMilestoneForecastPanel({
    required this.summary,
    this.maxItems = 5,
    this.onOpenProject,
    super.key,
  });

  final ProjectMilestoneForecastSummary summary;
  final int maxItems;
  final ValueChanged<String>? onOpenProject;

  @override
  Widget build(BuildContext context) {
    if (summary.totalCount == 0) {
      return const AppEmptyState(
        icon: Icons.flag_outlined,
        title: 'No milestone pressure',
        message: 'Open milestones inside the forecast window will appear here.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final visibleItems = summary.items.take(maxItems).toList();
    final nextItem = summary.nextItem;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppMetricGrid(
          minTileWidth: 150,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Milestones',
              value: summary.totalCount.toString(),
              icon: Icons.flag_outlined,
              accentColor: colorScheme.primary,
              helper: 'Next ${summary.horizonDays} days',
            ),
            AppMetricGridItem(
              title: 'Overdue',
              value: summary.overdueCount.toString(),
              icon: ProjectMilestoneForecastState.overdue.icon,
              accentColor:
                  summary.overdueCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
            ),
            AppMetricGridItem(
              title: 'Due Soon',
              value: summary.dueSoonCount.toString(),
              icon: ProjectMilestoneForecastState.dueSoon.icon,
              accentColor:
                  summary.dueSoonCount == 0
                      ? colorScheme.primary
                      : Colors.orange.shade700,
            ),
            AppMetricGridItem(
              title: 'Next Due',
              value: nextItem == null ? '-' : _compactDueLabel(nextItem),
              icon: Icons.event_note_outlined,
              accentColor:
                  nextItem == null
                      ? colorScheme.primary
                      : nextItem.state.color(colorScheme),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < visibleItems.length; index++) ...[
          _ProjectMilestoneForecastTile(
            item: visibleItems[index],
            onOpenProject:
                onOpenProject == null
                    ? null
                    : () => onOpenProject!(visibleItems[index].projectId),
          ),
          if (index != visibleItems.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  String _compactDueLabel(ProjectMilestoneForecastItem item) {
    if (item.daysFromToday < 0) return '${item.daysFromToday.abs()}d late';
    if (item.daysFromToday == 0) return 'Today';
    return '${item.daysFromToday}d';
  }
}

class _ProjectMilestoneForecastTile extends StatelessWidget {
  const _ProjectMilestoneForecastTile({
    required this.item,
    required this.onOpenProject,
  });

  final ProjectMilestoneForecastItem item;
  final VoidCallback? onOpenProject;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d');
    final stateColor = item.state.color(colorScheme);

    return AppInfoRow(
      title: item.label,
      subtitle: projectMilestoneForecastDetail(item),
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
            maxWidth: 118,
          ),
          AppStatusPill(
            label: dateFormat.format(item.dueDate),
            icon: Icons.event_outlined,
            color: colorScheme.primary,
            maxWidth: 94,
          ),
          if (onOpenProject != null)
            AppActionButton(
              label: 'Project',
              icon: Icons.open_in_new_rounded,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: onOpenProject,
            ),
        ],
      ),
    );
  }
}
