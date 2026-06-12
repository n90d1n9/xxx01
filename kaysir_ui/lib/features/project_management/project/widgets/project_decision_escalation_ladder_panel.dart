import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/widgets/ui/app_copy_brief_card.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../data/project_portfolio_repository.dart';
import '../services/project_decision_escalation_ladder_service.dart';
import '../services/project_decisions_workspace_service.dart';

/// Escalation ladder panel for routing decision actions to the right audience.
class ProjectDecisionEscalationLadderPanel extends StatefulWidget {
  const ProjectDecisionEscalationLadderPanel({
    required this.summary,
    this.maxSteps = 4,
    super.key,
  });

  final ProjectDecisionEscalationLadderSummary summary;
  final int maxSteps;

  @override
  State<ProjectDecisionEscalationLadderPanel> createState() =>
      _ProjectDecisionEscalationLadderPanelState();
}

/// Keeps escalation brief copy state local to the ladder presentation.
class _ProjectDecisionEscalationLadderPanelState
    extends State<ProjectDecisionEscalationLadderPanel> {
  var _briefCopied = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = summary.signal.color(colorScheme);
    final visibleSteps = summary.steps.take(widget.maxSteps).toList();
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
              title: 'Sponsor',
              value: summary.sponsorCount.toString(),
              icon: ProjectDecisionEscalationTier.sponsor.icon,
              accentColor:
                  summary.sponsorCount == 0
                      ? Colors.green.shade700
                      : colorScheme.error,
              helper: 'Escalate',
            ),
            AppMetricGridItem(
              title: 'Owner',
              value: summary.ownerCount.toString(),
              icon: ProjectDecisionEscalationTier.owner.icon,
              accentColor:
                  summary.ownerCount == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
              helper: 'Answer needed',
            ),
            AppMetricGridItem(
              title: 'Team',
              value: summary.deliveryTeamCount.toString(),
              icon: ProjectDecisionEscalationTier.deliveryTeam.icon,
              accentColor: colorScheme.primary,
              helper: 'Follow-through',
            ),
            AppMetricGridItem(
              title: 'Monitor',
              value: summary.monitorCount.toString(),
              icon: ProjectDecisionEscalationTier.monitor.icon,
              accentColor: Colors.green.shade700,
              helper: 'Low risk',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (visibleSteps.isEmpty)
          const AppInfoRow(
            title: 'No escalation lanes active',
            subtitle:
                'All open decision records are clear or already closed in the register.',
            icon: Icons.verified_outlined,
            iconStyle: AppInfoRowIconStyle.badge,
            contained: true,
          )
        else
          for (var index = 0; index < visibleSteps.length; index++) ...[
            _DecisionEscalationStepTile(step: visibleSteps[index]),
            if (index != visibleSteps.length - 1) const SizedBox(height: 10),
          ],
        if (briefText.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCopyBriefCard(
            title: 'Escalation brief',
            text: briefText,
            icon: Icons.notification_important_outlined,
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
    ).showSnackBar(const SnackBar(content: Text('Escalation brief copied')));
  }
}

/// Compact escalation row with audience, owner mix, and decision source mix.
class _DecisionEscalationStepTile extends StatelessWidget {
  const _DecisionEscalationStepTile({required this.step});

  final ProjectDecisionEscalationStep step;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tierColor = step.tier.color(colorScheme);
    final signalColor = step.signal.color(colorScheme);

    return AppInfoRow(
      title: step.title,
      subtitle:
          '${step.actionLabel} - Owners: ${step.ownerMixLabel} - '
          'Sources: ${step.sourceMixLabel} - ${step.detail}',
      icon: step.tier.icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: tierColor.withValues(alpha: 0.12),
      iconForegroundColor: tierColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppStatusPill(
        label: step.signal.label,
        icon: step.signal.icon,
        color: signalColor,
        maxWidth: 124,
      ),
    );
  }
}

@Preview(name: 'Project decision escalation ladder panel')
Widget projectDecisionEscalationLadderPanelPreview() {
  final workspace = buildProjectDecisionsWorkspaceSummary(
    project: demoProjectPortfolio.first,
    dependencyTasks: const [],
    today: DateTime(2026, 6, 11),
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ProjectDecisionEscalationLadderPanel(
          summary: workspace.decisionEscalationLadderSummary,
        ),
      ),
    ),
  );
}
