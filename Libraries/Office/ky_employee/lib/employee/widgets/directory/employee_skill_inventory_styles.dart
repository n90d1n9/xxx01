import 'package:flutter/material.dart';

import '../../models/employee_skill_inventory_models.dart';

Color employeeSkillVerificationStatusColor(
  EmployeeSkillVerificationStatus status,
) {
  return switch (status) {
    EmployeeSkillVerificationStatus.evidenceDue => const Color(0xFFB45309),
    EmployeeSkillVerificationStatus.inReview => const Color(0xFF2563EB),
    EmployeeSkillVerificationStatus.verified => const Color(0xFF15803D),
    EmployeeSkillVerificationStatus.expired => const Color(0xFFB91C1C),
    EmployeeSkillVerificationStatus.waived => const Color(0xFF6B7280),
  };
}

Color employeeSkillCriticalityColor(EmployeeSkillCriticality criticality) {
  return switch (criticality) {
    EmployeeSkillCriticality.critical => const Color(0xFFB91C1C),
    EmployeeSkillCriticality.core => const Color(0xFF2563EB),
    EmployeeSkillCriticality.growth => const Color(0xFF7C3AED),
    EmployeeSkillCriticality.optional => const Color(0xFF64748B),
  };
}

IconData employeeSkillCategoryIcon(EmployeeSkillInventoryCategory category) {
  return switch (category) {
    EmployeeSkillInventoryCategory.technical => Icons.code_outlined,
    EmployeeSkillInventoryCategory.domain => Icons.psychology_outlined,
    EmployeeSkillInventoryCategory.leadership => Icons.groups_2_outlined,
    EmployeeSkillInventoryCategory.compliance => Icons.policy_outlined,
    EmployeeSkillInventoryCategory.operations => Icons.hub_outlined,
  };
}
