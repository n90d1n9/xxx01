import 'package:flutter/material.dart';

import '../../models/employee_workflow_automation_models.dart';

Color employeeWorkflowAutomationStatusColor(
  EmployeeWorkflowAutomationStatus status,
) {
  return switch (status) {
    EmployeeWorkflowAutomationStatus.active => const Color(0xFF15803D),
    EmployeeWorkflowAutomationStatus.draft => const Color(0xFF1D4ED8),
    EmployeeWorkflowAutomationStatus.paused => const Color(0xFFB45309),
    EmployeeWorkflowAutomationStatus.failed => const Color(0xFFB91C1C),
  };
}

IconData employeeWorkflowAutomationStatusIcon(
  EmployeeWorkflowAutomationStatus status,
) {
  return switch (status) {
    EmployeeWorkflowAutomationStatus.active => Icons.play_circle_outline,
    EmployeeWorkflowAutomationStatus.draft => Icons.edit_note_outlined,
    EmployeeWorkflowAutomationStatus.paused => Icons.pause_circle_outline,
    EmployeeWorkflowAutomationStatus.failed => Icons.error_outline,
  };
}

Color employeeWorkflowAutomationRiskColor(EmployeeWorkflowAutomationRisk risk) {
  return switch (risk) {
    EmployeeWorkflowAutomationRisk.high => const Color(0xFFB91C1C),
    EmployeeWorkflowAutomationRisk.medium => const Color(0xFF1D4ED8),
    EmployeeWorkflowAutomationRisk.low => const Color(0xFF15803D),
  };
}

IconData employeeWorkflowAutomationTriggerIcon(
  EmployeeWorkflowAutomationTrigger trigger,
) {
  return switch (trigger) {
    EmployeeWorkflowAutomationTrigger.nextActionSignal =>
      Icons.auto_awesome_motion_outlined,
    EmployeeWorkflowAutomationTrigger.approvalPolicyIssue =>
      Icons.rule_folder_outlined,
    EmployeeWorkflowAutomationTrigger.approvalCoverageGap =>
      Icons.verified_user_outlined,
    EmployeeWorkflowAutomationTrigger.managerChangeBlocker =>
      Icons.manage_accounts_outlined,
    EmployeeWorkflowAutomationTrigger.jobHistoryEvidence =>
      Icons.history_edu_outlined,
    EmployeeWorkflowAutomationTrigger.recordActionApproved =>
      Icons.edit_note_outlined,
    EmployeeWorkflowAutomationTrigger.exitReadinessBlocker =>
      Icons.logout_outlined,
  };
}

IconData employeeWorkflowAutomationDeliveryIcon(
  EmployeeWorkflowAutomationDelivery delivery,
) {
  return switch (delivery) {
    EmployeeWorkflowAutomationDelivery.createWorkflowTask =>
      Icons.task_alt_outlined,
    EmployeeWorkflowAutomationDelivery.notifyOwner =>
      Icons.notifications_active_outlined,
    EmployeeWorkflowAutomationDelivery.addChecklistItem =>
      Icons.playlist_add_check_outlined,
    EmployeeWorkflowAutomationDelivery.blockQueue => Icons.block_outlined,
    EmployeeWorkflowAutomationDelivery.escalateOwner =>
      Icons.trending_up_outlined,
  };
}
