import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employee_directory_models.dart';
import '../models/employee_management_models.dart';
import '../models/employee_next_action_models.dart';
import '../models/employee_payslip_delivery_models.dart';
import '../models/employee_payroll_close_models.dart';
import '../models/employee_payroll_payment_models.dart';
import '../models/employee_profile_completeness_models.dart';
import 'employee_access_governance_provider.dart';
import 'employee_approval_coverage_provider.dart';
import 'employee_approval_policy_provider.dart';
import 'employee_assets_provider.dart';
import 'employee_audit_trail_provider.dart';
import 'employee_career_path_provider.dart';
import 'employee_case_log_provider.dart';
import 'employee_data_correction_governance_provider.dart';
import 'employee_data_correction_provider.dart';
import 'employee_data_quality_provider.dart';
import 'employee_development_provider.dart';
import 'employee_directory_provider.dart';
import 'employee_document_request_provider.dart';
import 'employee_engagement_provider.dart';
import 'employee_exit_readiness_provider.dart';
import 'employee_job_history_provider.dart';
import 'employee_leave_provider.dart';
import 'employee_lifecycle_task_provider.dart';
import 'employee_management_provider.dart';
import 'employee_manager_change_readiness_provider.dart';
import 'employee_mobility_readiness_provider.dart';
import 'employee_payslip_delivery_provider.dart';
import 'employee_payroll_close_provider.dart';
import 'employee_payroll_cutoff_provider.dart';
import 'employee_payroll_payment_provider.dart';
import 'employee_payroll_provider.dart';
import 'employee_payroll_run_provider.dart';
import 'employee_payroll_variance_provider.dart';
import 'employee_performance_provider.dart';
import 'employee_performance_support_provider.dart';
import 'employee_position_control_provider.dart';
import 'employee_profile_completeness_provider.dart';
import 'employee_record_action_provider.dart';
import 'employee_reimbursement_provider.dart';
import 'employee_skill_inventory_provider.dart';
import 'employee_succession_plan_provider.dart';
import 'employee_talent_calibration_provider.dart';
import 'employee_timekeeping_provider.dart';
import 'employee_timeline_provider.dart';
import 'employee_workflow_automation_provider.dart';

final employeeNextActionProfileProvider = Provider.family<
  EmployeeNextActionProfile?,
  String
