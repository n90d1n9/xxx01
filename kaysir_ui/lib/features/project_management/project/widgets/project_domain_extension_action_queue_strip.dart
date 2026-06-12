import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_extension_action_queue_service.dart';
import '../services/project_domain_extension_next_action_service.dart';
import 'project_domain_gap_repair_action_chip.dart';

class ProjectDomainExtensionActionQueueStrip extends StatelessWidget {
  const ProjectDomainExtensionActionQueueStrip({
    required this.queue,
    required this.onFocusField,
    super.key,
  });

  final ProjectDomainExtensionActionQueue queue;
  final ValueChanged<String> onFocusField;

  @override
  Widget build(BuildContext context) {
    if (!queue.hasActions) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final item in queue.visibleItems)
          ProjectDomainGapRepairActionChip(
            chipKey: ValueKey(
              'project-domain-extension-queue-${item.fieldKey}',
            ),
            label: item.actionLabel,
            icon: _icon(item.kind),
            color: _color(item.kind, colorScheme),
            tooltip: item.tooltip,
            maxWidth: 230,
            onPressed: () => onFocusField(item.fieldKey),
          ),
        if (queue.hasHiddenItems)
          AppStatusPill(
            label: '+${queue.hiddenItemCount} more',
            icon: Icons.more_horiz_rounded,
            color: colorScheme.secondary,
            maxWidth: 120,
          ),
      ],
    );
  }

  IconData _icon(ProjectDomainExtensionNextActionKind kind) {
    switch (kind) {
      case ProjectDomainExtensionNextActionKind.requiredField:
        return Icons.priority_high_rounded;
      case ProjectDomainExtensionNextActionKind.watchedField:
        return Icons.sensors_outlined;
      case ProjectDomainExtensionNextActionKind.recommendedField:
        return Icons.fact_check_outlined;
      case ProjectDomainExtensionNextActionKind.complete:
        return Icons.verified_outlined;
    }
  }

  Color _color(
    ProjectDomainExtensionNextActionKind kind,
    ColorScheme colorScheme,
  ) {
    switch (kind) {
      case ProjectDomainExtensionNextActionKind.requiredField:
        return colorScheme.error;
      case ProjectDomainExtensionNextActionKind.watchedField:
        return colorScheme.tertiary;
      case ProjectDomainExtensionNextActionKind.recommendedField:
        return colorScheme.primary;
      case ProjectDomainExtensionNextActionKind.complete:
        return Colors.green.shade700;
    }
  }
}
