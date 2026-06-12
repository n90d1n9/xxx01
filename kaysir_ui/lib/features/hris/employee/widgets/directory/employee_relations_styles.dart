import 'package:flutter/material.dart';

import '../../models/employee_relations_models.dart';

Color employeeRelationsStatusColor(EmployeeRelationsStatus status) {
  return switch (status) {
    EmployeeRelationsStatus.documented => const Color(0xFF15803D),
    EmployeeRelationsStatus.followUpDue => const Color(0xFFB45309),
    EmployeeRelationsStatus.inProgress => const Color(0xFF2563EB),
    EmployeeRelationsStatus.resolved => const Color(0xFF15803D),
    EmployeeRelationsStatus.archived => const Color(0xFF64748B),
  };
}

Color employeeRelationsSeverityColor(EmployeeRelationsSeverity severity) {
  return switch (severity) {
    EmployeeRelationsSeverity.low => const Color(0xFF15803D),
    EmployeeRelationsSeverity.medium => const Color(0xFF2563EB),
    EmployeeRelationsSeverity.high => const Color(0xFFB45309),
    EmployeeRelationsSeverity.critical => const Color(0xFFB91C1C),
  };
}

IconData employeeRelationsEventTypeIcon(EmployeeRelationsEventType type) {
  return switch (type) {
    EmployeeRelationsEventType.recognition => Icons.celebration_outlined,
    EmployeeRelationsEventType.commendation => Icons.workspace_premium_outlined,
    EmployeeRelationsEventType.coaching => Icons.record_voice_over_outlined,
    EmployeeRelationsEventType.conductIncident =>
      Icons.report_gmailerrorred_outlined,
    EmployeeRelationsEventType.writtenWarning => Icons.gavel_outlined,
    EmployeeRelationsEventType.performanceImprovement =>
      Icons.trending_up_outlined,
  };
}

IconData employeeRelationsVisibilityIcon(EmployeeRelationsVisibility value) {
  return switch (value) {
    EmployeeRelationsVisibility.team => Icons.groups_outlined,
    EmployeeRelationsVisibility.managerOnly =>
      Icons.supervisor_account_outlined,
    EmployeeRelationsVisibility.confidential => Icons.lock_outline,
  };
}
