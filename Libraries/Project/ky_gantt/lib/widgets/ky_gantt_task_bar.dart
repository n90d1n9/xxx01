import 'package:flutter/material.dart';

import '../models/gantt_chart_display_options.dart';
import '../models/gantt_task.dart';
import '../utils/gantt_task_formatters.dart';
import 'ky_gantt_selection_focus.dart';

class KyGanttTaskBar extends StatelessWidget {
  const KyGanttTaskBar({
    required this.task,
    required this.selected,
    this.dependencyFocused = false,
    this.dependencyConflicted = false,
    this.displayOptions = const KyGanttChartDisplayOptions(),
    this.avatars = const [],
    this.startsBeforeRange = false,
    this.endsAfterRange = false,
    this.today,
    this.semanticLabel,
    this.onTap,
    super.key,
  });

  final GanttTask task;
  final bool selected;
  final bool dependencyFocused;
  final bool dependencyConflicted;
  final KyGanttChartDisplayOptions displayOptions;
  final List<KyGanttTaskAvatar> avatars;
  final bool startsBeforeRange;
  final bool endsAfterRange;
  final DateTime? today;
  final String? semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = task.progress.clamp(0, 1).toDouble();
    final progressText = ganttTaskProgressLabel(task);
    final scheduleStatus = ganttTaskScheduleStatusFor(task, today: today);
    final scheduleColor = _scheduleStatusColor(colorScheme, scheduleStatus);
    final effectiveFocus = dependencyFocused && !selected;
    final selectedFocus = selected && displayOptions.showSelectedTaskFocus;
    final dependencyFocusColor =
        displayOptions.dependencyLines.highlightColor ?? colorScheme.primary;
    final showDependencyConflict =
        displayOptions.showTaskBarDependencyConflictBadges &&
            dependencyConflicted;
    final conflictColor = colorScheme.error;
    final borderColor = selected
        ? colorScheme.primary
        : effectiveFocus
            ? dependencyFocusColor
            : showDependencyConflict
                ? conflictColor
                : task.color;
    final borderWidth = selected || effectiveFocus ? 2.0 : 1.0;
    final shadowColor = selected || effectiveFocus ? borderColor : task.color;
    final shadowAlpha = selected
        ? 0.24
        : effectiveFocus
            ? 0.20
            : 0.16;
    final shadowBlur = selected
        ? 14.0
        : effectiveFocus
            ? 13.0
            : 10.0;

