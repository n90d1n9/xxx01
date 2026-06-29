import 'package:flutter/material.dart';

import '../../models/employee_assets_models.dart';

Color employeeAssetStatusColor(EmployeeAssetStatus status) {
  return switch (status) {
    EmployeeAssetStatus.active => const Color(0xFF15803D),
    EmployeeAssetStatus.provisioning => const Color(0xFF2563EB),
    EmployeeAssetStatus.dueReturn => const Color(0xFFB45309),
    EmployeeAssetStatus.returned => const Color(0xFF6B7280),
    EmployeeAssetStatus.lost => const Color(0xFFB91C1C),
  };
}

Color employeeAssetConditionColor(EmployeeAssetCondition condition) {
  return switch (condition) {
    EmployeeAssetCondition.newIssue => const Color(0xFF2563EB),
    EmployeeAssetCondition.good => const Color(0xFF15803D),
    EmployeeAssetCondition.repairNeeded => const Color(0xFFB45309),
    EmployeeAssetCondition.replacementDue => const Color(0xFFB91C1C),
  };
}

Color employeeAccessStatusColor(EmployeeAccessStatus status) {
  return switch (status) {
    EmployeeAccessStatus.requested => const Color(0xFF2563EB),
    EmployeeAccessStatus.active => const Color(0xFF15803D),
    EmployeeAccessStatus.reviewDue => const Color(0xFFB45309),
    EmployeeAccessStatus.revoked => const Color(0xFF6B7280),
  };
}

IconData employeeAssetTypeIcon(EmployeeAssetType type) {
  return switch (type) {
    EmployeeAssetType.laptop => Icons.laptop_mac_outlined,
    EmployeeAssetType.phone => Icons.phone_iphone_outlined,
    EmployeeAssetType.badge => Icons.badge_outlined,
    EmployeeAssetType.monitor => Icons.desktop_windows_outlined,
    EmployeeAssetType.software => Icons.apps_outlined,
  };
}

IconData employeeAccessScopeIcon(EmployeeAccessScope scope) {
  return switch (scope) {
    EmployeeAccessScope.productivity => Icons.workspaces_outlined,
    EmployeeAccessScope.engineering => Icons.code_outlined,
    EmployeeAccessScope.finance => Icons.account_balance_wallet_outlined,
    EmployeeAccessScope.hris => Icons.people_alt_outlined,
    EmployeeAccessScope.admin => Icons.admin_panel_settings_outlined,
  };
}
