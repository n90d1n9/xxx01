import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_delivery_command_service.dart';

class ProjectDeliveryCommandSummaryGrid extends StatelessWidget {
  const ProjectDeliveryCommandSummaryGrid({required this.summary, super.key});

  final ProjectDeliveryCommandSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppMetricGrid(
      minTileWidth: 180,
      metrics: [
        AppMetricGridItem(
          title: 'Command Items',
          value: summary.totalCount.toString(),
          icon: Icons.rule_folder_outlined,
          accentColor: colorScheme.primary,
        ),
        AppMetricGridItem(
          title: 'Critical',
          value: summary.criticalCount.toString(),
          icon: Icons.priority_high_rounded,
          accentColor:
              summary.criticalCount == 0
                  ? Colors.green.shade700
                  : colorScheme.error,
        ),
        AppMetricGridItem(
          title: 'Warnings',
          value: summary.warningCount.toString(),
          icon: Icons.warning_amber_rounded,
          accentColor: Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Dependency Items',
          value: summary.dependencyCount.toString(),
          icon: Icons.link_rounded,
          accentColor:
              summary.dependencyCount == 0
                  ? Colors.green.shade700
                  : colorScheme.error,
        ),
        AppMetricGridItem(
          title: 'Projects Touched',
          value: summary.projectCount.toString(),
          icon: Icons.workspaces_outline,
          accentColor: Colors.indigo.shade600,
        ),
      ],
    );
  }
}

class ProjectDeliveryCommandQueue extends StatelessWidget {
  const ProjectDeliveryCommandQueue({
    required this.commands,
    this.onOpenProject,
    this.onFocusGantt,
    this.emptyTitle = 'No command items',
    this.emptyMessage =
        'Projects, milestones, budgets, and dependencies are clear.',
    super.key,
  });