    final taskBar = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: task.color.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: _taskBarShadows(
              colorScheme: colorScheme,
              shadowColor: shadowColor,
              shadowAlpha: shadowAlpha,
              shadowBlur: shadowBlur,
              selectedFocus: selectedFocus,
              elevated: selected || effectiveFocus,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: progress,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: task.color),
                ),
              ),
              if (startsBeforeRange)
                const _KyGanttClippedEdge(alignment: Alignment.centerLeft),
              if (endsAfterRange)
                const _KyGanttClippedEdge(alignment: Alignment.centerRight),
              if (effectiveFocus)
                _KyGanttDependencyFocusTint(color: dependencyFocusColor),
              if (displayOptions.taskBarScheduleBadge.visible &&
                  displayOptions.taskBarScheduleBadge.showAccent)
                _KyGanttTaskScheduleAccent(
                  key: ValueKey('ky-gantt-task-schedule-accent-${task.id}'),
                  color: scheduleColor,
                ),
              _KyGanttTaskBarContent(
                task: task,
                progress: progress,
                progressText: progressText,
                scheduleStatus: scheduleStatus,
                scheduleColor: scheduleColor,
                avatars: avatars,
                displayOptions: displayOptions,
                dependencyConflicted: dependencyConflicted,
              ),
            ],
          ),
        ),
      ),
    );

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: _semanticLabel(progressText),
      explicitChildNodes: true,
      child: displayOptions.taskBarTooltip.visible
          ? Tooltip(
              message: _tooltipMessage(progressText),
              waitDuration: const Duration(milliseconds: 350),
              child: taskBar,
            )
          : taskBar,
    );
  }

  String _tooltipMessage(String progressText) {
    final tooltipOptions = displayOptions.taskBarTooltip;
    final lines = <String>[task.title];

    if (tooltipOptions.showStatus) {
      lines.add('Status: ${ganttTaskStatusLabel(task)}');
    }
    if (tooltipOptions.showProgress) {
      lines.add('Progress: $progressText');
    }
    if (tooltipOptions.showDateRange) {
      lines.add('Dates: ${ganttTaskDateRangeLabel(task)}');
    }
    if (tooltipOptions.showDuration) {
      lines.add('Duration: ${ganttTaskDurationLabel(task)}');
    }
    if (displayOptions.taskBarScheduleBadge.visible) {
      lines
          .add('Schedule: ${ganttTaskScheduleStatusLabel(task, today: today)}');
    }
    if (tooltipOptions.showDependency && ganttTaskHasDependency(task)) {
      lines.add('Depends on: ${task.dependsOn!.trim()}');
    }
    if (tooltipOptions.showAssignees && avatars.isNotEmpty) {
      lines.add(
        'Team: ${avatars.map((avatar) => avatar.tooltip ?? avatar.label).join(', ')}',
      );
    }
    if (dependencyFocused && !selected) {
      lines.add('Focus: dependency relationship');
    }
    if (displayOptions.showTaskBarDependencyConflictBadges &&
        dependencyConflicted) {
      lines.add('Risk: dependency conflict');
    }
    if (tooltipOptions.showClipHints && startsBeforeRange && endsAfterRange) {
      lines.add('Visible range clips both ends');
    } else if (tooltipOptions.showClipHints && startsBeforeRange) {
      lines.add('Starts before visible range');
    } else if (tooltipOptions.showClipHints && endsAfterRange) {
      lines.add('Continues after visible range');
    }

    return lines.join('\n');
  }

  Color _scheduleStatusColor(
    ColorScheme colorScheme,
    GanttTaskScheduleStatus status,
  ) {
    final options = displayOptions.taskBarScheduleBadge;
    switch (status) {
      case GanttTaskScheduleStatus.planned:
        return options.plannedColor ?? colorScheme.onSurfaceVariant;
      case GanttTaskScheduleStatus.inProgress:
        return options.inProgressColor ?? colorScheme.primary;
      case GanttTaskScheduleStatus.dueToday:
        return options.dueTodayColor ?? colorScheme.tertiary;
      case GanttTaskScheduleStatus.overdue:
        return options.overdueColor ?? colorScheme.error;
      case GanttTaskScheduleStatus.complete:
        return options.completeColor ?? colorScheme.tertiary;
    }
  }

  String _semanticLabel(String progressText) {
    final baseLabel = semanticLabel ?? '${task.title}, $progressText';
    final dependencyHint =
        task.dependsOn?.trim().isNotEmpty == true ? ', has predecessor' : '';
    final conflictHint = displayOptions.showTaskBarDependencyConflictBadges &&
            dependencyConflicted
        ? ', dependency conflict'
        : '';
    if (!dependencyFocused || selected) {
      return '$baseLabel$dependencyHint$conflictHint';
    }

    return '$baseLabel$dependencyHint$conflictHint, dependency focus';
  }

  List<BoxShadow>? _taskBarShadows({
    required ColorScheme colorScheme,
    required Color shadowColor,
    required double shadowAlpha,
    required double shadowBlur,
    required bool selectedFocus,
    required bool elevated,
  }) {
    final shadowOptions = displayOptions.taskBarShadow;
    final opacityScale = shadowOptions.opacityScale.clamp(0, 3).toDouble();
    final blurScale = shadowOptions.blurScale.clamp(0, 3).toDouble();
    final offsetScale = shadowOptions.offsetScale.clamp(0, 3).toDouble();
    final shadows = <BoxShadow>[
      if (selectedFocus) ...kyGanttSelectedTaskFocusShadows(colorScheme),
      if (displayOptions.showTaskBarShadows)
        BoxShadow(
          color: shadowColor.withValues(
            alpha: (shadowAlpha * opacityScale).clamp(0, 1).toDouble(),
          ),
          blurRadius: shadowBlur * blurScale,
          offset: Offset(0, (elevated ? 5 : 3) * offsetScale),
        ),
    ];

    return shadows.isEmpty ? null : shadows;
  }
}

