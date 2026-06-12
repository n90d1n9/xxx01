import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_accommodation_provider.dart';
import '../../states/employee_access_governance_provider.dart';
import '../../states/employee_approval_coverage_provider.dart';
import '../../states/employee_approval_policy_provider.dart';
import '../../states/employee_assets_provider.dart';
import '../../states/employee_audit_trail_provider.dart';
import '../../states/employee_benefits_provider.dart';
import '../../states/employee_career_path_provider.dart';
import '../../states/employee_case_log_provider.dart';
import '../../states/employee_compliance_provider.dart';
import '../../states/employee_contract_lifecycle_provider.dart';
import '../../states/employee_data_correction_governance_provider.dart';
import '../../states/employee_data_correction_provider.dart';
import '../../states/employee_data_quality_provider.dart';
import '../../states/employee_development_provider.dart';
import '../../states/employee_document_vault_provider.dart';
import '../../states/employee_document_request_provider.dart';
import '../../states/employee_engagement_provider.dart';
import '../../states/employee_exit_readiness_provider.dart';
import '../../states/employee_job_assignment_provider.dart';
import '../../states/employee_job_history_provider.dart';
import '../../states/employee_leave_provider.dart';
import '../../states/employee_lifecycle_task_provider.dart';
import '../../states/employee_manager_change_readiness_provider.dart';
import '../../states/employee_mobility_readiness_provider.dart';
import '../../states/employee_org_provider.dart';
import '../../states/employee_payslip_delivery_provider.dart';
import '../../states/employee_payroll_close_provider.dart';
import '../../states/employee_payroll_cutoff_provider.dart';
import '../../states/employee_payroll_payment_provider.dart';
import '../../states/employee_payroll_provider.dart';
import '../../states/employee_payroll_run_provider.dart';
import '../../states/employee_payroll_variance_provider.dart';
import '../../states/employee_performance_support_provider.dart';
import '../../states/employee_personal_records_provider.dart';
import '../../states/employee_position_control_provider.dart';
import '../../states/employee_record_action_provider.dart';
import '../../states/employee_relations_provider.dart';
import '../../states/employee_reimbursement_provider.dart';
import '../../states/employee_schedule_provider.dart';
import '../../states/employee_skill_inventory_provider.dart';
import '../../states/employee_succession_plan_provider.dart';
import '../../states/employee_talent_calibration_provider.dart';
import '../../states/employee_timekeeping_provider.dart';
import '../../states/employee_workflow_automation_provider.dart';
import '../../states/employee_work_authorization_provider.dart';

