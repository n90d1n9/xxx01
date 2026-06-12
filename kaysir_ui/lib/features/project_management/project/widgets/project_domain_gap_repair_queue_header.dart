import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_service.dart';
import 'project_domain_gap_repair_priority_visuals.dart';

class ProjectDomainGapRepairQueueHeader extends StatelessWidget {
  const ProjectDomainGapRepairQueueHeader({
    required this.plan,
    required this.isExpanded,
    super.key,
  });

  final ProjectDomainGapRepairPlan plan;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.edit_note_outlined,
              color: colorScheme.primary,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Field Repair Queue',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                _subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (plan.requiredTargetCount > 0)
                    _PriorityCountPill(
                      priority: ProjectDomainGapRepairPriority.requiredField,
                      label: 'Required: ${plan.requiredTargetCount}',
                      maxWidth: 150,
                    ),
                  if (plan.riskSignalTargetCount > 0)
                    _PriorityCountPill(
                      priority: ProjectDomainGapRepairPriority.riskSignal,
                      label: 'Risk: ${plan.riskSignalTargetCount}',
                      maxWidth: 128,
                    ),
                  if (plan.recommendedTargetCount > 0)
                    _PriorityCountPill(
                      priority: ProjectDomainGapRepairPriority.recommended,
                      label: 'Recommended: ${plan.recommendedTargetCount}',
                      maxWidth: 190,
                    ),
                  if (plan.hasHiddenTargets)
                    AppStatusPill(
                      label: '+${plan.hiddenTargetCount} more',
                      icon: Icons.more_horiz_rounded,
                      color: colorScheme.secondary,
                      maxWidth: 120,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String get _subtitle {
    if (!plan.hasHiddenTargets) {
      return '${plan.visibleTargetCount} editable domain gaps from the current table view';
    }

    if (isExpanded) {
      return '${plan.totalTargetCount} editable domain gaps shown by priority';
    }

    return '${plan.visibleTargetCount} of ${plan.totalTargetCount} editable domain gaps shown by priority';
  }
}

class _PriorityCountPill extends StatelessWidget {
  const _PriorityCountPill({
    required this.priority,
    required this.label,
    required this.maxWidth,
  });

  final ProjectDomainGapRepairPriority priority;
  final String label;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppStatusPill(
      label: label,
      icon: projectDomainGapRepairPriorityIcon(priority),
      color: projectDomainGapRepairPriorityColor(priority, colorScheme),
      maxWidth: maxWidth,
    );
  }
}
