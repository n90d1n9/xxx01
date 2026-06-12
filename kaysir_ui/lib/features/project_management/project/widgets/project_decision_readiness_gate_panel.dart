import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../models/project_decision_record.dart';
import '../services/project_decision_readiness_gate_service.dart';
import '../services/project_decisions_workspace_service.dart';

/// Readiness gate panel for checking if decision records can move cleanly.
class ProjectDecisionReadinessGatePanel extends StatefulWidget {
  const ProjectDecisionReadinessGatePanel({
    required this.summary,
    this.maxLanes = 4,
    super.key,
  });

  final ProjectDecisionReadinessGateSummary summary;
  final int maxLanes;

  @override
  State<ProjectDecisionReadinessGatePanel> createState() =>
      _ProjectDecisionReadinessGatePanelState();
}

/// Keeps readiness brief copy state local to the gate presentation.
class _ProjectDecisionReadinessGatePanelState
    extends State<ProjectDecisionReadinessGatePanel> {
  var _briefCopied = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final visibleLanes =
        summary.lanes
            .where((lane) => !lane.isEmpty)
            .take(widget.maxLanes)
            .toList();
    final briefText = summary.briefText.trim();

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
              title: 'Readiness Score',
              value: summary.averageScore.toString(),
              icon: Icons.speed_outlined,
              accentColor: signalColor,
              helper: '0-100',
            ),
            AppMetricGridItem(
              title: 'Blocked',
              value: summary.blockedCount.toString(),
              icon: ProjectDecisionReadinessGate.blocked.icon,
              accentColor:
                  summary.blockedCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Cannot move',
            ),
            AppMetricGridItem(
              title: 'Decision',
              value: summary.needsDecisionCount.toString(),
              icon: ProjectDecisionReadinessGate.needsDecision.icon,
              accentColor:
                  summary.needsDecisionCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Answer needed',
            ),
            AppMetricGridItem(
              title: 'Ready',
              value: summary.readyCount.toString(),
              icon: ProjectDecisionReadinessGate.ready.icon,
              accentColor: Colors.green.shade700,
              helper: 'Can progress',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleLanes.isEmpty)
          const AppInfoRow(
            title: 'No readiness lanes active',
            subtitle: 'No decision records are available for readiness review.',
            icon: Icons.verified_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
          )
        else
          for (var index = 0; index < visibleLanes.length; index++) ...[
            _DecisionReadinessLaneTile(lane: visibleLanes[index]),
            if (index != visibleLanes.length - 1) const SizedBox(height: 10),
          ],
        if (briefText.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCopyBriefCard(
            title: 'Readiness brief',
            text: briefText,
            icon: Icons.fact_check_outlined,
            copied: _briefCopied,
            onCopy: () => _copyBrief(briefText),
          ),
        ],
      ],
    );
  }

  Future<void> _copyBrief(String briefText) async {
    setState(() => _briefCopied = true);
    await Clipboard.setData(ClipboardData(text: briefText));
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Readiness brief copied')));
  }
}

/// Readiness lane row with primary record, owner, status, and score.
class _DecisionReadinessLaneTile extends StatelessWidget {
  const _DecisionReadinessLaneTile({required this.lane});

  final ProjectDecisionReadinessLane lane;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gateColor = lane.gate.color(colorScheme);
    final primary = lane.primaryRecord;

    return AppInfoRow(
      title: lane.gate.label,
      subtitle:
          primary == null
              ? lane.detail
              : '${lane.detail} ${primary.readinessLabel} - '
                  'Owner: ${primary.record.owner} - ${primary.record.status.label}.',
      icon: lane.gate.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: gateColor.withValues(alpha: 0.12),
      iconForegroundColor: gateColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: '${lane.averageScore}',
        icon: Icons.speed_outlined,
        color: gateColor,
        maxWidth: 96,
      ),
    );
  }
}

@Preview(name: 'Project decision readiness gate panel')
Widget projectDecisionReadinessGatePanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionReadinessGatePanel(
          summary: workspace.decisionReadinessGateSummary,
        ),
      ),
    ),
  );
}