>((ref, employeeId) {
  final asOfDate = ref.watch(employeeDirectoryAsOfDateProvider);
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) return null;

  final actions = <EmployeeNextAction>[];
  final today = _dateOnly(asOfDate);

  final snapshot = ref.watch(employeeManagementSnapshotProvider(employeeId));
  final completeness = ref.watch(
    employeeProfileCompletenessProvider(employeeId),
  );
  final dataQuality = ref.watch(employeeDataQualityProvider(employeeId));
  final dataCorrection = ref.watch(employeeDataCorrectionProvider(employeeId));
  final correctionGovernance = ref.watch(
    employeeDataCorrectionGovernanceProvider(employeeId),
  );
  final auditTrail = ref.watch(employeeAuditTrailProfileProvider(employeeId));
  final timeline = ref.watch(employeeTimelineProfileProvider(employeeId));
  final documentRequests = ref.watch(
    employeeDocumentRequestProfileProvider(employeeId),
  );
  final caseLog = ref.watch(employeeHrCaseLogProvider(employeeId));
  final approvalCoverage = ref.watch(
    employeeApprovalCoverageProvider(employeeId),
  );
  final approvalPolicy = ref.watch(
    employeeApprovalPolicyProfileProvider(employeeId),
  );
  final position = ref.watch(employeePositionControlProvider(employeeId));
  final managerChange = ref.watch(
    employeeManagerChangeReadinessProvider(employeeId),
  );
  final jobHistory = ref.watch(employeeJobHistoryProfileProvider(employeeId));
  final lifecycle = ref.watch(employeeLifecyclePlanProvider(employeeId));
  final recordActions = ref.watch(
    employeeRecordActionSummaryProvider(employeeId),
  );
  final leave = ref.watch(employeeLeaveProfileProvider(employeeId));
  final timekeeping = ref.watch(employeeTimekeepingProvider(employeeId));
  final reimbursement = ref.watch(
    employeeReimbursementProfileProvider(employeeId),
  );
  final payroll = ref.watch(employeePayrollProfileProvider(employeeId));
  final payrollCutoff = ref.watch(
    employeePayrollCutoffReconciliationProvider(employeeId),
  );
  final payrollVariance = ref.watch(
    employeePayrollVarianceProvider(employeeId),
  );
  final payrollRun = ref.watch(employeePayrollRunProvider(employeeId));
  final payrollPayment = ref.watch(employeePayrollPaymentProvider(employeeId));
  final payslipDelivery = ref.watch(
    employeePayslipDeliveryProvider(employeeId),
  );
  final payrollClose = ref.watch(employeePayrollCloseProvider(employeeId));
  final performance = ref.watch(employeePerformancePlanProvider(employeeId));
  final support = ref.watch(employeePerformanceSupportPlanProvider(employeeId));
  final career = ref.watch(employeeCareerPathProfileProvider(employeeId));
  final skills = ref.watch(employeeSkillInventoryProvider(employeeId));
  final talent = ref.watch(employeeTalentCalibrationProvider(employeeId));
  final succession = ref.watch(employeeSuccessionProfileProvider(employeeId));
  final mobility = ref.watch(employeeMobilityReadinessProvider(employeeId));
  final engagement = ref.watch(employeeEngagementPlanProvider(employeeId));
  final exitReadiness = ref.watch(employeeExitReadinessProvider(employeeId));
  final development = ref.watch(employeeDevelopmentPlanProvider(employeeId));
  final access = ref.watch(employeeAccessGovernanceProfileProvider(employeeId));
  final assets = ref.watch(employeeAssetAccessProfileProvider(employeeId));
  final automation = ref.watch(
    employeeWorkflowAutomationProfileProvider(employeeId),
  );

  if (snapshot != null) {
    _addSignal(
      actions,
      id: 'readiness-health',
      count: snapshot.health == EmployeeManagementHealth.actionRequired ? 1 : 0,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Review employee readiness',
      detail: snapshot.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Employee management',
      dueDate: today.add(const Duration(days: 1)),
      impactScore: 82,
    );
    _addSignal(
      actions,
      id: 'management-documents',
      count: snapshot.documentAttentionCount,
      area: EmployeeNextActionArea.records,
      priority: EmployeeNextActionPriority.high,
      status:
          snapshot.overdueDocumentCount > 0
              ? EmployeeNextActionStatus.blocked
              : EmployeeNextActionStatus.open,
      title: 'Clear employee document attention',
      detail:
          '${snapshot.documentAttentionCount} management document item(s) need attention.',
      owner: 'HR Operations',
      sourceLabel: 'Employee management',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 78,
    );
    _addSignal(
      actions,
      id: 'management-assets',
      count: snapshot.pendingAssetCount,
      area: EmployeeNextActionArea.security,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Finish pending asset provisioning',
      detail:
          '${snapshot.pendingAssetCount} asset or access item(s) are still provisioning.',
      owner: 'IT Operations',
      sourceLabel: 'Employee management',
      dueDate: today.add(const Duration(days: 5)),
      impactScore: 62,
    );
  }

  if (completeness != null) {
    for (final item in completeness.priorityItems
        .where((item) => item.isOpen)
        .take(4)) {
      actions.add(
        EmployeeNextAction(
          id: 'profile-${item.area.name}',
          area: _areaForCompleteness(item.area),
          priority: _priorityForCompleteness(item.status),
          status: _statusForCompleteness(item.status),
          title: item.area.label,
          detail: item.nextAction,
          owner: 'People Operations',
          sourceLabel: 'Profile completeness',
          dueDate: _dueDateForCompleteness(today, item.status),
          impactScore: _impactForCompleteness(item.status),
        ),
      );
    }
  }

  if (dataQuality != null) {
    _addSignal(
      actions,
      id: 'data-quality-overdue',
      count: dataQuality.overdueCount,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue data quality issue',
      detail: dataQuality.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Data quality',
      dueDate: today,
      impactScore: 88,
    );
    _addSignal(
      actions,
      id: 'data-quality-risk',
      count: dataQuality.overdueCount == 0 ? dataQuality.highRiskCount : 0,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Review high-risk employee data',
      detail: dataQuality.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Data quality',
      dueDate: today.add(const Duration(days: 1)),
      impactScore: 82,
    );
  }

  if (dataCorrection != null) {
    _addSignal(
      actions,
      id: 'data-correction-overdue',
      count: dataCorrection.overdueCount,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue data correction',
      detail: dataCorrection.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Data correction',
      dueDate: today,
      impactScore: 90,
    );
    _addSignal(
      actions,
      id: 'data-correction-approved',
      count:
          dataCorrection.overdueCount == 0 ? dataCorrection.approvedCount : 0,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.ready,
      title: 'Apply approved data correction',
      detail: dataCorrection.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Data correction',
      dueDate: today.add(const Duration(days: 1)),
      impactScore: 84,
    );
    _addSignal(
      actions,
      id: 'data-correction-review',
      count:
          dataCorrection.overdueCount == 0 && dataCorrection.approvedCount == 0
              ? dataCorrection.inReviewCount
              : 0,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Review data correction request',
      detail: dataCorrection.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Data correction',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 70,
    );
    _addSignal(
      actions,
      id: 'data-correction-submitted',
      count:
          dataCorrection.overdueCount == 0 &&
                  dataCorrection.approvedCount == 0 &&
                  dataCorrection.inReviewCount == 0
              ? dataCorrection.submittedCount
              : 0,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Start data correction review',
      detail: dataCorrection.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Data correction',
      dueDate: today.add(const Duration(days: 3)),
      impactScore: 64,
    );
  }

  if (correctionGovernance != null) {
    _addSignal(
      actions,
      id: 'correction-governance-blocked',
      count: correctionGovernance.blockedCount,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear blocked correction governance',
      detail: correctionGovernance.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Correction governance',
      dueDate: today,
      impactScore: 92,
    );
    _addSignal(
      actions,
      id: 'correction-governance-warning',
      count:
          correctionGovernance.blockedCount == 0
              ? correctionGovernance.warningCount
              : 0,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Review correction governance warnings',
      detail: correctionGovernance.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Correction governance',
      dueDate: today.add(const Duration(days: 1)),
      impactScore: 74,
    );
  }

  if (auditTrail != null) {
    _addSignal(
      actions,
      id: 'audit-escalated',
      count: auditTrail.escalatedCount,
      area: EmployeeNextActionArea.security,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve escalated audit event',
      detail: auditTrail.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Audit trail',
      dueDate: today,
      impactScore: 100,
    );
    _addSignal(
      actions,
      id: 'audit-review',
      count:
          auditTrail.escalatedCount == 0 ? auditTrail.reviewRequiredCount : 0,
      area: EmployeeNextActionArea.security,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Review audit events',
      detail: auditTrail.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Audit trail',
      dueDate: today.add(const Duration(days: 1)),
      impactScore: 82,
    );
  }

  if (timeline != null) {
    _addSignal(
      actions,
      id: 'timeline-overdue',
      count: timeline.overdueCount,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue timeline follow-up',
      detail: timeline.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Employee timeline',
      dueDate: today,
      impactScore: 80,
    );
    _addSignal(
      actions,
      id: 'timeline-follow-up',
      count: timeline.overdueCount == 0 ? timeline.openFollowUpCount : 0,
      area: EmployeeNextActionArea.profile,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.dueSoon,
      title: 'Complete timeline follow-up',
      detail: timeline.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Employee timeline',
      dueDate: today.add(const Duration(days: 5)),
      impactScore: 58,
    );
  }

  if (documentRequests != null) {
    _addSignal(
      actions,
      id: 'document-request-overdue',
      count: documentRequests.overdueCount,
      area: EmployeeNextActionArea.records,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue document request',
      detail: documentRequests.nextAction,
      owner: 'HR Operations',
      sourceLabel: 'Document requests',
      dueDate: today,
      impactScore: 84,
    );
    _addSignal(
      actions,
      id: 'document-request-open',
      count:
          documentRequests.overdueCount == 0
              ? documentRequests.requestedCount +
                  documentRequests.reviewingCount +
                  documentRequests.issuedPendingAckCount
              : 0,
      area: EmployeeNextActionArea.records,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Move document request forward',
      detail: documentRequests.nextAction,
      owner: 'HR Operations',
      sourceLabel: 'Document requests',
      dueDate: today.add(const Duration(days: 3)),
      impactScore: 66,
    );
  }

  if (caseLog != null) {
    _addSignal(
      actions,
      id: 'case-log-overdue',
      count: caseLog.overdueFollowUpCount,
      area: EmployeeNextActionArea.records,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Follow up overdue HR case',
      detail: caseLog.nextAction,
      owner: 'HR Business Partner',
      sourceLabel: 'HR case log',
      dueDate: today,
      impactScore: 86,
    );
    _addSignal(
      actions,
      id: 'case-log-priority',
      count: caseLog.overdueFollowUpCount == 0 ? caseLog.highPriorityCount : 0,
      area: EmployeeNextActionArea.records,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Prioritize high-risk HR case',
      detail: caseLog.nextAction,
      owner: 'HR Business Partner',
      sourceLabel: 'HR case log',
      dueDate: today.add(const Duration(days: 1)),
      impactScore: 78,
    );
  }

  if (approvalCoverage != null) {
    _addSignal(
      actions,
      id: 'approval-coverage-blocked',
      count: approvalCoverage.blockedCount,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear blocked approval coverage',
      detail: approvalCoverage.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Approval coverage',
      dueDate: today,
      impactScore: 92,
    );
    _addSignal(
      actions,
      id: 'approval-coverage-expired',
      count:
          approvalCoverage.blockedCount == 0
              ? approvalCoverage.expiredCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Renew expired approval coverage',
      detail: approvalCoverage.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Approval coverage',
      dueDate: today,
      impactScore: 82,
    );
    _addSignal(
      actions,
      id: 'approval-coverage-pending',
      count:
          approvalCoverage.blockedCount == 0 &&
                  approvalCoverage.expiredCount == 0
              ? approvalCoverage.pendingCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Activate approval coverage',
      detail: approvalCoverage.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Approval coverage',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 68,
    );
    _addSignal(
      actions,
      id: 'approval-coverage-expiring',
      count:
          approvalCoverage.blockedCount == 0 &&
                  approvalCoverage.expiredCount == 0 &&
                  approvalCoverage.pendingCount == 0
              ? approvalCoverage.expiringSoonCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.dueSoon,
      title: 'Review expiring approval coverage',
      detail: approvalCoverage.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Approval coverage',
      dueDate: today.add(const Duration(days: 7)),
      impactScore: 58,
    );
  }

  if (approvalPolicy != null) {
    _addSignal(
      actions,
      id: 'approval-policy-suspended',
      count: approvalPolicy.suspendedCount,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve suspended approval policy',
      detail: approvalPolicy.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Approval policy',
      dueDate: today,
      impactScore: 92,
    );
    _addSignal(
      actions,
      id: 'approval-policy-expired',
      count:
          approvalPolicy.suspendedCount == 0 ? approvalPolicy.expiredCount : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Renew expired approval policy',
      detail: approvalPolicy.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Approval policy',
      dueDate: today,
      impactScore: 84,
    );
    _addSignal(
      actions,
      id: 'approval-policy-review',
      count:
          approvalPolicy.suspendedCount == 0 && approvalPolicy.expiredCount == 0
              ? approvalPolicy.reviewRequiredCount + approvalPolicy.draftCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Review approval policy routing',
      detail: approvalPolicy.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Approval policy',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 76,
    );
    _addSignal(
      actions,
      id: 'approval-policy-expiring',
      count:
          approvalPolicy.suspendedCount == 0 &&
                  approvalPolicy.expiredCount == 0 &&
                  approvalPolicy.reviewRequiredCount == 0 &&
                  approvalPolicy.draftCount == 0
              ? approvalPolicy.expiringSoonCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.dueSoon,
      title: 'Refresh expiring approval policy',
      detail: approvalPolicy.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Approval policy',
      dueDate: today.add(const Duration(days: 7)),
      impactScore: 60,
    );
  }

  if (automation != null) {
    _addSignal(
      actions,
      id: 'workflow-automation-failed',
      count: automation.failedCount,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Repair workflow automation hook',
      detail: automation.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Workflow automation',
      dueDate: today,
      impactScore: 94,
    );
    _addSignal(
      actions,
      id: 'workflow-automation-due',
      count: automation.failedCount == 0 ? automation.dueCount : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Run due workflow automation hook',
      detail: automation.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Workflow automation',
      dueDate: today.add(const Duration(days: 1)),
      impactScore: 78,
    );
    _addSignal(
      actions,
      id: 'workflow-automation-paused',
      count:
          automation.failedCount == 0 && automation.dueCount == 0
              ? automation.pausedCount + automation.draftCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Review workflow automation hook',
      detail: automation.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Workflow automation',
      dueDate: today.add(const Duration(days: 3)),
      impactScore: 62,
    );
  }

  if (managerChange != null) {
    _addSignal(
      actions,
      id: 'manager-change-target',
      count: managerChange.targetDiffers ? 0 : 1,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Choose target manager',
      detail: managerChange.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Manager change readiness',
      dueDate: today,
      impactScore: 88,
    );
    _addSignal(
      actions,
      id: 'manager-change-blocked',
      count: managerChange.targetDiffers ? managerChange.blockedCount : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear blocked manager change readiness',
      detail: managerChange.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Manager change readiness',
      dueDate: today,
      impactScore: 94,
    );
    _addSignal(
      actions,
      id: 'manager-change-overdue',
      count:
          managerChange.targetDiffers && managerChange.blockedCount == 0
              ? managerChange.overdueCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue manager change item',
      detail: managerChange.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Manager change readiness',
      dueDate: today,
      impactScore: 82,
    );
    _addSignal(
      actions,
      id: 'manager-change-effective-soon',
      count:
          managerChange.targetDiffers &&
                  managerChange.blockedCount == 0 &&
                  managerChange.overdueCount == 0 &&
                  managerChange.isEffectiveSoon
              ? managerChange.attentionCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.dueSoon,
      title: 'Finalize manager change readiness',
      detail: managerChange.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Manager change readiness',
      dueDate: managerChange.effectiveDate,
      impactScore: 76,
    );
  }

  if (position != null) {
    _addSignal(
      actions,
      id: 'position-control-budget',
      count: position.position.isOverBudget ? 1 : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve position budget variance',
      detail: position.nextAction,
      owner: position.position.hiringManager,
      sourceLabel: 'Position control',
      dueDate: today,
      impactScore: 86,
    );
    _addSignal(
      actions,
      id: 'position-control-vacancy',
      count:
          position.position.isOverBudget
              ? 0
              : position.position.isFrozen || position.position.isVacant
              ? 1
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Review position staffing status',
      detail: position.nextAction,
      owner: position.position.hiringManager,
      sourceLabel: 'Position control',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 76,
    );
    _addSignal(
      actions,
      id: 'position-control-overdue-req',
      count:
          position.position.isOverBudget ||
                  position.position.isFrozen ||
                  position.position.isVacant
              ? 0
              : position.overdueRequisitionCount,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue position requisition',
      detail: position.nextAction,
      owner: position.position.hiringManager,
      sourceLabel: 'Position control',
      dueDate: today,
      impactScore: 78,
    );
    _addSignal(
      actions,
      id: 'position-control-approval',
      count:
          position.position.isOverBudget ||
                  position.position.isFrozen ||
                  position.position.isVacant ||
                  position.overdueRequisitionCount > 0
              ? 0
              : position.pendingApprovalCount,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Approve position requisition',
      detail: position.nextAction,
      owner: position.position.hiringManager,
      sourceLabel: 'Position control',
      dueDate: today.add(const Duration(days: 3)),
      impactScore: 62,
    );
  }

  if (jobHistory != null) {
    _addSignal(
      actions,
      id: 'job-history-overdue',
      count: jobHistory.overdueCount,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue job history',
      detail: jobHistory.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Job history',
      dueDate: today,
      impactScore: 84,
    );
    _addSignal(
      actions,
      id: 'job-history-evidence',
      count: jobHistory.overdueCount == 0 ? jobHistory.pendingEvidenceCount : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Attach job history evidence',
      detail: jobHistory.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Job history',
      dueDate: today.add(const Duration(days: 1)),
      impactScore: 78,
    );
    _addSignal(
      actions,
      id: 'job-history-scheduled',
      count:
          jobHistory.overdueCount == 0 && jobHistory.pendingEvidenceCount == 0
              ? jobHistory.scheduledSoonCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.dueSoon,
      title: 'Validate scheduled job history',
      detail: jobHistory.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Job history',
      dueDate: jobHistory.nextScheduledEvent?.effectiveDate,
      impactScore: 64,
    );
  }

  if (lifecycle != null) {
    _addSignal(
      actions,
      id: 'lifecycle-blocked',
      count: lifecycle.blockedCount,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear blocked lifecycle task',
      detail: lifecycle.nextAction,
      owner: 'HR Operations',
      sourceLabel: 'Lifecycle tasks',
      dueDate: today,
      impactScore: 94,
    );
    _addSignal(
      actions,
      id: 'lifecycle-overdue',
      count: lifecycle.blockedCount == 0 ? lifecycle.overdueCount : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue lifecycle task',
      detail: lifecycle.nextAction,
      owner: 'HR Operations',
      sourceLabel: 'Lifecycle tasks',
      dueDate: today,
      impactScore: 84,
    );
  }

  if (exitReadiness != null) {
    _addSignal(
      actions,
      id: 'exit-readiness-blocked',
      count: exitReadiness.blockedCount,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear blocked exit readiness',
      detail: exitReadiness.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Exit readiness',
      dueDate: today,
      impactScore: 98,
    );
    _addSignal(
      actions,
      id: 'exit-readiness-overdue',
      count: exitReadiness.blockedCount == 0 ? exitReadiness.overdueCount : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue exit clearance',
      detail: exitReadiness.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Exit readiness',
      dueDate: today,
      impactScore: 88,
    );
    _addSignal(
      actions,
      id: 'exit-readiness-imminent',
      count:
          exitReadiness.blockedCount == 0 &&
                  exitReadiness.overdueCount == 0 &&
                  exitReadiness.isExitImminent
              ? exitReadiness.attentionCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.dueSoon,
      title: 'Finalize exit readiness',
      detail: exitReadiness.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Exit readiness',
      dueDate: exitReadiness.finalWorkday,
      impactScore: 82,
    );
  }

  _addSignal(
    actions,
    id: 'record-change-approved',
    count: recordActions.approvedCount,
    area: EmployeeNextActionArea.work,
    priority: EmployeeNextActionPriority.high,
    status: EmployeeNextActionStatus.ready,
    title: 'Apply approved employee record change',
    detail: recordActions.nextAction,
    owner: 'People Operations',
    sourceLabel: 'Record actions',
    dueDate: today.add(const Duration(days: 1)),
    impactScore: 76,
  );
  _addSignal(
    actions,
    id: 'record-change-submitted',
    count: recordActions.submittedCount,
    area: EmployeeNextActionArea.work,
    priority: EmployeeNextActionPriority.medium,
    status: EmployeeNextActionStatus.open,
    title: 'Review submitted employee record change',
    detail: recordActions.nextAction,
    owner: 'People Operations',
    sourceLabel: 'Record actions',
    dueDate: today.add(const Duration(days: 3)),
    impactScore: 60,
  );

  if (leave != null) {
    _addSignal(
      actions,
      id: 'leave-attention',
      count: leave.attentionCount,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Review leave and absence signal',
      detail: leave.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Leave and absence',
      dueDate: today.add(const Duration(days: 3)),
      impactScore: 58,
    );
  }

  if (timekeeping != null) {
    _addSignal(
      actions,
      id: 'timekeeping-payroll-blocker',
      count: timekeeping.payrollBlockingExceptionCount,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve payroll-blocking time exception',
      detail: timekeeping.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Timekeeping',
      dueDate: today,
      impactScore: 92,
    );
    _addSignal(
      actions,
      id: 'timekeeping-overdue-exception',
      count:
          timekeeping.payrollBlockingExceptionCount == 0
              ? timekeeping.overdueExceptionCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Review overdue timekeeping exception',
      detail: timekeeping.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Timekeeping',
      dueDate: today,
      impactScore: 82,
    );
    _addSignal(
      actions,
      id: 'timekeeping-rejected-entry',
      count:
          timekeeping.payrollBlockingExceptionCount == 0 &&
                  timekeeping.overdueExceptionCount == 0
              ? timekeeping.rejectedEntryCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Correct rejected timesheet entry',
      detail: timekeeping.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Timekeeping',
      dueDate: today.add(const Duration(days: 1)),
      impactScore: 74,
    );
    _addSignal(
      actions,
      id: 'timekeeping-submitted-entry',
      count:
          timekeeping.payrollBlockingExceptionCount == 0 &&
                  timekeeping.overdueExceptionCount == 0 &&
                  timekeeping.rejectedEntryCount == 0
              ? timekeeping.submittedEntryCount
              : 0,
      area: EmployeeNextActionArea.work,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Approve submitted timesheet entry',
      detail: timekeeping.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Timekeeping',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 62,
    );
  }

  if (reimbursement != null) {
    _addSignal(
      actions,
      id: 'expense-attention',
      count: reimbursement.attentionCount,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Move expense request forward',
      detail: reimbursement.nextAction,
      owner: 'Payroll',
      sourceLabel: 'Expenses',
      dueDate: today.add(const Duration(days: 4)),
      impactScore: 56,
    );
  }

  if (payroll != null) {
    _addSignal(
      actions,
      id: 'payroll-attention',
      count: payroll.attentionCount,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Resolve payroll setup issue',
      detail: payroll.nextAction,
      owner: 'Payroll',
      sourceLabel: 'Payroll',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 80,
    );
  }

  if (payrollCutoff != null) {
    _addSignal(
      actions,
      id: 'payroll-cutoff-blockers',
      count: payrollCutoff.blockingCount,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear payroll cutoff blockers',
      detail: payrollCutoff.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll cutoff',
      dueDate: payrollCutoff.cutoffDate,
      impactScore: 94,
    );
    _addSignal(
      actions,
      id: 'payroll-cutoff-warnings',
      count:
          payrollCutoff.blockingCount == 0 ? payrollCutoff.openWarningCount : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Review payroll cutoff warnings',
      detail: payrollCutoff.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll cutoff',
      dueDate: payrollCutoff.cutoffDate,
      impactScore: 66,
    );
    _addSignal(
      actions,
      id: 'payroll-cutoff-signoff',
      count:
          payrollCutoff.blockingCount == 0 &&
                  payrollCutoff.openWarningCount == 0 &&
                  payrollCutoff.signoff == null
              ? 1
              : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.ready,
      title: 'Sign off payroll cutoff',
      detail: payrollCutoff.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll cutoff',
      dueDate: payrollCutoff.cutoffDate,
      impactScore: 78,
    );
  }

  if (payrollVariance != null) {
    _addSignal(
      actions,
      id: 'payroll-variance-risk',
      count: payrollVariance.varianceRiskCount,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Review high-risk payroll variance',
      detail: payrollVariance.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll variance',
      dueDate: payrollVariance.periodEnd,
      impactScore: 86,
    );
    _addSignal(
      actions,
      id: 'payroll-variance-approval',
      count:
          payrollVariance.varianceRiskCount == 0
              ? payrollVariance.approvalRequiredCount
              : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Approve payroll variance item',
      detail: payrollVariance.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll variance',
      dueDate: payrollVariance.periodEnd,
      impactScore: 64,
    );
    _addSignal(
      actions,
      id: 'payroll-variance-tolerance',
      count:
          payrollVariance.varianceRiskCount == 0 &&
                  payrollVariance.approvalRequiredCount == 0 &&
                  !payrollVariance.isWithinTolerance
              ? 1
              : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Review payroll variance tolerance',
      detail: payrollVariance.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll variance',
      dueDate: payrollVariance.periodEnd,
      impactScore: 58,
    );
  }

  if (payrollRun != null) {
    _addSignal(
      actions,
      id: 'payroll-run-blockers',
      count: payrollRun.blockerCount,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear payroll run blockers',
      detail: payrollRun.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll run',
      dueDate: payrollRun.payDate,
      impactScore: 96,
    );
    _addSignal(
      actions,
      id: 'payroll-run-review',
      count:
          payrollRun.blockerCount == 0 &&
                  !payrollRun.canExport &&
                  payrollRun.exportBatchId.isEmpty
              ? 1
              : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Review payroll run preview',
      detail: payrollRun.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll run',
      dueDate: payrollRun.payDate,
      impactScore: 76,
    );
    _addSignal(
      actions,
      id: 'payroll-run-export',
      count: payrollRun.canExport ? 1 : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.ready,
      title: 'Export payroll run',
      detail: payrollRun.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll run',
      dueDate: payrollRun.payDate,
      impactScore: 82,
    );
  }

  if (payrollPayment != null) {
    _addSignal(
      actions,
      id: 'payroll-payment-blockers',
      count:
          payrollPayment.status == EmployeePayrollPaymentStatus.blocked
              ? payrollPayment.attentionCount
              : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear payroll payment blocker',
      detail: payrollPayment.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll payment',
      dueDate: payrollPayment.payDate,
      impactScore: 88,
    );
    _addSignal(
      actions,
      id: 'payroll-payment-schedule',
      count: payrollPayment.canSchedule ? 1 : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.ready,
      title: 'Schedule payroll payment',
      detail: payrollPayment.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll payment',
      dueDate: payrollPayment.payDate,
      impactScore: 82,
    );
    _addSignal(
      actions,
      id: 'payroll-payment-settle',
      count:
          payrollPayment.status == EmployeePayrollPaymentStatus.scheduled ||
                  payrollPayment.status == EmployeePayrollPaymentStatus.held
              ? 1
              : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status:
          payrollPayment.status == EmployeePayrollPaymentStatus.held
              ? EmployeeNextActionStatus.open
              : EmployeeNextActionStatus.ready,
      title:
          payrollPayment.status == EmployeePayrollPaymentStatus.held
              ? 'Resolve payroll payment hold'
              : 'Confirm payroll payment settlement',
      detail: payrollPayment.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payroll payment',
      dueDate: payrollPayment.payDate,
      impactScore: 80,
    );
  }

  if (payslipDelivery != null) {
    _addSignal(
      actions,
      id: 'payslip-delivery-blockers',
      count:
          payslipDelivery.status == EmployeePayslipDeliveryStatus.blocked ||
                  payslipDelivery.status ==
                      EmployeePayslipDeliveryStatus.suppressed
              ? payslipDelivery.attentionCount
              : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status:
          payslipDelivery.status == EmployeePayslipDeliveryStatus.suppressed
              ? EmployeeNextActionStatus.open
              : EmployeeNextActionStatus.blocked,
      title: 'Clear payslip delivery blocker',
      detail: payslipDelivery.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payslip delivery',
      dueDate: payslipDelivery.payDate,
      impactScore: 74,
    );
    _addSignal(
      actions,
      id: 'payslip-delivery-release',
      count: payslipDelivery.canRelease ? 1 : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.ready,
      title: 'Release employee payslip',
      detail: payslipDelivery.nextAction,
      owner: 'Payroll Operations',
      sourceLabel: 'Payslip delivery',
      dueDate: payslipDelivery.payDate,
      impactScore: 78,
    );
  }

  if (payrollClose != null) {
    _addSignal(
      actions,
      id: 'payroll-close-blockers',
      count:
          payrollClose.status == EmployeePayrollCloseStatus.blocked
              ? payrollClose.attentionCount
              : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear payroll close blocker',
      detail: payrollClose.nextAction,
      owner: 'Payroll Accounting',
      sourceLabel: 'Payroll close',
      dueDate: payrollClose.payDate,
      impactScore: 84,
    );
    _addSignal(
      actions,
      id: 'payroll-close-post',
      count: payrollClose.canPost ? 1 : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.ready,
      title: 'Post payroll accounting journal',
      detail: payrollClose.nextAction,
      owner: 'Payroll Accounting',
      sourceLabel: 'Payroll close',
      dueDate: payrollClose.payDate,
      impactScore: 80,
    );
    _addSignal(
      actions,
      id: 'payroll-close-period',
      count: payrollClose.canClose ? 1 : 0,
      area: EmployeeNextActionArea.pay,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.ready,
      title: 'Close payroll period',
      detail: payrollClose.nextAction,
      owner: 'Payroll Accounting',
      sourceLabel: 'Payroll close',
      dueDate: payrollClose.payDate,
      impactScore: 82,
    );
  }

  if (performance != null) {
    _addSignal(
      actions,
      id: 'performance-overdue',
      count: performance.overdueGoalCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue performance goal',
      detail: performance.nextAction,
      owner: performance.manager,
      sourceLabel: 'Performance',
      dueDate: today,
      impactScore: 78,
    );
    _addSignal(
      actions,
      id: 'performance-at-risk',
      count:
          performance.overdueGoalCount == 0 ? performance.atRiskGoalCount : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Coach at-risk performance goal',
      detail: performance.nextAction,
      owner: performance.manager,
      sourceLabel: 'Performance',
      dueDate: today.add(const Duration(days: 5)),
      impactScore: 64,
    );
  }

  if (support != null) {
    _addSignal(
      actions,
      id: 'performance-support-escalated',
      count: support.isEscalated ? 1 : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve escalated support plan',
      detail: support.nextAction,
      owner: support.hrPartner,
      sourceLabel: 'Performance support',
      dueDate: today,
      impactScore: 94,
    );
    _addSignal(
      actions,
      id: 'performance-support-blocked',
      count: support.isEscalated ? 0 : support.blockedCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear blocked support milestone',
      detail: support.nextAction,
      owner: support.hrPartner,
      sourceLabel: 'Performance support',
      dueDate: today,
      impactScore: 90,
    );
    _addSignal(
      actions,
      id: 'performance-support-overdue',
      count:
          support.isEscalated || support.blockedCount > 0
              ? 0
              : support.overdueCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Complete overdue support milestone',
      detail: support.nextAction,
      owner: support.hrPartner,
      sourceLabel: 'Performance support',
      dueDate: today,
      impactScore: 82,
    );
    _addSignal(
      actions,
      id: 'performance-support-review',
      count:
          support.isEscalated ||
                  support.blockedCount > 0 ||
                  support.overdueCount > 0
              ? 0
              : support.isReviewDue
              ? 1
              : support.highRiskOpenCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Review performance support plan',
      detail: support.nextAction,
      owner: support.hrPartner,
      sourceLabel: 'Performance support',
      dueDate: today.add(const Duration(days: 3)),
      impactScore: 64,
    );
  }

  if (career != null) {
    _addSignal(
      actions,
      id: 'career-attention',
      count: career.attentionCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Review career path signal',
      detail: career.nextAction,
      owner: 'Talent Management',
      sourceLabel: 'Career path',
      dueDate: today.add(const Duration(days: 7)),
      impactScore: 56,
    );
  }

  if (skills != null) {
    _addSignal(
      actions,
      id: 'skills-critical-gap',
      count: skills.criticalGapCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.high,
      status:
          skills.reviewDueCount > 0
              ? EmployeeNextActionStatus.blocked
              : EmployeeNextActionStatus.open,
      title: 'Close critical skill gap',
      detail: skills.nextAction,
      owner: 'Talent Enablement',
      sourceLabel: 'Skills inventory',
      dueDate:
          skills.reviewDueCount > 0
              ? today
              : today.add(const Duration(days: 2)),
      impactScore: 84,
    );
    _addSignal(
      actions,
      id: 'skills-review-due',
      count: skills.criticalGapCount == 0 ? skills.reviewDueCount : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.blocked,
      title: 'Review skill evidence',
      detail: skills.nextAction,
      owner: 'Talent Enablement',
      sourceLabel: 'Skills inventory',
      dueDate: today,
      impactScore: 70,
    );
    _addSignal(
      actions,
      id: 'skills-evidence-due',
      count:
          skills.criticalGapCount == 0 && skills.reviewDueCount == 0
              ? skills.evidenceDueCount
              : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Collect skill evidence',
      detail: skills.nextAction,
      owner: 'Talent Enablement',
      sourceLabel: 'Skills inventory',
      dueDate: today.add(const Duration(days: 5)),
      impactScore: 60,
    );
  }

  if (talent != null) {
    _addSignal(
      actions,
      id: 'talent-calibration-disputed',
      count: talent.isDisputed ? 1 : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve disputed talent calibration',
      detail: talent.nextAction,
      owner: talent.calibrator,
      sourceLabel: 'Talent calibration',
      dueDate: today,
      impactScore: 88,
    );
    _addSignal(
      actions,
      id: 'talent-calibration-overdue',
      count: talent.isDisputed ? 0 : talent.overdueFollowUpCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Complete calibration follow-up',
      detail: talent.nextAction,
      owner: talent.calibrator,
      sourceLabel: 'Talent calibration',
      dueDate: today,
      impactScore: 82,
    );
    _addSignal(
      actions,
      id: 'talent-calibration-risk',
      count:
          talent.isDisputed || talent.overdueFollowUpCount > 0
              ? 0
              : talent.isHighRisk
              ? 1
              : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Review high-risk talent calibration',
      detail: talent.nextAction,
      owner: talent.calibrator,
      sourceLabel: 'Talent calibration',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 74,
    );
    _addSignal(
      actions,
      id: 'talent-calibration-review',
      count:
          talent.isDisputed ||
                  talent.overdueFollowUpCount > 0 ||
                  talent.isHighRisk
              ? 0
              : talent.isReviewDue
              ? 1
              : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Run talent calibration review',
      detail: talent.nextAction,
      owner: talent.calibrator,
      sourceLabel: 'Talent calibration',
      dueDate: today.add(const Duration(days: 4)),
      impactScore: 58,
    );
  }

  if (succession != null) {
    _addSignal(
      actions,
      id: 'succession-gap',
      count: succession.coverageGapCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Close succession coverage gap',
      detail: succession.nextAction,
      owner: succession.coverageOwner,
      sourceLabel: 'Succession coverage',
      dueDate: today,
      impactScore: 92,
    );
    _addSignal(
      actions,
      id: 'succession-attention',
      count:
          succession.coverageGapCount == 0
              ? succession.overdueCount + succession.highRiskCount
              : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'De-risk successor bench',
      detail: succession.nextAction,
      owner: succession.coverageOwner,
      sourceLabel: 'Succession coverage',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 80,
    );
    _addSignal(
      actions,
      id: 'succession-review',
      count:
          succession.coverageGapCount == 0 &&
                  succession.overdueCount == 0 &&
                  succession.highRiskCount == 0 &&
                  succession.isReviewDue
              ? 1
              : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Run succession review',
      detail: succession.nextAction,
      owner: succession.coverageOwner,
      sourceLabel: 'Succession coverage',
      dueDate: today.add(const Duration(days: 3)),
      impactScore: 62,
    );
  }

  if (mobility != null) {
    _addSignal(
      actions,
      id: 'mobility-blocked',
      count: mobility.blockedCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Clear blocked mobility readiness',
      detail: mobility.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Mobility readiness',
      dueDate: today,
      impactScore: 94,
    );
    _addSignal(
      actions,
      id: 'mobility-overdue',
      count: mobility.blockedCount == 0 ? mobility.overdueCount : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue mobility gate',
      detail: mobility.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Mobility readiness',
      dueDate: today,
      impactScore: 84,
    );
    _addSignal(
      actions,
      id: 'mobility-effective-soon',
      count:
          mobility.blockedCount == 0 &&
                  mobility.overdueCount == 0 &&
                  mobility.isEffectiveSoon
              ? mobility.attentionCount
              : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.dueSoon,
      title: 'Finalize mobility readiness',
      detail: mobility.nextAction,
      owner: 'People Operations',
      sourceLabel: 'Mobility readiness',
      dueDate: mobility.effectiveDate,
      impactScore: 76,
    );
  }

  if (engagement != null) {
    _addSignal(
      actions,
      id: 'engagement-critical',
      count: engagement.criticalSignalCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Prioritize retention signal',
      detail: engagement.nextAction,
      owner: 'HR Business Partner',
      sourceLabel: 'Engagement',
      dueDate: today.add(const Duration(days: 1)),
      impactScore: 80,
    );
    _addSignal(
      actions,
      id: 'engagement-overdue',
      count:
          engagement.criticalSignalCount == 0
              ? engagement.overdueSignalCount
              : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.dueSoon,
      title: 'Follow up retention action',
      detail: engagement.nextAction,
      owner: 'HR Business Partner',
      sourceLabel: 'Engagement',
      dueDate: today.add(const Duration(days: 3)),
      impactScore: 62,
    );
  }

  if (development != null) {
    _addSignal(
      actions,
      id: 'development-certification',
      count: development.certificationRiskCount,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Resolve certification risk',
      detail: development.nextAction,
      owner: 'Learning and Development',
      sourceLabel: 'Development',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 74,
    );
    _addSignal(
      actions,
      id: 'development-learning',
      count:
          development.certificationRiskCount == 0
              ? development.learningDueCount + development.skillGapCount
              : 0,
      area: EmployeeNextActionArea.growth,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Advance development plan',
      detail: development.nextAction,
      owner: 'Learning and Development',
      sourceLabel: 'Development',
      dueDate: today.add(const Duration(days: 7)),
      impactScore: 58,
    );
  }

  if (access != null) {
    _addSignal(
      actions,
      id: 'access-overdue',
      count: access.overdueCount,
      area: EmployeeNextActionArea.security,
      priority: EmployeeNextActionPriority.critical,
      status: EmployeeNextActionStatus.blocked,
      title: 'Resolve overdue access governance',
      detail: access.nextAction,
      owner: 'IT Security',
      sourceLabel: 'Access governance',
      dueDate: today,
      impactScore: 96,
    );
    _addSignal(
      actions,
      id: 'access-attention',
      count: access.overdueCount == 0 ? access.attentionCount : 0,
      area: EmployeeNextActionArea.security,
      priority: EmployeeNextActionPriority.high,
      status: EmployeeNextActionStatus.open,
      title: 'Review access governance',
      detail: access.nextAction,
      owner: 'IT Security',
      sourceLabel: 'Access governance',
      dueDate: today.add(const Duration(days: 2)),
      impactScore: 78,
    );
  }

  if (assets != null) {
    _addSignal(
      actions,
      id: 'assets-attention',
      count: assets.attentionCount,
      area: EmployeeNextActionArea.security,
      priority: EmployeeNextActionPriority.medium,
      status: EmployeeNextActionStatus.open,
      title: 'Review asset and access inventory',
      detail: assets.nextAction,
      owner: 'IT Operations',
      sourceLabel: 'Assets and access',
      dueDate: today.add(const Duration(days: 5)),
      impactScore: 60,
    );
  }

  return EmployeeNextActionProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    actions: actions,
  );
});

