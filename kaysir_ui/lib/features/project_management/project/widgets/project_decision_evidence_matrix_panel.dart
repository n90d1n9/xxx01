import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_decision_evidence_matrix_service.dart';
import '../services/project_decisions_workspace_service.dart';

/// Decision evidence matrix for proof readiness, review, and sign-off tracking.
class ProjectDecisionEvidenceMatrixPanel extends StatefulWidget {
  const ProjectDecisionEvidenceMatrixPanel({
    required this.summary,
    this.maxItems = 6,
    super.key,
  });

  final ProjectDecisionEvidenceMatrixSummary summary;
  final int maxItems;

  @override
  State<ProjectDecisionEvidenceMatrixPanel> createState() =>
      _ProjectDecisionEvidenceMatrixPanelState();
}

/// Keeps proof checklist copy state separate from evidence summary construction.
class _ProjectDecisionEvidenceMatrixPanelState
    extends State<ProjectDecisionEvidenceMatrixPanel> {
  var _packCopied = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final primaryItem = summary.primaryItem;
    final visibleItems = summary.items.take(widget.maxItems).toList();
    final packText = summary.packText.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title:
              primaryItem == null
                  ? 'Decision evidence ready'
                  : '${summary.itemCount} decision proof items tracked',
          subtitle:
              primaryItem == null
                  ? 'No decision proof items need review.'
                  : '${summary.readinessPercent}% ready - ${summary.missingCount} missing - ${summary.reviewCount} review - priority: ${primaryItem.title}.',
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
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: (summary.readinessPercent / 100).clamp(0, 1),
            color: signalColor,
            backgroundColor: signalColor.withValues(alpha: 0.14),
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 128,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Missing',
              value: summary.missingCount.toString(),
              icon: ProjectDecisionEvidenceState.missing.icon,
              accentColor:
                  summary.missingCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Blocked proof',
            ),
            AppMetricGridItem(
              title: 'Review',
              value: summary.reviewCount.toString(),
              icon: ProjectDecisionEvidenceState.review.icon,
              accentColor:
                  summary.reviewCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Needs sign-off',
            ),
            AppMetricGridItem(
              title: 'Ready',
              value: summary.readyCount.toString(),
              icon: ProjectDecisionEvidenceState.ready.icon,
              accentColor: colorScheme.primary,
              helper: 'Review-ready',
            ),
            AppMetricGridItem(
              title: 'Signed Off',
              value: summary.signedOffCount.toString(),
              icon: ProjectDecisionEvidenceState.signedOff.icon,
              accentColor: Colors.green.shade700,
              helper: 'Closed proof',
            ),
          ],
        ),
        if (visibleItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var index = 0; index < visibleItems.length; index++) ...[
            _DecisionEvidenceItemTile(item: visibleItems[index]),
            if (index != visibleItems.length - 1) const SizedBox(height: 10),
          ],
        ],
        if (summary.itemCount > widget.maxItems) ...[
          const SizedBox(height: 10),
          Text(
            'Showing ${widget.maxItems} of ${summary.itemCount} decision proof items',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        if (packText.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCopyBriefCard(
            title: 'Decision evidence checklist',
            text: packText,
            icon: Icons.fact_check_outlined,
            copied: _packCopied,
            onCopy: () => _copyPack(packText),
          ),
        ],
      ],
    );
  }

  Future<void> _copyPack(String packText) async {
    setState(() => _packCopied = true);
    await Clipboard.setData(ClipboardData(text: packText));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Decision evidence checklist copied')),
    );
  }
}

/// Decision proof row with source, owner, due date, and readiness state.
class _DecisionEvidenceItemTile extends StatelessWidget {
  const _DecisionEvidenceItemTile({required this.item});

  final ProjectDecisionEvidenceItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stateColor = item.state.color(colorScheme);
    final dueDateLabel = item.dueDateLabel;

    return AppInfoRow(
      title: item.title,
      subtitle: [
        item.kind.label,
        'Owner: ${item.owner}',
        if (dueDateLabel.isNotEmpty) dueDateLabel,
        item.evidenceLabel,
        item.detail,
      ].join(' - '),
      icon: item.kind.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: stateColor.withValues(alpha: 0.12),
      iconForegroundColor: stateColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: item.state.label,
        icon: item.state.icon,
        color: stateColor,
        maxWidth: 124,
      ),
    );
  }
}

@Preview(name: 'Project decision evidence matrix panel')
Widget projectDecisionEvidenceMatrixPanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionEvidenceMatrixPanel(
          summary: workspace.decisionEvidenceMatrixSummary,
        ),
      ),
    ),
  );
}
