import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_decision_impact_matrix_service.dart';
import '../services/project_decisions_workspace_service.dart';

/// Decision impact matrix for prioritizing operational consequences.
class ProjectDecisionImpactMatrixPanel extends StatefulWidget {
  const ProjectDecisionImpactMatrixPanel({
    required this.summary,
    this.maxItems = 6,
    super.key,
  });

  final ProjectDecisionImpactMatrixSummary summary;
  final int maxItems;

  @override
  State<ProjectDecisionImpactMatrixPanel> createState() =>
      _ProjectDecisionImpactMatrixPanelState();
}

/// Keeps impact brief copy state local to the impact presentation.
class _ProjectDecisionImpactMatrixPanelState
    extends State<ProjectDecisionImpactMatrixPanel> {
  var _impactCopied = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final primaryItem = summary.primaryItem;
    final visibleItems = summary.items.take(widget.maxItems).toList();
    final impactText = summary.impactText.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title:
              primaryItem == null
                  ? 'No decision impact yet'
                  : '${summary.impactIndex}/100 decision impact index',
          subtitle:
              primaryItem == null
                  ? 'Impact scoring will appear when decision records are available.'
                  : '${summary.elevatedCount} elevated impacts - ${summary.ownerCount} owners - priority: ${primaryItem.title}.',
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
              title: 'Impact Index',
              value: summary.impactIndex.toString(),
              icon: Icons.insights_outlined,
              accentColor: signalColor,
              helper: 'Average score',
            ),
            AppMetricGridItem(
              title: 'Severe',
              value: summary.severeCount.toString(),
              icon: ProjectDecisionImpactLevel.severe.icon,
              accentColor:
                  summary.severeCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Critical impact',
            ),
            AppMetricGridItem(
              title: 'High',
              value: summary.highCount.toString(),
              icon: ProjectDecisionImpactLevel.high.icon,
              accentColor:
                  summary.highCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Elevated impact',
            ),
            AppMetricGridItem(
              title: 'Owners',
              value: summary.ownerCount.toString(),
              icon: Icons.groups_outlined,
              accentColor: colorScheme.primary,
              helper: 'Accountable',
            ),
          ],
        ),
        if (visibleItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var index = 0; index < visibleItems.length; index++) ...[
            _DecisionImpactItemTile(item: visibleItems[index]),
            if (index != visibleItems.length - 1) const SizedBox(height: 10),
          ],
        ],
        if (summary.itemCount > widget.maxItems) ...[
          const SizedBox(height: 10),
          Text(
            'Showing ${widget.maxItems} of ${summary.itemCount} decision impacts',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (impactText.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCopyBriefCard(
            title: 'Decision impact brief',
            text: impactText,
            icon: Icons.insights_outlined,
            copied: _impactCopied,
            onCopy: () => _copyImpact(impactText),
          ),
        ],
      ],
    );
  }

  Future<void> _copyImpact(String impactText) async {
    setState(() => _impactCopied = true);
    await Clipboard.setData(ClipboardData(text: impactText));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Decision impact brief copied')),
    );
  }
}

/// Impact row with score, affected area, owner, and mitigation.
class _DecisionImpactItemTile extends StatelessWidget {
  const _DecisionImpactItemTile({required this.item});

  final ProjectDecisionImpactItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelColor = item.level.color(colorScheme);
    final dueDateLabel = item.dueDateLabel;

    return AppInfoRow(
      title: item.title,
      subtitle: [
        item.area.label,
        'Owner: ${item.owner}',
        if (dueDateLabel.isNotEmpty) dueDateLabel,
        item.mitigationLabel,
      ].join(' - '),
      icon: item.area.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: levelColor.withValues(alpha: 0.12),
      iconForegroundColor: levelColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: SizedBox(
        width: 124,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.score.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: AppStatusPill(
                label: item.level.label,
                icon: item.level.icon,
                color: levelColor,
                maxWidth: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Project decision impact matrix panel')
Widget projectDecisionImpactMatrixPanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionImpactMatrixPanel(
          summary: workspace.decisionImpactMatrixSummary,
        ),
      ),
    ),
  );
}