class _KyGanttTaskBarContent extends StatelessWidget {
  const _KyGanttTaskBarContent({
    required this.task,
    required this.progress,
    required this.progressText,
    required this.scheduleStatus,
    required this.scheduleColor,
    required this.avatars,
    required this.displayOptions,
    required this.dependencyConflicted,
  });

  final GanttTask task;
  final double progress;
  final String progressText;
  final GanttTaskScheduleStatus scheduleStatus;
  final Color scheduleColor;
  final List<KyGanttTaskAvatar> avatars;
  final KyGanttChartDisplayOptions displayOptions;
  final bool dependencyConflicted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = progress > 0.42 ? Colors.white : colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth =
            (constraints.maxWidth - 20).clamp(0, double.infinity).toDouble();
        final avatarOptions = displayOptions.taskBarAvatar;
        final showAvatars = displayOptions.showTaskBarAvatars &&
            avatars.isNotEmpty &&
            contentWidth >= avatarOptions.normalizedMinTaskBarWidth;
        final showScheduleBadge = displayOptions.taskBarScheduleBadge.visible &&
            displayOptions.taskBarScheduleBadge.showLabel &&
            contentWidth >= 158;
        final showProgressLabel = displayOptions.showTaskBarProgressLabels &&
            contentWidth >=
                (showAvatars ? 168 : 118) + (showScheduleBadge ? 88 : 0);
        final showStatusLabel = displayOptions.showTaskBarStatusLabels &&
            contentWidth >=
                _statusLabelMinWidth(
                  showAvatars: showAvatars,
                  showProgressLabel: showProgressLabel,
                  showScheduleBadge: showScheduleBadge,
                );
        final showDateLabel = displayOptions.showTaskBarDateLabels &&
            contentWidth >=
                _dateLabelMinWidth(
                  showAvatars: showAvatars,
                  showProgressLabel: showProgressLabel,
                  showStatusLabel: showStatusLabel,
                  showScheduleBadge: showScheduleBadge,
                );
        final showDurationLabel = displayOptions.showTaskBarDurationLabels &&
            contentWidth >=
                _durationLabelMinWidth(
                  showAvatars: showAvatars,
                  showProgressLabel: showProgressLabel,
                  showStatusLabel: showStatusLabel,
                  showDateLabel: showDateLabel,
                  showScheduleBadge: showScheduleBadge,
                );
        final showDependencyBadge =
            displayOptions.showTaskBarDependencyBadges &&
                _hasDependency &&
                contentWidth >=
                    _dependencyBadgeMinWidth(
                      showAvatars: showAvatars,
                      showProgressLabel: showProgressLabel,
                      showStatusLabel: showStatusLabel,
                      showDateLabel: showDateLabel,
                      showDurationLabel: showDurationLabel,
                      showScheduleBadge: showScheduleBadge,
                    );
        final showConflictBadge =
            displayOptions.showTaskBarDependencyConflictBadges &&
                dependencyConflicted &&
                contentWidth >=
                    _conflictBadgeMinWidth(
                      showAvatars: showAvatars,
                      showProgressLabel: showProgressLabel,
                      showStatusLabel: showStatusLabel,
                      showDateLabel: showDateLabel,
                      showDurationLabel: showDurationLabel,
                      showDependencyBadge: showDependencyBadge,
                      showScheduleBadge: showScheduleBadge,
                    );
        final status = ganttTaskStatusFor(task);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              if (showDateLabel) ...[
                const SizedBox(width: 8),
                _KyGanttTaskDateLabel(
                  key: ValueKey('ky-gantt-task-date-label-${task.id}'),
                  task: task,
                  prominent: progress > 0.42,
                ),
              ],
              if (showScheduleBadge) ...[
                const SizedBox(width: 8),
                _KyGanttTaskScheduleBadge(
                  key: ValueKey('ky-gantt-task-schedule-badge-${task.id}'),
                  status: scheduleStatus,
                  color: scheduleColor,
                  prominent: progress > 0.42,
                ),
              ],
              if (showDurationLabel) ...[
                const SizedBox(width: 8),
                _KyGanttTaskDurationLabel(
                  key: ValueKey('ky-gantt-task-duration-label-${task.id}'),
                  task: task,
                  prominent: progress > 0.42,
                ),
              ],
              if (showDependencyBadge) ...[
                const SizedBox(width: 8),
                _KyGanttTaskDependencyBadge(
                  key: ValueKey('ky-gantt-task-dependency-badge-${task.id}'),
                  prominent: progress > 0.42,
                ),
              ],
              if (showConflictBadge) ...[
                const SizedBox(width: 8),
                _KyGanttTaskDependencyConflictBadge(
                  key: ValueKey(
                    'ky-gantt-task-dependency-conflict-badge-${task.id}',
                  ),
                  prominent: progress > 0.42,
                ),
              ],
              if (showStatusLabel) ...[
                const SizedBox(width: 8),
                _KyGanttTaskStatusLabel(
                  key: ValueKey('ky-gantt-task-status-label-${task.id}'),
                  status: status,
                  prominent: progress > 0.42,
                ),
              ],
              if (showProgressLabel) ...[
                const SizedBox(width: 8),
                _KyGanttTaskProgressLabel(
                  key: ValueKey('ky-gantt-task-progress-label-${task.id}'),
                  progressText: progressText,
                  prominent: progress > 0.42,
                ),
              ],
              if (showAvatars) ...[
                const SizedBox(width: 8),
                KyGanttTaskAvatarStack(
                  avatars: avatars,
                  maxVisible: displayOptions.maxTaskBarAvatars,
                  size: avatarOptions.normalizedSize,
                  overlap: avatarOptions.normalizedOverlap,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  double _statusLabelMinWidth({
    required bool showAvatars,
    required bool showProgressLabel,
    required bool showScheduleBadge,
  }) {
    var minWidth = 150.0;
    if (showProgressLabel) minWidth += 52;
    if (showAvatars) minWidth += 64;
    if (showScheduleBadge) minWidth += 88;
    return minWidth;
  }

  double _dateLabelMinWidth({
    required bool showAvatars,
    required bool showProgressLabel,
    required bool showStatusLabel,
    required bool showScheduleBadge,
  }) {
    var minWidth = 176.0;
    if (showStatusLabel) minWidth += 70;
    if (showProgressLabel) minWidth += 52;
    if (showAvatars) minWidth += 64;
    if (showScheduleBadge) minWidth += 88;
    return minWidth;
  }

  bool get _hasDependency => ganttTaskHasDependency(task);

  double _durationLabelMinWidth({
    required bool showAvatars,
    required bool showProgressLabel,
    required bool showStatusLabel,
    required bool showDateLabel,
    required bool showScheduleBadge,
  }) {
    var minWidth = 142.0;
    if (showDateLabel) minWidth += 80;
    if (showStatusLabel) minWidth += 70;
    if (showProgressLabel) minWidth += 52;
    if (showAvatars) minWidth += 64;
    if (showScheduleBadge) minWidth += 88;
    return minWidth;
  }

  double _dependencyBadgeMinWidth({
    required bool showAvatars,
    required bool showProgressLabel,
    required bool showStatusLabel,
    required bool showDateLabel,
    required bool showDurationLabel,
    required bool showScheduleBadge,
  }) {
    var minWidth = 150.0;
    if (showDateLabel) minWidth += 80;
    if (showDurationLabel) minWidth += 50;
    if (showStatusLabel) minWidth += 70;
    if (showProgressLabel) minWidth += 52;
    if (showAvatars) minWidth += 64;
    if (showScheduleBadge) minWidth += 88;
    return minWidth;
  }

  double _conflictBadgeMinWidth({
    required bool showAvatars,
    required bool showProgressLabel,
    required bool showStatusLabel,
    required bool showDateLabel,
    required bool showDurationLabel,
    required bool showDependencyBadge,
    required bool showScheduleBadge,
  }) {
    var minWidth = 158.0;
    if (showDateLabel) minWidth += 80;
    if (showDurationLabel) minWidth += 50;
    if (showDependencyBadge) minWidth += 52;
    if (showStatusLabel) minWidth += 70;
    if (showProgressLabel) minWidth += 52;
    if (showAvatars) minWidth += 64;
    if (showScheduleBadge) minWidth += 88;
    return minWidth;
  }
}

class _KyGanttTaskScheduleAccent extends StatelessWidget {
  const _KyGanttTaskScheduleAccent({
    required super.key,
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 4,
          height: double.infinity,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.86),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class _KyGanttTaskScheduleBadge extends StatelessWidget {
  const _KyGanttTaskScheduleBadge({
    required super.key,
    required this.status,
    required this.color,
    required this.prominent,
  });

  final GanttTaskScheduleStatus status;
  final Color color;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = prominent ? Colors.white : color;
    final backgroundColor = prominent
        ? Colors.white.withValues(alpha: 0.18)
        : color.withValues(alpha: 0.11);
    final borderColor = prominent
        ? Colors.white.withValues(alpha: 0.28)
        : color.withValues(alpha: 0.30);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _icon,
                size: 11,
                color: foregroundColor,
              ),
              const SizedBox(width: 3),
              Text(
                ganttTaskScheduleBadgeText(status),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    switch (status) {
      case GanttTaskScheduleStatus.planned:
        return Icons.schedule_rounded;
      case GanttTaskScheduleStatus.inProgress:
        return Icons.play_circle_outline_rounded;
      case GanttTaskScheduleStatus.dueToday:
        return Icons.event_available_outlined;
      case GanttTaskScheduleStatus.overdue:
        return Icons.warning_amber_rounded;
      case GanttTaskScheduleStatus.complete:
        return Icons.check_circle_outline_rounded;
    }
  }
}

class _KyGanttTaskStatusLabel extends StatelessWidget {
  const _KyGanttTaskStatusLabel({
    required super.key,
    required this.status,
    required this.prominent,
  });

  final GanttTaskStatus status;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _statusColor(colorScheme);
    final foregroundColor = prominent ? Colors.white : statusColor;
    final backgroundColor = prominent
        ? Colors.white.withValues(alpha: 0.16)
        : statusColor.withValues(alpha: 0.12);
    final borderColor = prominent
        ? Colors.white.withValues(alpha: 0.26)
        : statusColor.withValues(alpha: 0.28);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          child: Text(
            ganttTaskStatusText(status),
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (status) {
      case GanttTaskStatus.planned:
        return colorScheme.onSurfaceVariant;
      case GanttTaskStatus.active:
        return colorScheme.primary;
      case GanttTaskStatus.done:
        return colorScheme.tertiary;
    }
  }
}

class _KyGanttTaskDateLabel extends StatelessWidget {
  const _KyGanttTaskDateLabel({
    required super.key,
    required this.task,
    required this.prominent,
  });

  final GanttTask task;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        prominent ? Colors.white : colorScheme.onSurfaceVariant;
    final backgroundColor = prominent
        ? Colors.white.withValues(alpha: 0.16)
        : colorScheme.surface.withValues(alpha: 0.70);
    final borderColor = prominent
        ? Colors.white.withValues(alpha: 0.26)
        : colorScheme.outlineVariant.withValues(alpha: 0.48);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          child: Text(
            ganttTaskDateRangeLabel(task),
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
          ),
        ),
      ),
    );
  }
}

