import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../models/project_portfolio_item.dart';
import '../services/project_domain_gap_repair_field_hint_service.dart';
import '../services/project_domain_gap_repair_reason_service.dart';
import '../services/project_domain_gap_repair_service.dart';
import 'project_domain_gap_repair_field_hint_chip.dart';
import 'project_domain_gap_repair_priority_visuals.dart';
import 'project_domain_gap_repair_reason_chips.dart';

class ProjectDomainGapRepairTargetRow extends StatelessWidget {
  const ProjectDomainGapRepairTargetRow({
    required this.target,
    required this.onRepair,
    super.key,
  });

  final ProjectDomainGapRepairTarget target;
  final VoidCallback onRepair;

  @override
  Widget build(BuildContext context) {
    final content = _ProjectDomainGapRepairTargetContent(target: target);
    final action = AppActionButton(
      key: ValueKey(
        'project-domain-gap-repair-${target.project.id}-${target.column.key}',
      ),
      label: 'Fix',
      icon: Icons.edit_outlined,
      variant: AppActionButtonVariant.secondary,
      compact: true,
      onPressed: onRepair,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: content),
            const SizedBox(width: 12),
            action,
          ],
        );
      },
    );
  }
}

class _ProjectDomainGapRepairTargetContent extends StatelessWidget {
  const _ProjectDomainGapRepairTargetContent({required this.target});

  final ProjectDomainGapRepairTarget target;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = projectDomainGapRepairPriorityColor(
      target.priority,
      colorScheme,
    );
    final fieldHint = buildProjectDomainGapRepairFieldHint(target: target);
    final reasonSet = buildProjectDomainGapRepairReasonSet(target: target);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          projectDomainGapRepairPriorityIcon(target.priority),
          color: priorityColor,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${target.fieldLabel} - ${target.projectLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  AppStatusPill(
                    label: target.priorityLabel,
                    icon: projectDomainGapRepairPriorityIcon(target.priority),
                    color: priorityColor,
                    maxWidth: 150,
                  ),
                  AppStatusPill(
                    label: target.contextLabel,
                    icon: target.project.health.icon,
                    color: target.project.health.color(colorScheme),
                    maxWidth: 250,
                  ),
                  ProjectDomainGapRepairFieldHintChip(hint: fieldHint),
                ],
              ),
              const SizedBox(height: 6),
              ProjectDomainGapRepairReasonChips(reasonSet: reasonSet),
            ],
          ),
        ),
      ],
    );
  }
}
