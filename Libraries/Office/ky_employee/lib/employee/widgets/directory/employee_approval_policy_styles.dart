import 'package:flutter/material.dart';

import '../../models/employee_approval_policy_models.dart';

Color employeeApprovalPolicyStatusColor(EmployeeApprovalPolicyStatus status) {
  return switch (status) {
    EmployeeApprovalPolicyStatus.active => const Color(0xFF15803D),
    EmployeeApprovalPolicyStatus.draft => const Color(0xFF1D4ED8),
    EmployeeApprovalPolicyStatus.reviewRequired => const Color(0xFFB45309),
    EmployeeApprovalPolicyStatus.suspended => const Color(0xFFB91C1C),
  };
}

IconData employeeApprovalPolicyStatusIcon(EmployeeApprovalPolicyStatus status) {
  return switch (status) {
    EmployeeApprovalPolicyStatus.active => Icons.check_circle_outline,
    EmployeeApprovalPolicyStatus.draft => Icons.edit_note_outlined,
    EmployeeApprovalPolicyStatus.reviewRequired => Icons.rate_review_outlined,
    EmployeeApprovalPolicyStatus.suspended => Icons.block_outlined,
  };
}

Color employeeApprovalPolicyRiskColor(EmployeeApprovalPolicyRisk risk) {
  return switch (risk) {
    EmployeeApprovalPolicyRisk.high => const Color(0xFFB91C1C),
    EmployeeApprovalPolicyRisk.medium => const Color(0xFF1D4ED8),
    EmployeeApprovalPolicyRisk.low => const Color(0xFF15803D),
  };
}

IconData employeeApprovalPolicyAreaIcon(EmployeeApprovalPolicyArea area) {
  return switch (area) {
    EmployeeApprovalPolicyArea.timeOff => Icons.event_available_outlined,
    EmployeeApprovalPolicyArea.expense => Icons.receipt_long_outlined,
    EmployeeApprovalPolicyArea.payroll => Icons.payments_outlined,
    EmployeeApprovalPolicyArea.access => Icons.admin_panel_settings_outlined,
    EmployeeApprovalPolicyArea.documents => Icons.folder_copy_outlined,
    EmployeeApprovalPolicyArea.performance => Icons.insights_outlined,
    EmployeeApprovalPolicyArea.jobChange => Icons.work_history_outlined,
    EmployeeApprovalPolicyArea.compensation =>
      Icons.account_balance_wallet_outlined,
  };
}

IconData employeeApprovalRouteIcon(EmployeeApprovalRoute route) {
  return switch (route) {
    EmployeeApprovalRoute.directManager => Icons.supervisor_account_outlined,
    EmployeeApprovalRoute.departmentHead => Icons.account_tree_outlined,
    EmployeeApprovalRoute.hrBusinessPartner => Icons.diversity_3_outlined,
    EmployeeApprovalRoute.financePartner => Icons.request_quote_outlined,
    EmployeeApprovalRoute.securityOwner => Icons.security_outlined,
    EmployeeApprovalRoute.executiveSponsor => Icons.workspace_premium_outlined,
    EmployeeApprovalRoute.customDelegate => Icons.person_pin_outlined,
  };
}

IconData employeeApprovalEscalationIcon(EmployeeApprovalEscalationMode mode) {
  return switch (mode) {
    EmployeeApprovalEscalationMode.autoEscalate => Icons.trending_up_outlined,
    EmployeeApprovalEscalationMode.notifyOnly =>
      Icons.notifications_active_outlined,
    EmployeeApprovalEscalationMode.holdQueue => Icons.pause_circle_outline,
    EmployeeApprovalEscalationMode.fallbackDelegate =>
      Icons.assignment_ind_outlined,
  };
}