class _KyGanttTaskDurationLabel extends StatelessWidget {
  const _KyGanttTaskDurationLabel({
    required super.key,
    required this.task,
    required this.prominent,
  });

  final GanttTask task;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        prominent ? Colors.white : colorScheme.onSurfaceVariant;
    final backgroundColor = prominent
        ? Colors.white.withValues(alpha: 0.15)
        : colorScheme.surface.withValues(alpha: 0.68);
    final borderColor = prominent
        ? Colors.white.withValues(alpha: 0.24)
        : colorScheme.outlineVariant.withValues(alpha: 0.44);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          child: Text(
            ganttTaskDurationLabel(task),
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
          ),
        ),
      ),
    );
  }
}

class _KyGanttTaskDependencyBadge extends StatelessWidget {
  const _KyGanttTaskDependencyBadge({
    required super.key,
    required this.prominent,
  });

  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        prominent ? Colors.white : colorScheme.onSurfaceVariant;
    final backgroundColor = prominent
        ? Colors.white.withValues(alpha: 0.15)
        : colorScheme.secondaryContainer.withValues(alpha: 0.62);
    final borderColor = prominent
        ? Colors.white.withValues(alpha: 0.24)
        : colorScheme.outlineVariant.withValues(alpha: 0.44);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          child: Text(
            '1 dep',
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
          ),
        ),
      ),
    );
  }
}

