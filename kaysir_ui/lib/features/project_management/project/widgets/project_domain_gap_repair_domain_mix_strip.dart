import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_domain_mix_service.dart';
import '../services/project_domain_gap_repair_service.dart';
import 'project_domain_gap_repair_action_chip.dart';

class ProjectDomainGapRepairDomainMixStrip extends StatelessWidget {
  const ProjectDomainGapRepairDomainMixStrip({
    required this.summary,
    required this.onRepair,
    super.key,
  });

  final ProjectDomainGapRepairDomainMixSummary summary;
  final ValueChanged<ProjectDomainGapRepairTarget> onRepair;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasMix) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final group in summary.visibleGroups)
          _DomainActionChip(
            group: group,
            onRepair: () => onRepair(group.primaryTarget),
          ),
        if (summary.hasHiddenGroups)
          AppStatusPill(
            label: '+${summary.hiddenGroupCount} domains',
            icon: Icons.more_horiz_rounded,
            color: colorScheme.secondary,
            maxWidth: 140,
          ),
      ],
    );
  }
}

class _DomainActionChip extends StatelessWidget {
  const _DomainActionChip({required this.group, required this.onRepair});

  final ProjectDomainGapRepairDomainGroup group;
  final VoidCallback onRepair;

  @override
  Widget build(BuildContext context) {
    final color = _domainColor(group.domainKey, Theme.of(context).colorScheme);

    return ProjectDomainGapRepairActionChip(
      chipKey: ValueKey('project-domain-gap-repair-domain-${group.domainKey}'),
      label: group.actionLabel,
      icon: Icons.business_center_outlined,
      color: color,
      tooltip: '${group.tooltipLabel}\n${group.prioritySummaryLabel}',
      maxWidth: 230,
      onPressed: onRepair,
    );
  }
}

Color _domainColor(String key, ColorScheme colorScheme) {
  final palette = <Color>[
    colorScheme.primary,
    colorScheme.tertiary,
    colorScheme.secondary,
    Colors.indigo.shade600,
    Colors.teal.shade700,
    Colors.blue.shade700,
  ];
  final colorIndex = key.codeUnits.fold<int>(0, (total, unit) => total + unit);
  return palette[colorIndex % palette.length];
}
