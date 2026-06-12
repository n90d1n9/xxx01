import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/widgets/ui/app_empty_state.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../../gantt/services/gantt_schedule_health_service.dart';
import '../models/project_portfolio_item.dart';
import '../services/project_attention_service.dart';
import '../services/project_milestone_timeline_service.dart';

class ProjectDetailSummaryGrid extends StatelessWidget {
  const ProjectDetailSummaryGrid({required this.project, super.key});

  final ProjectPortfolioItem project;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppMetricGrid(
      minTileWidth: 180,
      metrics: [
        AppMetricGridItem(
          title: 'Progress',
          value: '${(project.progress * 100).round()}%',
          icon: Icons.trending_up_rounded,
          accentColor: project.health.color(colorScheme),
        ),
        AppMetricGridItem(
          title: 'Budget Used',
          value: '${(project.budgetUsed * 100).round()}%',
          icon: Icons.account_balance_wallet_outlined,
          accentColor: Colors.indigo.shade600,
        ),
        AppMetricGridItem(
          title: 'Open Milestones',
          value: project.openMilestoneCount.toString(),
          icon: Icons.flag_outlined,
          accentColor: Colors.orange.shade700,
        ),
        AppMetricGridItem(
          title: 'Delivery Risks',
          value: project.riskCount.toString(),
          icon: Icons.health_and_safety_outlined,
          accentColor: colorScheme.error,
        ),
      ],
    );
  }
}

class ProjectDetailOverview extends StatelessWidget {
  const ProjectDetailOverview({required this.project, super.key});

  final ProjectPortfolioItem project;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');
    final healthColor = project.health.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title:
              project.sponsor.isEmpty ? 'Executive sponsor' : project.sponsor,
          subtitle:
              '${dateFormat.format(project.startDate)} - ${dateFormat.format(project.endDate)}',
          icon: Icons.verified_user_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: healthColor.withValues(alpha: 0.12),
          iconForegroundColor: healthColor,
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: project.progress.clamp(0, 1),
            color: healthColor,
            backgroundColor: healthColor.withValues(alpha: 0.14),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${(project.progress * 100).round()}% complete - ${(project.budgetUsed * 100).round()}% budget used',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class ProjectAttentionPanel extends StatelessWidget {
  const ProjectAttentionPanel({
    required this.project,
    required this.timelineTasks,
    this.today,
    super.key,
  });

  final ProjectPortfolioItem project;
  final List<gantt.GanttTask> timelineTasks;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final insights = buildProjectAttentionInsights(
      project: project,
      timelineTasks: timelineTasks,
      today: today,
    );

