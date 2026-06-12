import 'package:flutter/material.dart';

import '../services/project_domain_gap_repair_service.dart';

IconData projectDomainGapRepairPriorityIcon(
  ProjectDomainGapRepairPriority priority,
) {
  switch (priority) {
    case ProjectDomainGapRepairPriority.requiredField:
      return Icons.priority_high_rounded;
    case ProjectDomainGapRepairPriority.riskSignal:
      return Icons.sensors_outlined;
    case ProjectDomainGapRepairPriority.recommended:
      return Icons.fact_check_outlined;
    case ProjectDomainGapRepairPriority.coverageGap:
      return Icons.edit_note_outlined;
  }
}

Color projectDomainGapRepairPriorityColor(
  ProjectDomainGapRepairPriority priority,
  ColorScheme colorScheme,
) {
  switch (priority) {
    case ProjectDomainGapRepairPriority.requiredField:
      return colorScheme.error;
    case ProjectDomainGapRepairPriority.riskSignal:
      return colorScheme.tertiary;
    case ProjectDomainGapRepairPriority.recommended:
      return colorScheme.primary;
    case ProjectDomainGapRepairPriority.coverageGap:
      return colorScheme.secondary;
  }
}
