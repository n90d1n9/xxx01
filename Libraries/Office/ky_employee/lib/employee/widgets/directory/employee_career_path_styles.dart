import 'package:flutter/material.dart';

import '../../models/employee_career_path_models.dart';

Color employeeCareerReadinessColor(EmployeeCareerReadiness readiness) {
  return switch (readiness) {
    EmployeeCareerReadiness.readyNow => const Color(0xFF15803D),
    EmployeeCareerReadiness.readySoon => const Color(0xFF2563EB),
    EmployeeCareerReadiness.developing => const Color(0xFFB45309),
    EmployeeCareerReadiness.exploratory => const Color(0xFF64748B),
  };
}

Color employeeSuccessionCoverageColor(EmployeeSuccessionCoverage coverage) {
  return switch (coverage) {
    EmployeeSuccessionCoverage.covered => const Color(0xFF15803D),
    EmployeeSuccessionCoverage.partial => const Color(0xFFB45309),
    EmployeeSuccessionCoverage.uncovered => const Color(0xFFB91C1C),
    EmployeeSuccessionCoverage.notCritical => const Color(0xFF64748B),
  };
}

Color employeeCareerMoveStatusColor(EmployeeCareerMoveStatus status) {
  return switch (status) {
    EmployeeCareerMoveStatus.proposed => const Color(0xFF2563EB),
    EmployeeCareerMoveStatus.approved => const Color(0xFFB45309),
    EmployeeCareerMoveStatus.active => const Color(0xFF7C3AED),
    EmployeeCareerMoveStatus.completed => const Color(0xFF15803D),
    EmployeeCareerMoveStatus.declined => const Color(0xFFB91C1C),
  };
}

IconData employeeCareerMoveTypeIcon(EmployeeCareerMoveType type) {
  return switch (type) {
    EmployeeCareerMoveType.promotion => Icons.rocket_launch_outlined,
    EmployeeCareerMoveType.lateralMove => Icons.swap_horiz_outlined,
    EmployeeCareerMoveType.stretchAssignment => Icons.trending_up_outlined,
    EmployeeCareerMoveType.mentorship => Icons.record_voice_over_outlined,
    EmployeeCareerMoveType.successionNomination => Icons.account_tree_outlined,
  };
}

IconData employeeMobilityPreferenceIcon(EmployeeMobilityPreference preference) {
  return switch (preference) {
    EmployeeMobilityPreference.sameTeam => Icons.group_work_outlined,
    EmployeeMobilityPreference.crossFunctional => Icons.hub_outlined,
    EmployeeMobilityPreference.managerTrack =>
      Icons.supervisor_account_outlined,
    EmployeeMobilityPreference.specialistTrack => Icons.psychology_outlined,
    EmployeeMobilityPreference.remoteFirst => Icons.public_outlined,
  };
}
