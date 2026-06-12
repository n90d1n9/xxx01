import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../services/project_timeline_health_service.dart';

enum ProjectTimelineHealthIssueFilter {
  all,
  dependencyBlock,
  overdue,
  dueSoon,
  active,
}

class ProjectTimelineHealthIssueList extends StatefulWidget {
  const ProjectTimelineHealthIssueList({
    required this.issues,
    this.maxItems = 5,
    this.today,
    this.onTaskFocus,
    super.key,
  });

  final List<ProjectTimelineHealthIssue> issues;
  final int maxItems;
  final DateTime? today;
  final ValueChanged<gantt.GanttTask>? onTaskFocus;

  @override
  State<ProjectTimelineHealthIssueList> createState() =>
      _ProjectTimelineHealthIssueListState();
}

class _ProjectTimelineHealthIssueListState
    extends State<ProjectTimelineHealthIssueList> {
  var _filter = ProjectTimelineHealthIssueFilter.all;

  @override
  Widget build(BuildContext context) {
    if (widget.issues.isEmpty) {
      return const AppInfoRow(
        title: 'No timeline attention',
        subtitle: 'Linked tasks have no active schedule or dependency alerts.',
        icon: Icons.check_circle_outline,
        iconStyle: AppInfoRowIconStyle.badge,
        contained: true,
      );
    }

    final visibleIssues =
        widget.issues.where(_filter.matches).take(widget.maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFilterChipGroup<ProjectTimelineHealthIssueFilter>(
          value: _filter,
          options: [
            AppFilterChipOption(
              value: ProjectTimelineHealthIssueFilter.all,
              label: ProjectTimelineHealthIssueFilter.all.label,
              icon: ProjectTimelineHealthIssueFilter.all.icon,
              count: widget.issues.length,
            ),
            for (final filter in ProjectTimelineHealthIssueFilter.values.where(
              (filter) => filter != ProjectTimelineHealthIssueFilter.all,
            ))
              AppFilterChipOption(
                value: filter,
                label: filter.label,
                icon: filter.icon,
                count: widget.issues.where(filter.matches).length,
              ),
          ],
          onChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 12),
        if (visibleIssues.isEmpty)
          AppInfoRow(
            title: 'No ${_filter.label.toLowerCase()} task signals',
            subtitle:
                'Choose another attention filter to inspect the timeline.',
            icon: _filter.icon,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
          )
        else
          for (var index = 0; index < visibleIssues.length; index++) ...[
            _ProjectTimelineHealthIssueTile(
              issue: visibleIssues[index],
              onTaskFocus:
                  widget.onTaskFocus == null
                      ? null
                      : () => widget.onTaskFocus!(visibleIssues[index].task),
            ),
            if (index != visibleIssues.length - 1) const SizedBox(height: 10),
          ],
        if (_filter == ProjectTimelineHealthIssueFilter.all &&
            widget.issues.length > widget.maxItems) ...[
          const SizedBox(height: 10),
          Text(
            'Showing ${widget.maxItems} of ${widget.issues.length} timeline signals',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _ProjectTimelineHealthIssueTile extends StatelessWidget {
  const _ProjectTimelineHealthIssueTile({
    required this.issue,
    required this.onTaskFocus,
  });

  final ProjectTimelineHealthIssue issue;
  final VoidCallback? onTaskFocus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final issueColor = issue.kind.color(colorScheme);
    final task = issue.task;

    return AppInfoRow(
      title: issue.title,
      subtitle: '${issue.detail} ${_taskDateLabel(task)}',
      icon: issue.kind.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      onTap: onTaskFocus,
      iconBackgroundColor: issueColor.withValues(alpha: 0.12),
      iconForegroundColor: issueColor,
      titleMaxLines: 1,
      subtitleMaxLines: 2,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: issue.kind.label,
            icon: issue.kind.icon,
            color: issueColor,
            maxWidth: 118,
          ),
          AppStatusPill(
            label:
                task.isMilestone
                    ? 'Milestone'
                    : '${(task.progress * 100).round()}%',
            icon:
                task.isMilestone
                    ? Icons.flag_outlined
                    : Icons.trending_up_rounded,
            color: task.color,
            maxWidth: 118,
          ),
          if (onTaskFocus != null)
            Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }

  String _taskDateLabel(gantt.GanttTask task) {
    final dateFormat = DateFormat('MMM d');

    if (task.isMilestone) {
      return 'Milestone on ${dateFormat.format(task.startDate)}.';
    }

    return '${dateFormat.format(task.startDate)} - ${dateFormat.format(task.endDate)}.';
  }
}

extension ProjectTimelineHealthIssueFilterPresentation
    on ProjectTimelineHealthIssueFilter {
  String get label {
    switch (this) {
      case ProjectTimelineHealthIssueFilter.all:
        return 'All';
      case ProjectTimelineHealthIssueFilter.dependencyBlock:
        return ProjectTimelineHealthIssueKind.dependencyBlock.label;
      case ProjectTimelineHealthIssueFilter.overdue:
        return ProjectTimelineHealthIssueKind.overdue.label;
      case ProjectTimelineHealthIssueFilter.dueSoon:
        return ProjectTimelineHealthIssueKind.dueSoon.label;
      case ProjectTimelineHealthIssueFilter.active:
        return ProjectTimelineHealthIssueKind.active.label;
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectTimelineHealthIssueFilter.all:
        return Icons.monitor_heart_outlined;
      case ProjectTimelineHealthIssueFilter.dependencyBlock:
        return ProjectTimelineHealthIssueKind.dependencyBlock.icon;
      case ProjectTimelineHealthIssueFilter.overdue:
        return ProjectTimelineHealthIssueKind.overdue.icon;
      case ProjectTimelineHealthIssueFilter.dueSoon:
        return ProjectTimelineHealthIssueKind.dueSoon.icon;
      case ProjectTimelineHealthIssueFilter.active:
        return ProjectTimelineHealthIssueKind.active.icon;
    }
  }

  bool matches(ProjectTimelineHealthIssue issue) {
    switch (this) {
      case ProjectTimelineHealthIssueFilter.all:
        return true;
      case ProjectTimelineHealthIssueFilter.dependencyBlock:
        return issue.kind == ProjectTimelineHealthIssueKind.dependencyBlock;
      case ProjectTimelineHealthIssueFilter.overdue:
        return issue.kind == ProjectTimelineHealthIssueKind.overdue;
      case ProjectTimelineHealthIssueFilter.dueSoon:
        return issue.kind == ProjectTimelineHealthIssueKind.dueSoon;
      case ProjectTimelineHealthIssueFilter.active:
        return issue.kind == ProjectTimelineHealthIssueKind.active;
    }
  }
}
