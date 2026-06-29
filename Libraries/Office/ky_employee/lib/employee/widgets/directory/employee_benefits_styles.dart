import 'package:flutter/material.dart';

import '../../models/employee_benefits_models.dart';

Color employeeBenefitEnrollmentStatusColor(
  EmployeeBenefitEnrollmentStatus status,
) {
  return switch (status) {
    EmployeeBenefitEnrollmentStatus.active => const Color(0xFF15803D),
    EmployeeBenefitEnrollmentStatus.pending => const Color(0xFFB45309),
    EmployeeBenefitEnrollmentStatus.waived => const Color(0xFF6B7280),
    EmployeeBenefitEnrollmentStatus.actionRequired => const Color(0xFFB91C1C),
  };
}

Color employeeDependentVerificationStatusColor(
  EmployeeDependentVerificationStatus status,
) {
  return switch (status) {
    EmployeeDependentVerificationStatus.verified => const Color(0xFF15803D),
    EmployeeDependentVerificationStatus.pending => const Color(0xFFB45309),
    EmployeeDependentVerificationStatus.expiring => const Color(0xFFB45309),
    EmployeeDependentVerificationStatus.missing => const Color(0xFFB91C1C),
  };
}

IconData employeeBenefitPlanTypeIcon(EmployeeBenefitPlanType type) {
  return switch (type) {
    EmployeeBenefitPlanType.medical => Icons.health_and_safety_outlined,
    EmployeeBenefitPlanType.dental => Icons.medical_services_outlined,
    EmployeeBenefitPlanType.vision => Icons.visibility_outlined,
    EmployeeBenefitPlanType.retirement => Icons.savings_outlined,
    EmployeeBenefitPlanType.wellness => Icons.spa_outlined,
  };
}
