import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_project_cluster_service.dart';
import '../services/project_domain_gap_repair_service.dart';
import 'project_domain_gap_repair_action_chip.dart';

class ProjectDomainGapRepairProjectClusterStrip extends StatelessWidget {
  const ProjectDomainGapRepairProjectClusterStrip({
    required this.summary,
    required this.onRepair,
    super.key,
  });

  final ProjectDomainGapRepairProjectClusterSummary summary;
  final ValueChanged<ProjectDomainGapRepairTarget> onRepair;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasClusters) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final cluster in summary.visibleClusters)
          _ProjectClusterActionChip(
            cluster: cluster,
            onRepair: () => onRepair(cluster.primaryTarget),
          ),
        if (summary.hasHiddenClusters)
          AppStatusPill(
            label: '+${summary.hiddenClusterCount} project batches',
            icon: Icons.more_horiz_rounded,
            color: colorScheme.secondary,
            maxWidth: 190,
          ),
      ],
    );
  }
}

class _ProjectClusterActionChip extends StatelessWidget {
  const _ProjectClusterActionChip({
    required this.cluster,
    required this.onRepair,
  });

  final ProjectDomainGapRepairProjectCluster cluster;
  final VoidCallback onRepair;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color =
        cluster.hasBlockedContext
            ? colorScheme.error
            : cluster.hasAtRiskContext
            ? Colors.orange.shade700
            : colorScheme.secondary;

    return ProjectDomainGapRepairActionChip(
      chipKey: ValueKey(
        'project-domain-gap-repair-cluster-${cluster.project.id}',
      ),
      label: cluster.actionLabel,
      icon: Icons.account_tree_outlined,
      color: color,
      tooltip: '${cluster.tooltipLabel}\n${cluster.prioritySummaryLabel}',
      maxWidth: 220,
      onPressed: onRepair,
    );
  }
}