class EmployeeProfileAttentionSummary extends ConsumerWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeProfileAttentionSummary({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeId = snapshot.member.id;
    final personal = ref.watch(
      employeePersonalRecordsProfileProvider(employeeId),
    );
    final accommodations = ref.watch(
      employeeAccommodationProfileProvider(employeeId),
    );
    final documentRequests = ref.watch(
      employeeDocumentRequestProfileProvider(employeeId),
    );
    final documentVault = ref.watch(
      employeeDocumentVaultProfileProvider(employeeId),
    );
    final workAuthorization = ref.watch(
      employeeWorkAuthorizationProfileProvider(employeeId),
    );
    final compliance = ref.watch(employeeComplianceSummaryProvider(employeeId));
    final engagement = ref.watch(employeeEngagementPlanProvider(employeeId));
    final support = ref.watch(
      employeePerformanceSupportPlanProvider(employeeId),
    );
    final careerPath = ref.watch(employeeCareerPathProfileProvider(employeeId));
    final skills = ref.watch(employeeSkillInventoryProvider(employeeId));
    final talent = ref.watch(employeeTalentCalibrationProvider(employeeId));
    final mobility = ref.watch(employeeMobilityReadinessProvider(employeeId));
    final succession = ref.watch(employeeSuccessionProfileProvider(employeeId));
    final relations = ref.watch(employeeRelationsProfileProvider(employeeId));
    final development = ref.watch(employeeDevelopmentPlanProvider(employeeId));
    final benefits = ref.watch(employeeBenefitsProfileProvider(employeeId));
    final payroll = ref.watch(employeePayrollProfileProvider(employeeId));
    final payrollCutoff = ref.watch(
      employeePayrollCutoffReconciliationProvider(employeeId),
    );
    final payrollVariance = ref.watch(
      employeePayrollVarianceProvider(employeeId),
    );
    final payrollRun = ref.watch(employeePayrollRunProvider(employeeId));
    final payrollPayment = ref.watch(
      employeePayrollPaymentProvider(employeeId),
    );
    final payslipDelivery = ref.watch(
      employeePayslipDeliveryProvider(employeeId),
    );
    final payrollClose = ref.watch(employeePayrollCloseProvider(employeeId));
    final reimbursement = ref.watch(
      employeeReimbursementProfileProvider(employeeId),
    );
    final accessGovernance = ref.watch(
      employeeAccessGovernanceProfileProvider(employeeId),
    );
    final assets = ref.watch(employeeAssetAccessProfileProvider(employeeId));
    final auditTrail = ref.watch(employeeAuditTrailProfileProvider(employeeId));
    final caseLog = ref.watch(employeeHrCaseLogProvider(employeeId));
    final dataQuality = ref.watch(employeeDataQualityProvider(employeeId));
    final dataCorrection = ref.watch(
      employeeDataCorrectionProvider(employeeId),
    );
    final correctionGovernance = ref.watch(
      employeeDataCorrectionGovernanceProvider(employeeId),
    );
    final jobAssignments = ref.watch(
      employeeJobAssignmentProfileProvider(employeeId),
    );
    final jobHistory = ref.watch(employeeJobHistoryProfileProvider(employeeId));
    final approvalCoverage = ref.watch(
      employeeApprovalCoverageProvider(employeeId),
    );
    final approvalPolicy = ref.watch(
      employeeApprovalPolicyProfileProvider(employeeId),
    );
    final managerChange = ref.watch(
      employeeManagerChangeReadinessProvider(employeeId),
    );
    final lifecycle = ref.watch(employeeLifecyclePlanProvider(employeeId));
    final exitReadiness = ref.watch(employeeExitReadinessProvider(employeeId));
    final contractLifecycle = ref.watch(
      employeeContractLifecycleProfileProvider(employeeId),
    );
    final recordActions = ref.watch(
      employeeRecordActionSummaryProvider(employeeId),
    );
    final schedule = ref.watch(employeeScheduleProfileProvider(employeeId));
    final timekeeping = ref.watch(employeeTimekeepingProvider(employeeId));
    final org = ref.watch(employeeOrgProfileProvider(employeeId));
    final position = ref.watch(employeePositionControlProvider(employeeId));
    final leave = ref.watch(employeeLeaveProfileProvider(employeeId));
    final automation = ref.watch(
      employeeWorkflowAutomationProfileProvider(employeeId),
    );

    final recordsCount =
        (personal?.totalAttentionCount ?? 0) +
        (documentVault?.attentionCount ?? 0) +
        (workAuthorization?.attentionCount ?? 0) +
        (accommodations?.attentionCount ?? 0) +
        (documentRequests?.attentionCount ?? 0) +
        compliance.pendingCount +
        compliance.rejectedCount +
        compliance.overdueCount +
        compliance.expiringSoonCount +
        (caseLog?.attentionCount ?? 0) +
        (dataQuality?.attentionCount ?? 0) +
        (dataCorrection?.attentionCount ?? 0) +
        (correctionGovernance?.attentionCount ?? 0);
    final growthCount =
        (support?.attentionCount ?? 0) +
        (engagement?.criticalSignalCount ?? 0) +
        (engagement?.overdueSignalCount ?? 0) +
        (careerPath?.attentionCount ?? 0) +
        (skills?.attentionCount ?? 0) +
        (talent?.attentionCount ?? 0) +
        (succession?.attentionCount ?? 0) +
        (mobility?.attentionCount ?? 0) +
        (relations?.attentionCount ?? 0) +
        (development?.skillGapCount ?? 0) +
        (development?.learningDueCount ?? 0) +
        (development?.certificationRiskCount ?? 0);
    final workCount =
        (org?.attentionCount ?? 0) +
        (position?.attentionCount ?? 0) +
        (managerChange?.attentionCount ?? 0) +
        (approvalCoverage?.attentionCount ?? 0) +
        (approvalPolicy?.attentionCount ?? 0) +
        (jobAssignments?.attentionCount ?? 0) +
        (jobHistory?.attentionCount ?? 0) +
        (contractLifecycle?.attentionCount ?? 0) +
        (schedule?.attentionCount ?? 0) +
        (timekeeping?.attentionCount ?? 0) +
        (leave?.attentionCount ?? 0) +
        (lifecycle?.blockedCount ?? 0) +
        (lifecycle?.overdueCount ?? 0) +
        (exitReadiness?.attentionCount ?? 0) +
        (automation?.attentionCount ?? 0) +
        recordActions.submittedCount +
        recordActions.approvedCount;
    final payCount =
        (payroll?.attentionCount ?? 0) +
        (payrollCutoff?.attentionCount ?? 0) +
        (payrollVariance?.attentionCount ?? 0) +
        (payrollRun?.attentionCount ?? 0) +
        (payrollPayment?.attentionCount ?? 0) +
        (payslipDelivery?.attentionCount ?? 0) +
        (payrollClose?.attentionCount ?? 0) +
        (reimbursement?.attentionCount ?? 0) +
        (benefits?.actionRequiredCount ?? 0) +
        (benefits?.pendingDependentCount ?? 0);
    final securityCount =
        (accessGovernance?.attentionCount ?? 0) +
        (auditTrail?.attentionCount ?? 0) +
        (assets?.attentionCount ?? snapshot.pendingAssetCount);
    final totalCount =
        recordsCount + workCount + growthCount + payCount + securityCount;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Attention summary',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              HrisStatusPill(
                label: totalCount == 0 ? 'Clear' : '$totalCount open',
                color:
                    totalCount == 0
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(label: 'Records', value: '$recordsCount'),
              HrisMetricStripItem(label: 'Work', value: '$workCount'),
              HrisMetricStripItem(label: 'Growth', value: '$growthCount'),
              HrisMetricStripItem(label: 'Pay', value: '$payCount'),
              HrisMetricStripItem(label: 'Security', value: '$securityCount'),
            ],
          ),
        ],
      ),
    );
  }
}