void _addSignal(
  List<EmployeeNextAction> actions, {
  required String id,
  required int count,
  required EmployeeNextActionArea area,
  required EmployeeNextActionPriority priority,
  required EmployeeNextActionStatus status,
  required String title,
  required String detail,
  required String owner,
  required String sourceLabel,
  required DateTime? dueDate,
  required int impactScore,
}) {
  if (count <= 0) return;
  actions.add(
    EmployeeNextAction(
      id: id,
      area: area,
      priority: priority,
      status: status,
      title: title,
      detail: detail,
      owner: owner,
      sourceLabel: sourceLabel,
      dueDate: dueDate,
      impactScore: impactScore,
    ),
  );
}

EmployeeNextActionArea _areaForCompleteness(
  EmployeeProfileCompletenessArea area,
) {
  return switch (area) {
    EmployeeProfileCompletenessArea.personalRecords ||
    EmployeeProfileCompletenessArea.documentVault ||
    EmployeeProfileCompletenessArea.workAuthorization ||
    EmployeeProfileCompletenessArea
        .compliance => EmployeeNextActionArea.records,
    EmployeeProfileCompletenessArea.jobAssignment ||
    EmployeeProfileCompletenessArea.reporting ||
    EmployeeProfileCompletenessArea.schedule => EmployeeNextActionArea.work,
    EmployeeProfileCompletenessArea.payroll ||
    EmployeeProfileCompletenessArea.benefits => EmployeeNextActionArea.pay,
    EmployeeProfileCompletenessArea.assetsAccess =>
      EmployeeNextActionArea.security,
  };
}

