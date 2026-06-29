import 'package:flutter/material.dart';

import '../../models/employee_succession_plan_models.dart';

Color employeeSuccessionCriticalityColor(
  EmployeeSuccessionCriticality criticality,
) {
  return switch (criticality) {
    EmployeeSuccessionCriticality.critical => const Color(0xFF991B1B),
    EmployeeSuccessionCriticality.high => const Color(0xFFB45309),
    EmployeeSuccessionCriticality.medium => const Color(0xFF1D4ED8),
    EmployeeSuccessionCriticality.low => const Color(0xFF15803D),
  };
}

Color employeeSuccessionCoverageStatusColor(
  EmployeeSuccessionCoverageStatus status,
) {
  return switch (status) {
    EmployeeSuccessionCoverageStatus.covered => const Color(0xFF15803D),
    EmployeeSuccessionCoverageStatus.atRisk => const Color(0xFFB45309),
    EmployeeSuccessionCoverageStatus.gap => const Color(0xFFB91C1C),
    EmployeeSuccessionCoverageStatus.building => const Color(0xFF2563EB),
  };
}

Color employeeSuccessionReadinessColor(EmployeeSuccessionReadiness readiness) {
  return switch (readiness) {
    EmployeeSuccessionReadiness.readyNow => const Color(0xFF15803D),
    EmployeeSuccessionReadiness.readySoon => const Color(0xFF1D4ED8),
    EmployeeSuccessionReadiness.developing => const Color(0xFFB45309),
    EmployeeSuccessionReadiness.hold => const Color(0xFF6B7280),
  };
}

Color employeeSuccessionRiskColor(EmployeeSuccessionRisk risk) {
  return switch (risk) {
    EmployeeSuccessionRisk.critical => const Color(0xFF991B1B),
    EmployeeSuccessionRisk.high => const Color(0xFFB91C1C),
    EmployeeSuccessionRisk.medium => const Color(0xFFB45309),
    EmployeeSuccessionRisk.low => const Color(0xFF15803D),
  };
}

IconData employeeSuccessionCoverageStatusIcon(
  EmployeeSuccessionCoverageStatus status,
) {
  return switch (status) {
    EmployeeSuccessionCoverageStatus.covered => Icons.verified_user_outlined,
    EmployeeSuccessionCoverageStatus.atRisk => Icons.warning_amber_outlined,
    EmployeeSuccessionCoverageStatus.gap => Icons.report_problem_outlined,
    EmployeeSuccessionCoverageStatus.building => Icons.construction_outlined,
  };
}

IconData employeeSuccessionReadinessIcon(
  EmployeeSuccessionReadiness readiness,
) {
  return switch (readiness) {
    EmployeeSuccessionReadiness.readyNow => Icons.check_circle_outline,
    EmployeeSuccessionReadiness.readySoon => Icons.schedule_outlined,
    EmployeeSuccessionReadiness.developing => Icons.school_outlined,
    EmployeeSuccessionReadiness.hold => Icons.pause_circle_outline,
  };
}

IconData employeeSuccessionActionTypeIcon(
  EmployeeSuccessionActionType actionType,
) {
  return switch (actionType) {
    EmployeeSuccessionActionType.talentReview => Icons.fact_check_outlined,
    EmployeeSuccessionActionType.developmentPlan => Icons.school_outlined,
    EmployeeSuccessionActionType.retentionCheck => Icons.favorite_outline,
    EmployeeSuccessionActionType.knowledgeTransfer =>
      Icons.swap_horizontal_circle_outlined,
    EmployeeSuccessionActionType.compensationReview => Icons.payments_outlined,
  };
}
