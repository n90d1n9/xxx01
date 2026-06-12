import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_impact_service.dart';

class ProjectDomainGapRepairImpactStrip extends StatelessWidget {
  const ProjectDomainGapRepairImpactStrip({required this.summary, super.key});

  final ProjectDomainGapRepairImpactSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final urgencyColor =
        summary.blockedProjectCount > 0
            ? colorScheme.error
            : Colors.orange.shade700;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppStatusPill(
          label: 'Next: ${summary.nextFixLabel}',
          icon: Icons.bolt_outlined,
          color: colorScheme.primary,
          tooltip:
              'Top repair based on field importance, risk signal, project health, and due date.',
          maxWidth: 300,
        ),
        AppStatusPill(
          label: summary.projectScopeLabel,
          icon: Icons.account_tree_outlined,
          color: colorScheme.secondary,
          maxWidth: 140,
        ),
        AppStatusPill(
          label: summary.fieldScopeLabel,
          icon: Icons.view_column_outlined,
          color: colorScheme.secondary,
          maxWidth: 128,
        ),
        AppStatusPill(
          label: summary.domainScopeLabel,
          icon: Icons.business_center_outlined,
          color: colorScheme.tertiary,
          tooltip: summary.domainTooltip,
          maxWidth: 190,
        ),
        if (summary.hasUrgentHealthContext)
          AppStatusPill(
            label: summary.urgencyLabel,
            icon:
                summary.blockedProjectCount > 0
                    ? Icons.block_outlined
                    : Icons.warning_amber_rounded,
            color: urgencyColor,
            maxWidth: 190,
          ),
      ],
    );
  }
}
