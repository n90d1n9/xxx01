import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_field_type_mix_service.dart';
import '../services/project_domain_gap_repair_service.dart';
import 'project_custom_attribute_type_ui.dart';
import 'project_domain_gap_repair_action_chip.dart';

class ProjectDomainGapRepairFieldTypeMixStrip extends StatelessWidget {
  const ProjectDomainGapRepairFieldTypeMixStrip({
    required this.summary,
    required this.onRepair,
    super.key,
  });

  final ProjectDomainGapRepairFieldTypeMixSummary summary;
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
          _FieldTypeActionChip(
            group: group,
            onRepair: () => onRepair(group.primaryTarget),
          ),
        if (summary.hasHiddenGroups)
          AppStatusPill(
            label: '+${summary.hiddenGroupCount} value types',
            icon: Icons.more_horiz_rounded,
            color: colorScheme.secondary,
            maxWidth: 170,
          ),
      ],
    );
  }
}

class _FieldTypeActionChip extends StatelessWidget {
  const _FieldTypeActionChip({required this.group, required this.onRepair});

  final ProjectDomainGapRepairFieldTypeGroup group;
  final VoidCallback onRepair;

  @override
  Widget build(BuildContext context) {
    final color = group.type.accentColor(Theme.of(context).colorScheme);

    return ProjectDomainGapRepairActionChip(
      chipKey: ValueKey(
        'project-domain-gap-repair-field-type-${group.type.name}',
      ),
      label: group.actionLabel,
      icon: group.type.icon,
      color: color,
      tooltip: '${group.tooltipLabel}\n${group.prioritySummaryLabel}',
      maxWidth: 180,
      onPressed: onRepair,
    );
  }
}
