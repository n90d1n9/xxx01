import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/gantt_dependency_chain_service.dart';
import '../services/gantt_dependency_service.dart';
import '../services/gantt_task_relationship_overview_service.dart';

class GanttTaskRelationshipOverviewStrip extends StatelessWidget {
  const GanttTaskRelationshipOverviewStrip({required this.overview, super.key});

  final GanttTaskRelationshipOverview overview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor =
        overview.attentionCount > 0 ? colorScheme.error : Colors.green.shade700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppInfoRow(
          title: 'Relationship Overview',
          subtitle: overview.headline,
          icon: Icons.hub_outlined,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 1,
          subtitleMaxLines: 2,
          trailing: AppStatusPill(
            label: overview.attentionLabel,
            icon:
                overview.attentionCount > 0
                    ? Icons.warning_amber_rounded
                    : Icons.verified_outlined,
            color: signalColor,
            maxWidth: 132,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusPill(
              label: overview.upstreamLabel,
              icon: overview.chain.state.icon,
              color: overview.chain.state.color(colorScheme),
              tooltip: overview.chain.summary,
              maxWidth: 150,
            ),
            AppStatusPill(
              label: overview.downstreamLabel,
              icon: Icons.call_split_outlined,
              color: overview.successorImpact.signal.color(colorScheme),
              tooltip: overview.successorImpact.summaryText,
              maxWidth: 160,
            ),
            AppStatusPill(
              label: overview.branchLabel,
              icon: Icons.account_tree_outlined,
              color: _branchColor(colorScheme),
              tooltip: overview.branchDetail,
              maxWidth: 132,
            ),
          ],
        ),
      ],
    );
  }

  Color _branchColor(ColorScheme colorScheme) {
    final branchSummary = overview.branchSummary;
    if (branchSummary == null) return colorScheme.onSurfaceVariant;
    if (branchSummary.riskTaskCount > 0) return colorScheme.error;
    if (branchSummary.completedTaskCount >= branchSummary.taskCount) {
      return Colors.green.shade700;
    }
    return colorScheme.tertiary;
  }
}