  final List<ProjectDeliveryCommand> commands;
  final ValueChanged<String>? onOpenProject;
  final void Function(String projectId, String? taskId)? onFocusGantt;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (commands.isEmpty) {
      return AppEmptyState(
        icon: Icons.task_alt_outlined,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return Column(
      children: [
        for (var index = 0; index < commands.length; index++) ...[
          ProjectDeliveryCommandTile(
            command: commands[index],
            onOpenProject:
                onOpenProject == null
                    ? null
                    : () => onOpenProject!(commands[index].projectId),
            onFocusGantt:
                onFocusGantt == null
                    ? null
                    : () => onFocusGantt!(
                      commands[index].projectId,
                      commands[index].taskId,
                    ),
          ),
          if (index != commands.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class ProjectDeliveryCommandFilteredQueue extends StatefulWidget {
  const ProjectDeliveryCommandFilteredQueue({
    required this.commands,
    this.filteredCommands,
    this.filter,
    this.onFilterChanged,
    this.onOpenProject,
    this.onFocusGantt,
    super.key,
  });

  final List<ProjectDeliveryCommand> commands;
  final List<ProjectDeliveryCommand>? filteredCommands;
  final ProjectDeliveryCommandFilter? filter;
  final ValueChanged<ProjectDeliveryCommandFilter>? onFilterChanged;
  final ValueChanged<String>? onOpenProject;
  final void Function(String projectId, String? taskId)? onFocusGantt;

  @override
  State<ProjectDeliveryCommandFilteredQueue> createState() =>
      _ProjectDeliveryCommandFilteredQueueState();
}

class _ProjectDeliveryCommandFilteredQueueState
    extends State<ProjectDeliveryCommandFilteredQueue> {
  ProjectDeliveryCommandFilter _fallbackFilter =
      ProjectDeliveryCommandFilter.empty;

  @override
  Widget build(BuildContext context) {
    final filter = widget.filter ?? _fallbackFilter;
    final filteredCommands =
        widget.filteredCommands ??
        filterProjectDeliveryCommands(
          commands: widget.commands,
          filter: filter,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProjectDeliveryCommandFilterBar(
          commands: widget.commands,
          filter: filter,
          onFilterChanged: _setFilter,
        ),
        const SizedBox(height: 12),
        ProjectDeliveryCommandQueue(
          commands: filteredCommands,
          onOpenProject: widget.onOpenProject,
          onFocusGantt: widget.onFocusGantt,
          emptyTitle: 'No matching command items',
          emptyMessage: 'Try another priority or signal filter.',
        ),
      ],
    );
  }

  void _setFilter(ProjectDeliveryCommandFilter filter) {
    final onFilterChanged = widget.onFilterChanged;
    if (onFilterChanged != null) {
      onFilterChanged(filter);
      return;
    }

    setState(() => _fallbackFilter = filter);
  }
}

class _ProjectDeliveryCommandFilterBar extends StatelessWidget {
  const _ProjectDeliveryCommandFilterBar({
    required this.commands,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<ProjectDeliveryCommand> commands;
  final ProjectDeliveryCommandFilter filter;
  final ValueChanged<ProjectDeliveryCommandFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterChipGroup<ProjectDeliveryCommandLevel?>(
          value: filter.level,
          options: [
            AppFilterChipOption<ProjectDeliveryCommandLevel?>(
              value: null,
              label: 'All Priorities',
              icon: Icons.filter_list_rounded,
              count: commands.length,
            ),
            for (final level in ProjectDeliveryCommandLevel.values)
              AppFilterChipOption<ProjectDeliveryCommandLevel?>(
                value: level,
                label: level.label,
                icon: level.icon,
                count:
                    commands.where((command) => command.level == level).length,
              ),
          ],
          onChanged: (level) => onFilterChanged(filter.withLevel(level)),
        ),
        const SizedBox(height: 10),
        AppFilterChipGroup<ProjectDeliveryCommandKind?>(
          value: filter.kind,
          options: [
            AppFilterChipOption<ProjectDeliveryCommandKind?>(
              value: null,
              label: 'All Signals',
              icon: Icons.category_outlined,
              count: commands.length,
            ),
            for (final kind in ProjectDeliveryCommandKind.values)
              AppFilterChipOption<ProjectDeliveryCommandKind?>(
                value: kind,
                label: kind.label,
                icon: kind.icon,
                count: commands.where((command) => command.kind == kind).length,
              ),
          ],
          onChanged: (kind) => onFilterChanged(filter.withKind(kind)),
        ),
        if (filter.hasActiveFilters) ...[
          const SizedBox(height: 10),
          AppActionButton(
            label: 'Reset filters',
            icon: Icons.filter_alt_off_outlined,
            compact: true,
            height: 34,
            variant: AppActionButtonVariant.text,
            onPressed:
                () => onFilterChanged(ProjectDeliveryCommandFilter.empty),
          ),
        ],
      ],
    );
  }
}

class ProjectDeliveryCommandTile extends StatelessWidget {
  const ProjectDeliveryCommandTile({
    required this.command,
    this.onOpenProject,
    this.onFocusGantt,
    super.key,
  });

  final ProjectDeliveryCommand command;
  final VoidCallback? onOpenProject;
  final VoidCallback? onFocusGantt;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = command.level.color(colorScheme);

    return AppInfoRow(
      title: command.title,
      subtitle: '${command.projectName} - ${command.detail}',
      icon: command.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: command.level.label,
            icon: command.level.icon,
            color: levelColor,
            maxWidth: 120,
          ),
          if (onFocusGantt != null)
            AppActionButton(
              label: 'Gantt',
              icon: Icons.timeline_outlined,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: onFocusGantt,
            ),
          if (onOpenProject != null)
            AppActionButton(
              label: 'Project',
              icon: Icons.open_in_new_rounded,
              compact: true,
              onPressed: onOpenProject,
            ),
        ],
      ),
    );
  }
}