    return Column(
      children: [
        for (var index = 0; index < insights.length; index++) ...[
          Builder(
            builder: (context) {
              final insight = insights[index];
              final insightColor = insight.level.color(colorScheme);

              return AppInfoRow(
                title: insight.title,
                subtitle: insight.detail,
                icon: insight.icon,
                iconStyle: AppInfoRowIconStyle.badge,
                contained: true,
                iconBackgroundColor: insightColor.withValues(alpha: 0.12),
                iconForegroundColor: insightColor,
                titleMaxLines: 2,
                subtitleMaxLines: 3,
                trailing: AppStatusPill(
                  label: insight.level.label,
                  color: insightColor,
                  maxWidth: 110,
                ),
              );
            },
          ),
          if (index != insights.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class ProjectMilestoneTimeline extends StatelessWidget {
  const ProjectMilestoneTimeline({
    required this.milestones,
    this.today,
    super.key,
  });

  final List<ProjectMilestone> milestones;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) {
      return const AppEmptyState(
        icon: Icons.flag_outlined,
        title: 'No milestones',
        message: 'Add target dates to make delivery checkpoints visible.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d');
    final summary = buildProjectMilestoneTimelineSummary(
      milestones: milestones,
      today: today,
    );
    final signalColor = summary.signalState.color(colorScheme);
    final nextOpen = summary.nextOpenItem;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title:
              nextOpen == null
                  ? 'All milestones complete'
                  : 'Next milestone: ${nextOpen.label}',
          subtitle:
              '${summary.openCount} open - ${summary.doneCount} done - ${summary.overdueCount} overdue',
          icon: summary.signalState.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: nextOpen?.dueLabel ?? 'Complete',
            icon: summary.signalState.icon,
            color: signalColor,
            maxWidth: 132,
          ),
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < summary.items.length; index++) ...[
          Builder(
            builder: (context) {
              final item = summary.items[index];
              final itemColor = item.state.color(colorScheme);

              return AppInfoRow(
                title: item.label,
                subtitle:
                    '${dateFormat.format(item.dueDate)} - ${item.dueLabel}',
                icon: item.state.icon,
                iconStyle: AppInfoRowIconStyle.badge,
                contained: true,
                iconBackgroundColor: itemColor.withValues(alpha: 0.12),
                iconForegroundColor: itemColor,
                titleMaxLines: 1,
                subtitleMaxLines: 2,
                trailing: AppStatusPill(
                  label: item.state.label,
                  icon: item.state.icon,
                  color: itemColor,
                  maxWidth: 118,
                ),
              );
            },
          ),
          if (index != summary.items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class ProjectRiskQueue extends StatelessWidget {
  const ProjectRiskQueue({required this.risks, super.key});

  final List<ProjectDeliveryRisk> risks;

  @override
  Widget build(BuildContext context) {
    if (risks.isEmpty) {
      return const AppEmptyState(
        icon: Icons.health_and_safety_outlined,
        title: 'No active risks',
        message: 'Delivery risks will appear here when they need attention.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (var index = 0; index < risks.length; index++) ...[
          AppInfoRow(
            title: risks[index].title,
            subtitle: risks[index].detail,
            icon: risks[index].severity.icon,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: risks[index].severity
                .color(colorScheme)
                .withValues(alpha: 0.12),
            iconForegroundColor: risks[index].severity.color(colorScheme),
            trailing: AppStatusPill(
              label: risks[index].severity.label,
              icon: risks[index].severity.icon,
              color: risks[index].severity.color(colorScheme),
            ),
          ),
          if (index != risks.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class ProjectTeamRoster extends StatelessWidget {
  const ProjectTeamRoster({required this.members, super.key});

  final List<ProjectTeamMember> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const AppEmptyState(
        icon: Icons.groups_outlined,
        title: 'No team assigned',
        message: 'Add owners and contributors to clarify accountability.',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (var index = 0; index < members.length; index++) ...[
          AppInfoRow(
            title: members[index].name,
            subtitle: members[index].role,
            icon: Icons.person_outline,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
            iconBackgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            iconForegroundColor: colorScheme.primary,
            trailing: AppStatusPill(
              label: '${(members[index].allocation * 100).round()}%',
              icon: Icons.pie_chart_outline,
              color: colorScheme.primary,
            ),
          ),
          if (index != members.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class ProjectLinkedTimelinePanel extends StatelessWidget {
  const ProjectLinkedTimelinePanel({
    required this.tasks,
    this.onTaskFocus,
    this.today,
    super.key,
  });

  final List<gantt.GanttTask> tasks;
  final ValueChanged<gantt.GanttTask>? onTaskFocus;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const AppEmptyState(
        icon: Icons.timeline_outlined,
        title: 'No linked timeline tasks',
        message: 'Link Gantt tasks to this project for schedule visibility.',
      );
    }

    final dateFormat = DateFormat('MMM d');
    final sortedTasks = [...tasks]..sort((first, second) {
      final startComparison = first.startDate.compareTo(second.startDate);
      if (startComparison != 0) return startComparison;

      return first.endDate.compareTo(second.endDate);
    });
    final milestoneCount = sortedTasks.where((task) => task.isMilestone).length;
    final completedCount =
        sortedTasks.where((task) => task.progress >= 1).length;
    final nextOpenTask =
        sortedTasks.where((task) => task.progress < 1).firstOrNull;
    final summaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        AppInfoRow(
          title:
              nextOpenTask == null
                  ? 'Linked timeline complete'
                  : 'Next timeline item: ${nextOpenTask.title}',
          subtitle:
              '${sortedTasks.length} linked - $milestoneCount milestones - $completedCount complete',
          icon: Icons.view_timeline_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: summaryColor.withValues(alpha: 0.12),
          iconForegroundColor: summaryColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < sortedTasks.length; index++) ...[
          Builder(
            builder: (context) {
              final task = sortedTasks[index];
              final health = ganttScheduleHealthFor(task, today: today);
              final healthColor = health.color(Theme.of(context).colorScheme);

              return AppInfoRow(
                title: task.title,
                subtitle: [
                  if (task.isMilestone)
                    'Milestone - ${dateFormat.format(task.startDate)}'
                  else
                    '${dateFormat.format(task.startDate)} - ${dateFormat.format(task.endDate)}',
                  ganttScheduleHealthDetail(task, today: today),
                ].join(' - '),
                icon:
                    task.isMilestone
                        ? Icons.flag_outlined
                        : Icons.timeline_outlined,
                iconStyle: AppInfoRowIconStyle.badge,
                contained: true,
                onTap: onTaskFocus == null ? null : () => onTaskFocus!(task),
                iconBackgroundColor: task.color.withValues(alpha: 0.12),
                iconForegroundColor: task.color,
                trailing: Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppStatusPill(
                      label: health.label,
                      icon: health.icon,
                      color: healthColor,
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              );
            },
          ),
          if (index != sortedTasks.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;

    return iterator.current;
  }
}
