import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_session_playbook_service.dart';

class ProjectDomainGapRepairSessionPlaybookStrip extends StatelessWidget {
  const ProjectDomainGapRepairSessionPlaybookStrip({
    required this.summary,
    super.key,
  });

  final ProjectDomainGapRepairSessionPlaybookSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final playbookColor = _playbookColor(summary.kind, colorScheme);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppStatusPill(
          label: summary.playbookLabel,
          icon: _playbookIcon(summary.kind),
          color: playbookColor,
          tooltip: summary.playbookTooltip,
          maxWidth: 230,
        ),
        AppStatusPill(
          label: summary.reviewerLabel,
          icon: Icons.groups_outlined,
          color: colorScheme.tertiary,
          tooltip: summary.reviewerTooltip,
          maxWidth: 190,
        ),
        AppStatusPill(
          label: summary.evidenceLabel,
          icon: Icons.description_outlined,
          color: colorScheme.secondary,
          tooltip: summary.evidenceTooltip,
          maxWidth: 220,
        ),
      ],
    );
  }
}

IconData _playbookIcon(ProjectDomainGapRepairSessionPlaybookKind kind) {
  switch (kind) {
    case ProjectDomainGapRepairSessionPlaybookKind.recoveryChecklist:
      return Icons.fact_check_outlined;
    case ProjectDomainGapRepairSessionPlaybookKind.riskReview:
      return Icons.policy_outlined;
    case ProjectDomainGapRepairSessionPlaybookKind.domainSetup:
      return Icons.dashboard_customize_outlined;
    case ProjectDomainGapRepairSessionPlaybookKind.reportingPolish:
      return Icons.edit_note_outlined;
  }
}

Color _playbookColor(
  ProjectDomainGapRepairSessionPlaybookKind kind,
  ColorScheme colorScheme,
) {
  switch (kind) {
    case ProjectDomainGapRepairSessionPlaybookKind.recoveryChecklist:
      return colorScheme.error;
    case ProjectDomainGapRepairSessionPlaybookKind.riskReview:
      return colorScheme.tertiary;
    case ProjectDomainGapRepairSessionPlaybookKind.domainSetup:
      return colorScheme.primary;
    case ProjectDomainGapRepairSessionPlaybookKind.reportingPolish:
      return colorScheme.secondary;
  }
}
