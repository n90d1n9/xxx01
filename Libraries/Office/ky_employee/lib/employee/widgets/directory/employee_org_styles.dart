import 'package:flutter/material.dart';

import '../../models/employee_org_models.dart';

Color employeeOrgRelationshipStatusColor(EmployeeOrgRelationshipStatus status) {
  return switch (status) {
    EmployeeOrgRelationshipStatus.pending => const Color(0xFFB45309),
    EmployeeOrgRelationshipStatus.active => const Color(0xFF15803D),
    EmployeeOrgRelationshipStatus.archived => const Color(0xFF6B7280),
  };
}

Color employeeOrgRiskColor(EmployeeOrgRiskType type) {
  return switch (type) {
    EmployeeOrgRiskType.reportingLoop => const Color(0xFFB91C1C),
    EmployeeOrgRiskType.managerSpan => const Color(0xFFB45309),
    EmployeeOrgRiskType.watchlistReport => const Color(0xFF7C3AED),
    EmployeeOrgRiskType.successionGap => const Color(0xFF2563EB),
  };
}

IconData employeeOrgRelationshipTypeIcon(EmployeeOrgRelationshipType type) {
  return switch (type) {
    EmployeeOrgRelationshipType.dottedLineManager =>
      Icons.account_tree_outlined,
    EmployeeOrgRelationshipType.buddy => Icons.handshake_outlined,
    EmployeeOrgRelationshipType.backupApprover => Icons.verified_user_outlined,
    EmployeeOrgRelationshipType.matrixPartner => Icons.hub_outlined,
  };
}

IconData employeeOrgRiskIcon(EmployeeOrgRiskType type) {
  return switch (type) {
    EmployeeOrgRiskType.reportingLoop => Icons.sync_problem_outlined,
    EmployeeOrgRiskType.managerSpan => Icons.groups_2_outlined,
    EmployeeOrgRiskType.watchlistReport => Icons.warning_amber_outlined,
    EmployeeOrgRiskType.successionGap => Icons.manage_accounts_outlined,
  };
}
