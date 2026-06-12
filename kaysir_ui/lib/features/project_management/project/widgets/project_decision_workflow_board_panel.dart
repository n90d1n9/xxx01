import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_decision_record.dart';
import '../services/project_decision_workflow_board_service.dart';
import '../services/project_decisions_workspace_service.dart';

/// Workflow board for decision status lanes and stage-level prioritization.
class ProjectDecisionWorkflowBoardPanel extends StatefulWidget {
  const ProjectDecisionWorkflowBoardPanel({
    required this.summary,
    this.maxStages = 6,
    super.key,
  });

  final ProjectDecisionWorkflowBoardSummary summary;
  final int maxStages;

  @override
  State<ProjectDecisionWorkflowBoardPanel> createState() =>
      _ProjectDecisionWorkflowBoardPanelState();
}

/// Keeps workflow snapshot copy state local to board presentation.
class _ProjectDecisionWorkflowBoardPanelState
    extends State<ProjectDecisionWorkflowBoardPanel> {
  var _snapshotCopied = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final primaryStage = summary.primaryStage;
    final visibleStages = summary.stages.take(widget.maxStages).toList();
    final snapshotText = summary.snapshotText.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title:
              summary.activeCount == 0
                  ? 'Decision workflow clear'
                  : '${summary.activeCount} active decisions in workflow',
          subtitle:
              '${summary.blockedCount} blocked - ${summary.awaitingCount} awaiting - ${summary.reviewCount} review - priority stage: ${primaryStage.status.label}.',
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
              title: 'Blocked',
              value: summary.blockedCount.toString(),
              icon: ProjectDecisionStatus.blocked.icon,
              accentColor:
                  summary.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Recovery',
            ),
            AppMetricGridItem(
              title: 'Awaiting',
              value: summary.awaitingCount.toString(),
              icon: ProjectDecisionStatus.awaitingDecision.icon,
              accentColor:
                  summary.awaitingCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Decision needed',
            ),
            AppMetricGridItem(
              title: 'Review',
              value: summary.reviewCount.toString(),
              icon: ProjectDecisionStatus.inReview.icon,
              accentColor:
                  summary.reviewCount == 0
                      ? Colors.green.shade700
                      : colorScheme.primary,
              helper: 'Under review',
            ),
            AppMetricGridItem(
              title: 'Closed',
              value: summary.closedCount.toString(),
              icon: ProjectDecisionStatus.completed.icon,
              accentColor: Colors.green.shade700,
              helper: 'Approved or done',
            ),
          ],
        ),
        if (visibleStages.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (var index = 0; index < visibleStages.length; index++) ...[
            _DecisionWorkflowStageTile(stage: visibleStages[index]),
            if (index != visibleStages.length - 1) const SizedBox(height: 10),
          ],
        ],
        if (snapshotText.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCopyBriefCard(
            title: 'Workflow snapshot',
            text: snapshotText,
            icon: Icons.view_kanban_outlined,
            copied: _snapshotCopied,
            onCopy: () => _copySnapshot(snapshotText),
          ),
        ],
      ],
    );
  }

  Future<void> _copySnapshot(String snapshotText) async {
    setState(() => _snapshotCopied = true);
    await Clipboard.setData(ClipboardData(text: snapshotText));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workflow snapshot copied')));
  }
}

/// Decision workflow stage row with count, primary record, and overdue signal.
class _DecisionWorkflowStageTile extends StatelessWidget {
  const _DecisionWorkflowStageTile({required this.stage});

  final ProjectDecisionWorkflowStage stage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = stage.status.color(colorScheme);
    final primaryRecord = stage.primaryRecord;

    return AppInfoRow(
      title: stage.status.label,
      subtitle:
          primaryRecord == null
              ? stage.detail
              : '${stage.detail} ${_recordDetail(primaryRecord)}',
      icon: stage.status.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: statusColor.withValues(alpha: 0.12),
      iconForegroundColor: statusColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: '${stage.count}',
        icon: stage.status.icon,
        color: statusColor,
        maxWidth: 88,
      ),
    );
  }

  String _recordDetail(ProjectDecisionRecord record) {
    final dueDateLabel = record.dueDateLabel;
    final ownerLabel = 'Owner: ${record.owner}';
    if (dueDateLabel.isEmpty) return ownerLabel;

    return '$ownerLabel - $dueDateLabel';
  }
}

@Preview(name: 'Project decision workflow board panel')
Widget projectDecisionWorkflowBoardPanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionWorkflowBoardPanel(
          summary: workspace.decisionWorkflowBoardSummary,
        ),
      ),
    ),
  );
}
