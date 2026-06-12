import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

import '../services/project_domain_gap_repair_service.dart';

class ProjectDomainGapRepairNextAction extends StatelessWidget {
  const ProjectDomainGapRepairNextAction({
    required this.target,
    required this.onRepair,
    super.key,
  });

  final ProjectDomainGapRepairTarget? target;
  final ValueChanged<ProjectDomainGapRepairTarget> onRepair;

  @override
  Widget build(BuildContext context) {
    final repairTarget = target;
    if (repairTarget == null) return const SizedBox.shrink();

    return Tooltip(
      message:
          'Open ${repairTarget.fieldLabel} for ${repairTarget.projectLabel}.',
      child: AppActionButton(
        key: const ValueKey('project-domain-gap-repair-fix-next'),
        label: 'Fix Next',
        icon: Icons.bolt_outlined,
        height: 34,
        compact: true,
        onPressed: () => onRepair(repairTarget),
      ),
    );
  }
}
