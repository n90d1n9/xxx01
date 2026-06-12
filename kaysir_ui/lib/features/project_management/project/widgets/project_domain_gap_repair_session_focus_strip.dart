import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../services/project_domain_gap_repair_session_focus_service.dart';

class ProjectDomainGapRepairSessionFocusStrip extends StatelessWidget {
  const ProjectDomainGapRepairSessionFocusStrip({
    required this.summary,
    super.key,
  });

  final ProjectDomainGapRepairSessionFocusSummary summary;

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final focusColor = _focusColor(summary.focusKind, colorScheme);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppStatusPill(
          label: summary.focusLabel,
          icon: _focusIcon(summary.focusKind),
          color: focusColor,
          tooltip: summary.focusTooltip,
          maxWidth: 230,
        ),
        AppStatusPill(
          label: summary.paceLabel,
          icon: Icons.timer_outlined,
          color: colorScheme.secondary,
          maxWidth: 160,
        ),
        AppStatusPill(
          label: summary.scopeLabel,
          icon: Icons.account_tree_outlined,
          color: colorScheme.tertiary,
          tooltip: summary.scopeTooltip,
          maxWidth: 180,
        ),
      ],
    );
  }
}

IconData _focusIcon(ProjectDomainGapRepairSessionFocusKind kind) {
  switch (kind) {
    case ProjectDomainGapRepairSessionFocusKind.stabilization:
      return Icons.health_and_safety_outlined;
    case ProjectDomainGapRepairSessionFocusKind.riskControl:
      return Icons.sensors_outlined;
    case ProjectDomainGapRepairSessionFocusKind.domainCoverage:
      return Icons.dashboard_customize_outlined;
    case ProjectDomainGapRepairSessionFocusKind.contextPolish:
      return Icons.auto_awesome_outlined;
  }
}

Color _focusColor(
  ProjectDomainGapRepairSessionFocusKind kind,
  ColorScheme colorScheme,
) {
  switch (kind) {
    case ProjectDomainGapRepairSessionFocusKind.stabilization:
      return colorScheme.error;
    case ProjectDomainGapRepairSessionFocusKind.riskControl:
      return colorScheme.tertiary;
    case ProjectDomainGapRepairSessionFocusKind.domainCoverage:
      return colorScheme.primary;
    case ProjectDomainGapRepairSessionFocusKind.contextPolish:
      return colorScheme.secondary;
  }
}
