import 'package:flutter/material.dart';

import '../../models/employee_development_models.dart';

Color employeeSkillStatusColor(EmployeeSkillStatus status) {
  return switch (status) {
    EmployeeSkillStatus.gap => const Color(0xFFB91C1C),
    EmployeeSkillStatus.building => const Color(0xFFB45309),
    EmployeeSkillStatus.proficient => const Color(0xFF2563EB),
    EmployeeSkillStatus.verified => const Color(0xFF15803D),
  };
}

Color employeeLearningStatusColor(EmployeeLearningStatus status) {
  return switch (status) {
    EmployeeLearningStatus.assigned => const Color(0xFF2563EB),
    EmployeeLearningStatus.inProgress => const Color(0xFFB45309),
    EmployeeLearningStatus.completed => const Color(0xFF15803D),
    EmployeeLearningStatus.overdue => const Color(0xFFB91C1C),
  };
}

Color employeeCertificationStatusColor(EmployeeCertificationStatus status) {
  return switch (status) {
    EmployeeCertificationStatus.active => const Color(0xFF15803D),
    EmployeeCertificationStatus.expiring => const Color(0xFFB45309),
    EmployeeCertificationStatus.expired => const Color(0xFFB91C1C),
    EmployeeCertificationStatus.missing => const Color(0xFFB91C1C),
  };
}

IconData employeeCertificationStatusIcon(EmployeeCertificationStatus status) {
  return switch (status) {
    EmployeeCertificationStatus.active => Icons.verified_outlined,
    EmployeeCertificationStatus.expiring => Icons.update_outlined,
    EmployeeCertificationStatus.expired => Icons.error_outline,
    EmployeeCertificationStatus.missing => Icons.report_outlined,
  };
}
