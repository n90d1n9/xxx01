import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_decision_cadence_service.dart';
import '../services/project_decisions_workspace_service.dart';

/// Decision cadence panel for review rhythm, escalation window, and agenda.
class ProjectDecisionCadencePanel extends StatefulWidget {
  const ProjectDecisionCadencePanel({
    required this.summary,
    this.maxItems = 5,
    super.key,
  });

  final ProjectDecisionCadenceSummary summary;
  final int maxItems;

  @override
  State<ProjectDecisionCadencePanel> createState() =>
      _ProjectDecisionCadencePanelState();
}

/// Keeps cadence agenda copy state local to the cadence presentation.
class _ProjectDecisionCadencePanelState
    extends State<ProjectDecisionCadencePanel> {
  var _agendaCopied = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final visibleItems = summary.items.take(widget.maxItems).toList();
    final agendaText = summary.agendaText.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: summary.title,
          subtitle: summary.subtitle,
          icon: summary.signal.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 2,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: summary.signal.label,
            icon: summary.signal.icon,
            color: signalColor,
            maxWidth: 124,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Cadence',
              value: summary.cadenceMetricLabel,
              icon: Icons.event_repeat_outlined,
              accentColor: signalColor,
              helper: 'Review rhythm',
            ),
            AppMetricGridItem(
              title: 'Owners',
              value: summary.ownerCount.toString(),
              icon: Icons.groups_outlined,
              accentColor: colorScheme.primary,
              helper: 'Accountable',
            ),
            AppMetricGridItem(
              title: 'Open',
              value: summary.register.openCount.toString(),
              icon: Icons.rule_folder_outlined,
              accentColor:
                  summary.register.openCount == 0
                      ? Colors.green.shade700
                      : colorScheme.primary,
              helper: 'Decisions',
            ),
            AppMetricGridItem(
              title: 'Escalation',
              value: summary.immediateCount.toString(),
              icon: Icons.priority_high_rounded,
              accentColor:
                  summary.immediateCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Same-day items',
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppInfoRow(
          title: 'Review cadence',
          subtitle: summary.reviewCadenceLabel,
          icon: Icons.event_available_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: colorScheme.primary.withValues(alpha: 0.1),
          iconForegroundColor: colorScheme.primary,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
        ),
        const SizedBox(height: 10),
        AppInfoRow(
          title: 'Escalation window',
          subtitle: summary.escalationWindowLabel,
          icon: Icons.notification_important_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.1),
          iconForegroundColor: signalColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
        ),
        if (visibleItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var index = 0; index < visibleItems.length; index++) ...[
            _DecisionCadenceItemTile(item: visibleItems[index]),
            if (index != visibleItems.length - 1) const SizedBox(height: 10),
          ],
        ],
        if (agendaText.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCopyBriefCard(
            title: 'Cadence agenda',
            text: agendaText,
            icon: Icons.event_note_outlined,
            copied: _agendaCopied,
            onCopy: () => _copyAgenda(agendaText),
          ),
        ],
      ],
    );
  }

  Future<void> _copyAgenda(String agendaText) async {
    setState(() => _agendaCopied = true);
    await Clipboard.setData(ClipboardData(text: agendaText));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cadence agenda copied')));
  }
}

/// Cadence agenda row with owner, due date, and rhythm label.
class _DecisionCadenceItemTile extends StatelessWidget {
  const _DecisionCadenceItemTile({required this.item});

  final ProjectDecisionCadenceItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = item.signal.color(colorScheme);
    final dueDateLabel = item.dueDateLabel;

    return AppInfoRow(
      title: item.title,
      subtitle: [
        item.kind.label,
        'Owner: ${item.owner}',
        if (dueDateLabel.isNotEmpty) dueDateLabel,
        item.detail,
      ].join(' - '),
      icon: item.kind.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: signalColor.withValues(alpha: 0.12),
      iconForegroundColor: signalColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: item.signal.label,
        icon: item.signal.icon,
        color: signalColor,
        maxWidth: 124,
      ),
    );
  }
}

@Preview(name: 'Project decision cadence panel')
Widget projectDecisionCadencePanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionCadencePanel(
          summary: workspace.decisionCadenceSummary,
        ),
      ),
    ),
  );
}
