import 'package:flutter/material.dart';

import '../../models/employee_talent_calibration_models.dart';

Color employeeTalentRiskColor(EmployeeTalentRiskLevel risk) {
  return switch (risk) {
    EmployeeTalentRiskLevel.critical => const Color(0xFFB91C1C),
    EmployeeTalentRiskLevel.high => const Color(0xFFC2410C),
    EmployeeTalentRiskLevel.medium => const Color(0xFFB45309),
    EmployeeTalentRiskLevel.low => const Color(0xFF15803D),
  };
}

Color employeeTalentStatusColor(EmployeeTalentCalibrationStatus status) {
  return switch (status) {
    EmployeeTalentCalibrationStatus.draft => const Color(0xFF64748B),
    EmployeeTalentCalibrationStatus.calibrated => const Color(0xFF15803D),
    EmployeeTalentCalibrationStatus.actionDue => const Color(0xFFB45309),
    EmployeeTalentCalibrationStatus.disputed => const Color(0xFFB91C1C),
    EmployeeTalentCalibrationStatus.archived => const Color(0xFF6B7280),
  };
}

Color employeeTalentDecisionColor(EmployeeTalentCalibrationDecision decision) {
  return switch (decision) {
    EmployeeTalentCalibrationDecision.advance => const Color(0xFF15803D),
    EmployeeTalentCalibrationDecision.invest => const Color(0xFF2563EB),
    EmployeeTalentCalibrationDecision.retain => const Color(0xFF7C3AED),
    EmployeeTalentCalibrationDecision.stabilize => const Color(0xFFB45309),
    EmployeeTalentCalibrationDecision.monitor => const Color(0xFF64748B),
  };
}

Color employeeTalentFollowUpStatusColor(EmployeeTalentFollowUpStatus status) {
  return switch (status) {
    EmployeeTalentFollowUpStatus.open => const Color(0xFFB45309),
    EmployeeTalentFollowUpStatus.inProgress => const Color(0xFF2563EB),
    EmployeeTalentFollowUpStatus.completed => const Color(0xFF15803D),
    EmployeeTalentFollowUpStatus.waived => const Color(0xFF6B7280),
  };
}

IconData employeeTalentFollowUpTypeIcon(EmployeeTalentFollowUpType type) {
  return switch (type) {
    EmployeeTalentFollowUpType.compensationReview => Icons.payments_outlined,
    EmployeeTalentFollowUpType.developmentPlan => Icons.school_outlined,
    EmployeeTalentFollowUpType.retentionCheck => Icons.favorite_border,
    EmployeeTalentFollowUpType.managerCoaching => Icons.support_agent_outlined,
    EmployeeTalentFollowUpType.successionReview => Icons.account_tree_outlined,
  };
}