EmployeeNextActionPriority _priorityForCompleteness(
  EmployeeProfileCompletenessStatus status,
) {
  return switch (status) {
    EmployeeProfileCompletenessStatus.missing =>
      EmployeeNextActionPriority.critical,
    EmployeeProfileCompletenessStatus.actionRequired =>
      EmployeeNextActionPriority.high,
    EmployeeProfileCompletenessStatus.inProgress =>
      EmployeeNextActionPriority.medium,
    EmployeeProfileCompletenessStatus.complete =>
      EmployeeNextActionPriority.low,
  };
}

EmployeeNextActionStatus _statusForCompleteness(
  EmployeeProfileCompletenessStatus status,
) {
  return switch (status) {
    EmployeeProfileCompletenessStatus.missing =>
      EmployeeNextActionStatus.blocked,
    EmployeeProfileCompletenessStatus.actionRequired =>
      EmployeeNextActionStatus.open,
    EmployeeProfileCompletenessStatus.inProgress =>
      EmployeeNextActionStatus.dueSoon,
    EmployeeProfileCompletenessStatus.complete =>
      EmployeeNextActionStatus.ready,
  };
}

DateTime _dueDateForCompleteness(
  DateTime today,
  EmployeeProfileCompletenessStatus status,
) {
  return switch (status) {
    EmployeeProfileCompletenessStatus.missing => today,
    EmployeeProfileCompletenessStatus.actionRequired => today.add(
      const Duration(days: 1),
    ),
    EmployeeProfileCompletenessStatus.inProgress => today.add(
      const Duration(days: 7),
    ),
    EmployeeProfileCompletenessStatus.complete => today.add(
      const Duration(days: 14),
    ),
  };
}

int _impactForCompleteness(EmployeeProfileCompletenessStatus status) {
  return switch (status) {
    EmployeeProfileCompletenessStatus.missing => 100,
    EmployeeProfileCompletenessStatus.actionRequired => 84,
    EmployeeProfileCompletenessStatus.inProgress => 58,
    EmployeeProfileCompletenessStatus.complete => 20,
  };
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> members,
  String employeeId,
) {
  for (final member in members) {
    if (member.id == employeeId) {
      return member;
    }
  }
  return null;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
