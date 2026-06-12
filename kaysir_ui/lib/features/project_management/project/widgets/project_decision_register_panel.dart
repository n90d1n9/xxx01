import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_decision_record.dart';
import '../services/project_decision_register_service.dart';
import '../services/project_decisions_workspace_service.dart';

/// Filterable decision register for project governance and action tracking.
class ProjectDecisionRegisterPanel extends StatefulWidget {
  const ProjectDecisionRegisterPanel({
    required this.summary,
    this.maxRows = 8,
    super.key,
  });

  final ProjectDecisionRegisterSummary summary;
  final int maxRows;

  @override
  State<ProjectDecisionRegisterPanel> createState() =>
      _ProjectDecisionRegisterPanelState();
}

/// Stores the active register lens separately from register summary building.
class _ProjectDecisionRegisterPanelState
    extends State<ProjectDecisionRegisterPanel> {
  var _lens = ProjectDecisionRegisterLens.all;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final visibleRows = summary.recordsFor(_lens).take(widget.maxRows).toList();
    final colorScheme = Theme.of(context).colorScheme;
    final priorityRecord = summary.priorityRecord;
    final headerColor = _headerColor(summary, colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title:
              priorityRecord == null
                  ? 'No decision records yet'
                  : '${summary.recordCount} decision records tracked',
          subtitle:
              priorityRecord == null
                  ? 'Next decisions, governance routes, risks, milestones, and domain fields will appear here.'
                  : '${summary.openCount} open items - ${summary.awaitingDecisionCount} awaiting - ${summary.overdueCount} overdue - priority: ${priorityRecord.title}.',
          icon: priorityRecord?.source.icon ?? Icons.rule_folder_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: headerColor.withValues(alpha: 0.12),
          iconForegroundColor: headerColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: _headerStatusLabel(summary),
            icon: _headerStatusIcon(summary),
            color: headerColor,
            maxWidth: 128,
          ),
        ),
        const SizedBox(height: 12),
        AppFilterChipGroup<ProjectDecisionRegisterLens>(
          value: _lens,
          options: [
            for (final lens in ProjectDecisionRegisterLens.values)
              AppFilterChipOption(
                value: lens,
                label: lens.label,
                icon: lens.icon,
                count: summary.countFor(lens),
              ),
          ],
          onChanged: (value) => setState(() => _lens = value),
        ),
        const SizedBox(height: 12),
        if (visibleRows.isEmpty)
          AppInfoRow(
            title: 'No ${_lens.label.toLowerCase()} records',
            subtitle: 'Choose another decision lens to inspect this project.',
            icon: _lens.icon,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
          )
        else
          for (var index = 0; index < visibleRows.length; index++) ...[
            _DecisionRecordTile(
              record: visibleRows[index],
              today: summary.today,
            ),
            if (index != visibleRows.length - 1) const SizedBox(height: 10),
          ],
        if (summary.countFor(_lens) > widget.maxRows) ...[
          const SizedBox(height: 10),
          Text(
            'Showing ${widget.maxRows} of ${summary.countFor(_lens)} ${_lens.label.toLowerCase()} records',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Color _headerColor(
    ProjectDecisionRegisterSummary summary,
    ColorScheme colorScheme,
  ) {
    if (summary.overdueCount > 0 || summary.blockedCount > 0) {
      return colorScheme.error;
    }
    if (summary.awaitingDecisionCount > 0) return Colors.orange.shade700;

    return Colors.green.shade700;
  }

  String _headerStatusLabel(ProjectDecisionRegisterSummary summary) {
    if (summary.overdueCount > 0) return 'Overdue';
    if (summary.blockedCount > 0) return 'Blocked';
    if (summary.awaitingDecisionCount > 0) return 'Awaiting';

    return 'Governed';
  }

  IconData _headerStatusIcon(ProjectDecisionRegisterSummary summary) {
    if (summary.overdueCount > 0 || summary.blockedCount > 0) {
      return Icons.block_outlined;
    }
    if (summary.awaitingDecisionCount > 0) {
      return Icons.pending_actions_outlined;
    }

    return Icons.verified_outlined;
  }
}

/// Decision register row with normalized owner, due date, evidence, and status.
class _DecisionRecordTile extends StatelessWidget {
  const _DecisionRecordTile({required this.record, required this.today});

  final ProjectDecisionRecord record;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = record.priority.color(colorScheme);
    final overdue = record.isOverdue(today);
    final subtitleParts = [
      record.source.label,
      record.ownerText,
      if (record.dueDateLabel.isNotEmpty) record.dueDateLabel,
      if (record.evidenceLabel.isNotEmpty) record.evidenceLabel,
      if (record.metadataLabel.isNotEmpty) record.metadataLabel,
      record.detail,
    ];

    return AppInfoRow(
      title: record.title,
      subtitle: subtitleParts.join(' - '),
      icon: record.source.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: priorityColor.withValues(alpha: 0.1),
      iconForegroundColor: priorityColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: _DecisionRecordTrailing(
        record: record,
        statusColor:
            overdue ? colorScheme.error : record.status.color(colorScheme),
      ),
    );
  }
}

/// Fixed-width trailing block that keeps decision register rows visually steady.
class _DecisionRecordTrailing extends StatelessWidget {
  const _DecisionRecordTrailing({
    required this.record,
    required this.statusColor,
  });

  final ProjectDecisionRecord record;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                record.priority.icon,
                size: 16,
                color: record.priority.color(Theme.of(context).colorScheme),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  record.priority.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: AppStatusPill(
              label: record.status.label,
              icon: record.status.icon,
              color: statusColor,
              maxWidth: 124,
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Project decision register panel')
Widget projectDecisionRegisterPanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionRegisterPanel(
          summary: workspace.decisionRegisterSummary,
        ),
      ),
    ),
  );
}