class _KyGanttTaskDependencyConflictBadge extends StatelessWidget {
  const _KyGanttTaskDependencyConflictBadge({
    required super.key,
    required this.prominent,
  });

  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final errorColor = colorScheme.error;
    final foregroundColor = prominent ? Colors.white : errorColor;
    final backgroundColor = prominent
        ? Colors.white.withValues(alpha: 0.18)
        : errorColor.withValues(alpha: 0.10);
    final borderColor = prominent
        ? Colors.white.withValues(alpha: 0.26)
        : errorColor.withValues(alpha: 0.28);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 11,
                color: foregroundColor,
              ),
              const SizedBox(width: 3),
              Text(
                'Risk',
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KyGanttTaskProgressLabel extends StatelessWidget {
  const _KyGanttTaskProgressLabel({
    required super.key,
    required this.progressText,
    required this.prominent,
  });

  final String progressText;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor =
        prominent ? Colors.white : colorScheme.onSurfaceVariant;
    final backgroundColor = prominent
        ? Colors.white.withValues(alpha: 0.18)
        : colorScheme.surface.withValues(alpha: 0.74);
    final borderColor = prominent
        ? Colors.white.withValues(alpha: 0.28)
        : colorScheme.outlineVariant.withValues(alpha: 0.52);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            progressText,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
          ),
        ),
      ),
    );
  }
}

