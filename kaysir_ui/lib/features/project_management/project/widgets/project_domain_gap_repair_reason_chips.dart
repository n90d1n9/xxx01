import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_reason_service.dart';

class ProjectDomainGapRepairReasonChips extends StatelessWidget {
  const ProjectDomainGapRepairReasonChips({required this.reasonSet, super.key});

  final ProjectDomainGapRepairReasonSet reasonSet;

  @override
  Widget build(BuildContext context) {
    if (reasonSet.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        for (final reason in reasonSet.reasons)
          AppStatusPill(
            label: reason.label,
            icon: _reasonIcon(reason.kind),
            color: _reasonColor(reason.kind, colorScheme),
            tooltip: reason.detail,
            maxWidth: 190,
          ),
      ],
    );
  }
}

IconData _reasonIcon(ProjectDomainGapRepairReasonKind kind) {
  switch (kind) {
    case ProjectDomainGapRepairReasonKind.requiredField:
      return Icons.rule_folder_outlined;
    case ProjectDomainGapRepairReasonKind.riskSignal:
      return Icons.sensors_outlined;
    case ProjectDomainGapRepairReasonKind.recommendedField:
      return Icons.fact_check_outlined;
    case ProjectDomainGapRepairReasonKind.coverageGap:
      return Icons.view_column_outlined;
    case ProjectDomainGapRepairReasonKind.blockedProject:
      return Icons.block_outlined;
    case ProjectDomainGapRepairReasonKind.atRiskProject:
      return Icons.warning_amber_rounded;
    case ProjectDomainGapRepairReasonKind.dueSoon:
      return Icons.event_outlined;
    case ProjectDomainGapRepairReasonKind.overdue:
      return Icons.event_busy_outlined;
  }
}

Color _reasonColor(
  ProjectDomainGapRepairReasonKind kind,
  ColorScheme colorScheme,
) {
  switch (kind) {
    case ProjectDomainGapRepairReasonKind.requiredField:
      return colorScheme.error;
    case ProjectDomainGapRepairReasonKind.riskSignal:
      return colorScheme.tertiary;
    case ProjectDomainGapRepairReasonKind.recommendedField:
      return colorScheme.primary;
    case ProjectDomainGapRepairReasonKind.coverageGap:
      return colorScheme.secondary;
    case ProjectDomainGapRepairReasonKind.blockedProject:
      return colorScheme.error;
    case ProjectDomainGapRepairReasonKind.atRiskProject:
      return Colors.orange.shade700;
    case ProjectDomainGapRepairReasonKind.dueSoon:
      return colorScheme.primary;
    case ProjectDomainGapRepairReasonKind.overdue:
      return colorScheme.error;
  }
}
