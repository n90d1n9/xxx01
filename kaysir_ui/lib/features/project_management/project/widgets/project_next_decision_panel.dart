import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../services/project_next_decision_service.dart';
import 'project_next_decision_brief_card.dart';

enum ProjectNextDecisionFilter { all, critical, warning, action, healthy }

class ProjectNextDecisionPanel extends StatefulWidget {
  const ProjectNextDecisionPanel({
    required this.summary,
    this.maxDecisions = 5,
    this.onOpenTask,
    super.key,
  });

  final ProjectNextDecisionSummary summary;
  final int maxDecisions;
  final ValueChanged<gantt.GanttTask>? onOpenTask;

  @override
  State<ProjectNextDecisionPanel> createState() =>
      _ProjectNextDecisionPanelState();
}

class _ProjectNextDecisionPanelState extends State<ProjectNextDecisionPanel> {
  var _filter = ProjectNextDecisionFilter.all;
  var _briefCopied = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summary = widget.summary;
    final summaryColor = summary.level.color(colorScheme);
    final visibleDecisions =
        summary.decisions
            .where(_filter.matches)
            .take(widget.maxDecisions)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.primaryDecision.title,
          subtitle:
              '${summary.decisions.length} decision signal${summary.decisions.length == 1 ? '' : 's'} - ${summary.readinessScore}/100 readiness - ${summary.timelineIssueCount} timeline signal${summary.timelineIssueCount == 1 ? '' : 's'}',
          icon: summary.primaryDecision.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: summaryColor.withValues(alpha: 0.12),
          iconForegroundColor: summaryColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.level.summaryLabel,
            icon: summary.primaryDecision.icon,
            color: summaryColor,
            maxWidth: 150,
          ),
        ),
        const SizedBox(height: 12),
        AppFilterChipGroup<ProjectNextDecisionFilter>(
          value: _filter,
          options: [
            AppFilterChipOption(
              value: ProjectNextDecisionFilter.all,
              label: ProjectNextDecisionFilter.all.label,
              icon: ProjectNextDecisionFilter.all.icon,
              count: summary.decisions.length,
            ),
            AppFilterChipOption(
              value: ProjectNextDecisionFilter.critical,
              label: ProjectNextDecisionFilter.critical.label,
              icon: ProjectNextDecisionFilter.critical.icon,
              count: summary.criticalCount,
            ),
            AppFilterChipOption(
              value: ProjectNextDecisionFilter.warning,
              label: ProjectNextDecisionFilter.warning.label,
              icon: ProjectNextDecisionFilter.warning.icon,
              count: summary.warningCount,
            ),
            AppFilterChipOption(
              value: ProjectNextDecisionFilter.action,
              label: ProjectNextDecisionFilter.action.label,
              icon: ProjectNextDecisionFilter.action.icon,
              count: summary.actionCount,
            ),
            AppFilterChipOption(
              value: ProjectNextDecisionFilter.healthy,
              label: ProjectNextDecisionFilter.healthy.label,
              icon: ProjectNextDecisionFilter.healthy.icon,
              count: summary.healthyCount,
            ),
          ],
          onChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 12),
        if (visibleDecisions.isEmpty)
          AppInfoRow(
            title: 'No ${_filter.label.toLowerCase()} decisions',
            subtitle:
                'Choose another decision lens to inspect this project signal.',
            icon: _filter.icon,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
          )
        else
          for (var index = 0; index < visibleDecisions.length; index++) ...[
            _ProjectNextDecisionTile(
              decision: visibleDecisions[index],
              onOpenTask:
                  visibleDecisions[index].task == null ||
                          widget.onOpenTask == null
                      ? null
                      : () => widget.onOpenTask!(visibleDecisions[index].task!),
            ),
            if (index != visibleDecisions.length - 1)
              const SizedBox(height: 10),
          ],
        if (_filter == ProjectNextDecisionFilter.all &&
            summary.decisions.length > widget.maxDecisions) ...[
          const SizedBox(height: 10),
          Text(
            'Showing ${widget.maxDecisions} of ${summary.decisions.length} decisions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 12),
        ProjectNextDecisionBriefCard(
          briefText: summary.briefText,
          copied: _briefCopied,
          onCopy: () => _copyBrief(summary.briefText),
        ),
      ],
    );
  }

  Future<void> _copyBrief(String briefText) async {
    await Clipboard.setData(ClipboardData(text: briefText));
    if (!mounted) return;

    setState(() => _briefCopied = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Decision brief copied')));
  }
}

class _ProjectNextDecisionTile extends StatelessWidget {
  const _ProjectNextDecisionTile({
    required this.decision,
    required this.onOpenTask,
  });

  final ProjectNextDecision decision;
  final VoidCallback? onOpenTask;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final decisionColor = decision.level.color(colorScheme);

    return AppInfoRow(
      title: decision.title,
      subtitle: decision.detail,
      icon: decision.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: decisionColor.withValues(alpha: 0.12),
      iconForegroundColor: decisionColor,
      titleMaxLines: 1,
      subtitleMaxLines: 3,
      trailing: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppStatusPill(
            label: decision.kind.label,
            icon: decision.icon,
            color: decisionColor,
            maxWidth: 118,
          ),
          AppStatusPill(
            label: decision.level.label,
            color: decisionColor,
            maxWidth: 102,
          ),
          if (onOpenTask != null)
            AppActionButton(
              label: 'Gantt',
              icon: Icons.open_in_new_rounded,
              compact: true,
              variant: AppActionButtonVariant.secondary,
              onPressed: onOpenTask,
            ),
        ],
      ),
    );
  }
}

extension ProjectNextDecisionFilterPresentation on ProjectNextDecisionFilter {
  String get label {
    switch (this) {
      case ProjectNextDecisionFilter.all:
        return 'All';
      case ProjectNextDecisionFilter.critical:
        return ProjectNextDecisionLevel.critical.label;
      case ProjectNextDecisionFilter.warning:
        return ProjectNextDecisionLevel.warning.label;
      case ProjectNextDecisionFilter.action:
        return ProjectNextDecisionLevel.action.label;
      case ProjectNextDecisionFilter.healthy:
        return ProjectNextDecisionLevel.healthy.label;
    }
  }

  IconData get icon {
    switch (this) {
      case ProjectNextDecisionFilter.all:
        return Icons.rule_folder_outlined;
      case ProjectNextDecisionFilter.critical:
        return ProjectNextDecisionLevel.critical.icon;
      case ProjectNextDecisionFilter.warning:
        return ProjectNextDecisionLevel.warning.icon;
      case ProjectNextDecisionFilter.action:
        return ProjectNextDecisionLevel.action.icon;
      case ProjectNextDecisionFilter.healthy:
        return ProjectNextDecisionLevel.healthy.icon;
    }
  }

  bool matches(ProjectNextDecision decision) {
    switch (this) {
      case ProjectNextDecisionFilter.all:
        return true;
      case ProjectNextDecisionFilter.critical:
        return decision.level == ProjectNextDecisionLevel.critical;
      case ProjectNextDecisionFilter.warning:
        return decision.level == ProjectNextDecisionLevel.warning;
      case ProjectNextDecisionFilter.action:
        return decision.level == ProjectNextDecisionLevel.action;
      case ProjectNextDecisionFilter.healthy:
        return decision.level == ProjectNextDecisionLevel.healthy;
    }
  }
}