class _KyGanttDependencyFocusTint extends StatelessWidget {
  const _KyGanttDependencyFocusTint({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              color.withValues(alpha: 0.20),
              color.withValues(alpha: 0.04),
            ],
          ),
        ),
      ),
    );
  }
}

class KyGanttTaskAvatarStack extends StatelessWidget {
  const KyGanttTaskAvatarStack({
    required this.avatars,
    this.maxVisible = 3,
    this.size = 22,
    this.overlap = 8,
    super.key,
  });

  final List<KyGanttTaskAvatar> avatars;
  final int maxVisible;
  final double size;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    final normalizedMax = maxVisible.clamp(1, 5).toInt();
    final hasOverflow = avatars.length > normalizedMax;
    final visibleAvatarCount = hasOverflow
        ? (normalizedMax - 1).clamp(0, normalizedMax).toInt()
        : normalizedMax;
    final visibleAvatars = avatars.take(visibleAvatarCount).toList();
    final overflowAvatars = avatars.skip(visibleAvatarCount).toList();
    final overflowCount = avatars.length - visibleAvatars.length;
    final itemCount = visibleAvatars.length + (overflowCount > 0 ? 1 : 0);
    if (itemCount == 0) return const SizedBox.shrink();

    final visibleStep = size - overlap;
    final width = size + ((itemCount - 1) * visibleStep);

