import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_service.dart';
import '../services/project_domain_gap_repair_session_path_service.dart';
import 'project_domain_gap_repair_action_chip.dart';
import 'project_domain_gap_repair_priority_visuals.dart';

class ProjectDomainGapRepairSessionPathStrip extends StatelessWidget {
  const ProjectDomainGapRepairSessionPathStrip({
    required this.summary,
    required this.onRepair,
    super.key,
  });

  final ProjectDomainGapRepairSessionPathSummary summary;
  final ValueChanged<ProjectDomainGapRepairTarget> onRepair;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasPath) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final step in summary.visibleSteps)
          ProjectDomainGapRepairActionChip(
            chipKey: ValueKey(
              'project-domain-gap-repair-session-step-${step.stepNumber}',
            ),
            label: step.actionLabel,
            icon: projectDomainGapRepairPriorityIcon(step.target.priority),
            color: projectDomainGapRepairPriorityColor(
              step.target.priority,
              colorScheme,
            ),
            tooltip: step.tooltipLabel,
            maxWidth: 240,
            onPressed: () => onRepair(step.target),
          ),
        if (summary.hasHiddenSteps)
          AppStatusPill(
            label: '+${summary.hiddenStepCount} steps',
            icon: Icons.more_horiz_rounded,
            color: colorScheme.secondary,
            maxWidth: 120,
          ),
      ],
    );
  }
}
