import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_service.dart';
import '../services/project_domain_gap_repair_session_service.dart';
import 'project_domain_gap_repair_next_action.dart';

class ProjectDomainGapRepairSessionStrip extends StatelessWidget {
  const ProjectDomainGapRepairSessionStrip({
    required this.summary,
    required this.onRepair,
    super.key,
  });

  final ProjectDomainGapRepairSessionSummary summary;
  final ValueChanged<ProjectDomainGapRepairTarget> onRepair;

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppStatusPill(
          label: summary.stepCountLabel,
          icon: Icons.route_outlined,
          color: colorScheme.primary,
          tooltip: summary.priorityPathLabel,
          maxWidth: 160,
        ),
        AppStatusPill(
          label: summary.nextStepLabel,
          icon: Icons.flag_outlined,
          color: colorScheme.secondary,
          tooltip: 'Start with the highest-priority repair target.',
          maxWidth: 320,
        ),
        AppStatusPill(
          label: summary.domainScopeLabel,
          icon: Icons.business_center_outlined,
          color: colorScheme.tertiary,
          maxWidth: 130,
        ),
        ProjectDomainGapRepairNextAction(
          target: summary.nextTarget,
          onRepair: onRepair,
        ),
      ],
    );
  }
}
