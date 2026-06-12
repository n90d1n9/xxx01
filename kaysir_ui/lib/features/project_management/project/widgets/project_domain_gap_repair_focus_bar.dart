import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

import '../services/project_domain_gap_repair_service.dart';
import 'project_domain_gap_repair_priority_visuals.dart';

class ProjectDomainGapRepairFocusBar extends StatelessWidget {
  const ProjectDomainGapRepairFocusBar({
    required this.plan,
    required this.onFocusPriority,
    super.key,
  });

  static bool hasActionsFor(ProjectDomainGapRepairPlan plan) {
    return _actionsFor(plan).isNotEmpty;
  }

  final ProjectDomainGapRepairPlan plan;
  final ValueChanged<ProjectDomainGapRepairPriority> onFocusPriority;

  @override
  Widget build(BuildContext context) {
    final actions = _actionsFor(plan);
    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          AppActionButton(
            key: ValueKey(
              'project-domain-gap-repair-focus-${action.priority.name}',
            ),
            label: action.label,
            icon: action.icon,
            variant: AppActionButtonVariant.secondary,
            height: 34,
            compact: true,
            onPressed: () => onFocusPriority(action.priority),
          ),
      ],
    );
  }
}

List<_RepairFocusAction> _actionsFor(ProjectDomainGapRepairPlan plan) {
  return [
    if (plan.requiredTargetCount > 0)
      _RepairFocusAction(
        priority: ProjectDomainGapRepairPriority.requiredField,
        label: 'Required ${plan.requiredTargetCount}',
        icon: projectDomainGapRepairPriorityIcon(
          ProjectDomainGapRepairPriority.requiredField,
        ),
      ),
    if (plan.riskSignalTargetCount > 0)
      _RepairFocusAction(
        priority: ProjectDomainGapRepairPriority.riskSignal,
        label: 'Risk ${plan.riskSignalTargetCount}',
        icon: projectDomainGapRepairPriorityIcon(
          ProjectDomainGapRepairPriority.riskSignal,
        ),
      ),
    if (plan.recommendedTargetCount > 0)
      _RepairFocusAction(
        priority: ProjectDomainGapRepairPriority.recommended,
        label: 'Recommended ${plan.recommendedTargetCount}',
        icon: projectDomainGapRepairPriorityIcon(
          ProjectDomainGapRepairPriority.recommended,
        ),
      ),
    if (plan.coverageGapTargetCount > 0)
      _RepairFocusAction(
        priority: ProjectDomainGapRepairPriority.coverageGap,
        label: 'Coverage ${plan.coverageGapTargetCount}',
        icon: projectDomainGapRepairPriorityIcon(
          ProjectDomainGapRepairPriority.coverageGap,
        ),
      ),
  ];
}

class _RepairFocusAction {
  const _RepairFocusAction({
    required this.priority,
    required this.label,
    required this.icon,
  });

  final ProjectDomainGapRepairPriority priority;
  final String label;
  final IconData icon;
}
