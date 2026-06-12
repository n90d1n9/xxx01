import 'package:flutter/material.dart';

import '../../models/employee_contract_lifecycle_models.dart';

Color employeeContractStatusColor(EmployeeContractStatus status) {
  return switch (status) {
    EmployeeContractStatus.active => const Color(0xFF15803D),
    EmployeeContractStatus.probation => const Color(0xFF2563EB),
    EmployeeContractStatus.renewalDue => const Color(0xFFB45309),
    EmployeeContractStatus.pendingSignature => const Color(0xFF7C3AED),
    EmployeeContractStatus.expired => const Color(0xFFB91C1C),
    EmployeeContractStatus.terminated => const Color(0xFF64748B),
  };
}

Color employeeContractChangeStatusColor(EmployeeContractChangeStatus status) {
  return switch (status) {
    EmployeeContractChangeStatus.submitted => const Color(0xFF2563EB),
    EmployeeContractChangeStatus.approved => const Color(0xFFB45309),
    EmployeeContractChangeStatus.signed => const Color(0xFF7C3AED),
    EmployeeContractChangeStatus.activated => const Color(0xFF15803D),
    EmployeeContractChangeStatus.rejected => const Color(0xFFB91C1C),
  };
}

IconData employeeContractTypeIcon(EmployeeContractType type) {
  return switch (type) {
    EmployeeContractType.permanent => Icons.verified_user_outlined,
    EmployeeContractType.fixedTerm => Icons.event_available_outlined,
    EmployeeContractType.probation => Icons.hourglass_top_outlined,
    EmployeeContractType.internship => Icons.school_outlined,
    EmployeeContractType.contractor => Icons.badge_outlined,
  };
}

IconData employeeContractChangeTypeIcon(EmployeeContractChangeType type) {
  return switch (type) {
    EmployeeContractChangeType.renewal => Icons.autorenew_outlined,
    EmployeeContractChangeType.extension => Icons.more_time_outlined,
    EmployeeContractChangeType.conversion => Icons.swap_horiz_outlined,
    EmployeeContractChangeType.compensationClause => Icons.payments_outlined,
    EmployeeContractChangeType.endDateChange => Icons.event_repeat_outlined,
  };
}
