import 'package:flutter/material.dart';

import '../../models/employee_position_control_models.dart';

Color employeePositionStatusColor(EmployeePositionStatus status) {
  return switch (status) {
    EmployeePositionStatus.filled => const Color(0xFF15803D),
    EmployeePositionStatus.vacant => const Color(0xFFB45309),
    EmployeePositionStatus.backfillPending => const Color(0xFF2563EB),
    EmployeePositionStatus.frozen => const Color(0xFF64748B),
    EmployeePositionStatus.overAllocated => const Color(0xFFB91C1C),
  };
}

Color employeePositionBudgetStatusColor(EmployeePositionBudgetStatus status) {
  return switch (status) {
    EmployeePositionBudgetStatus.inBudget => const Color(0xFF15803D),
    EmployeePositionBudgetStatus.watch => const Color(0xFFB45309),
    EmployeePositionBudgetStatus.overBudget => const Color(0xFFB91C1C),
  };
}

Color employeePositionCriticalityColor(
  EmployeePositionCriticality criticality,
) {
  return switch (criticality) {
    EmployeePositionCriticality.critical => const Color(0xFFB91C1C),
    EmployeePositionCriticality.high => const Color(0xFFC2410C),
    EmployeePositionCriticality.standard => const Color(0xFF2563EB),
    EmployeePositionCriticality.low => const Color(0xFF64748B),
  };
}

Color employeePositionRequisitionStatusColor(
  EmployeePositionRequisitionStatus status,
) {
  return switch (status) {
    EmployeePositionRequisitionStatus.draft => const Color(0xFF64748B),
    EmployeePositionRequisitionStatus.submitted => const Color(0xFFB45309),
    EmployeePositionRequisitionStatus.approved => const Color(0xFF2563EB),
    EmployeePositionRequisitionStatus.open => const Color(0xFF7C3AED),
    EmployeePositionRequisitionStatus.filled => const Color(0xFF15803D),
    EmployeePositionRequisitionStatus.cancelled => const Color(0xFF6B7280),
  };
}

IconData employeePositionRequisitionTypeIcon(
  EmployeePositionRequisitionType type,
) {
  return switch (type) {
    EmployeePositionRequisitionType.newHeadcount => Icons.add_business_outlined,
    EmployeePositionRequisitionType.backfill => Icons.swap_horiz_outlined,
    EmployeePositionRequisitionType.conversion => Icons.published_with_changes,
    EmployeePositionRequisitionType.temporaryCover => Icons.schedule_outlined,
  };
}