    return SizedBox(
      key: const ValueKey('ky-gantt-task-avatar-stack'),
      width: width,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < visibleAvatars.length; index++)
            Positioned(
              left: index * visibleStep,
              child: _KyGanttTaskAvatarChip(
                avatar: visibleAvatars[index],
                size: size,
              ),
            ),
          if (overflowCount > 0)
            Positioned(
              left: visibleAvatars.length * visibleStep,
              child: _KyGanttTaskAvatarOverflow(
                avatars: overflowAvatars,
                size: size,
              ),
            ),
        ],
      ),
    );
  }
}

class _KyGanttTaskAvatarChip extends StatelessWidget {
  const _KyGanttTaskAvatarChip({
    required this.avatar,
    required this.size,
  });

  final KyGanttTaskAvatar avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = avatar.color ?? _fallbackColor(context, avatar.id);
    final foregroundColor =
        ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
            ? Colors.white
            : colorScheme.onSurface;
    final tooltip = _avatarAccessibleLabel(avatar);
    final chip = Container(
      key: ValueKey('ky-gantt-task-avatar-${avatar.id}'),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.surface, width: 2),
        boxShadow: _avatarChipShadows(colorScheme),
      ),
      child: Text(
        avatar.displayInitials,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w900,
              fontSize: 9,
            ),
      ),
    );

    return Semantics(
      container: true,
      label: 'Team member: $tooltip',
      child: Tooltip(
        message: tooltip,
        excludeFromSemantics: true,
        waitDuration: const Duration(milliseconds: 350),
        child: ExcludeSemantics(child: chip),
      ),
    );
  }

  Color _fallbackColor(BuildContext context, String seed) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = [
      colorScheme.primary,
      colorScheme.tertiary,
      colorScheme.secondary,
      Colors.teal.shade700,
      Colors.indigo.shade600,
      Colors.pink.shade600,
    ];
    final hash = seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return palette[hash % palette.length];
  }
}

class _KyGanttTaskAvatarOverflow extends StatelessWidget {
  const _KyGanttTaskAvatarOverflow({
    required this.avatars,
    required this.size,
  });

  final List<KyGanttTaskAvatar> avatars;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final count = avatars.length;
    final labels = avatars.map(_avatarAccessibleLabel).toList();
    final tooltipTitle =
        count == 1 ? '1 more team member' : '$count more team members';
    final tooltipMessage = '$tooltipTitle\n${labels.join('\n')}';
    final semanticsLabel = '$tooltipTitle: ${labels.join(', ')}';

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Tooltip(
        message: tooltipMessage,
        excludeFromSemantics: true,
        waitDuration: const Duration(milliseconds: 350),
        child: ExcludeSemantics(
          child: Container(
            key: const ValueKey('ky-gantt-task-avatar-overflow'),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
              boxShadow: _avatarChipShadows(colorScheme),
            ),
            child: Text(
              '+$count',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

String _avatarAccessibleLabel(KyGanttTaskAvatar avatar) {
  final tooltip = avatar.tooltip?.trim();
  if (tooltip != null && tooltip.isNotEmpty) return tooltip;

  return avatar.label;
}

List<BoxShadow> _avatarChipShadows(ColorScheme colorScheme) {
  return [
    BoxShadow(
      color: colorScheme.shadow.withValues(alpha: 0.14),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
}

class _KyGanttClippedEdge extends StatelessWidget {
  const _KyGanttClippedEdge({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final isStart = alignment == Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        width: 4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.horizontal(
            left: isStart ? const Radius.circular(8) : Radius.zero,
            right: isStart ? Radius.zero : const Radius.circular(8),
          ),
        ),
      ),
    );
  }
}
