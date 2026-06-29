import 'package:flutter/material.dart';

import '../../models/employee_management_models.dart';
import 'employee_access_governance_center_panel.dart';
import 'employee_accommodation_center_panel.dart';
import 'employee_approval_coverage_center_panel.dart';
import 'employee_approval_policy_center_panel.dart';
import 'employee_asset_access_center_panel.dart';
import 'employee_audit_trail_center_panel.dart';
import 'employee_benefits_center_panel.dart';
import 'employee_career_path_center_panel.dart';
import 'employee_case_log_center_panel.dart';
import 'employee_compensation_review_panel.dart';
import 'employee_compliance_center_panel.dart';
import 'employee_contract_lifecycle_center_panel.dart';
import 'employee_data_correction_governance_panel.dart';
import 'employee_data_correction_panel.dart';
import 'employee_data_quality_panel.dart';
import 'employee_development_center_panel.dart';
import 'employee_document_lifecycle_audit_panel.dart';
import 'employee_document_vault_center_panel.dart';
import 'employee_document_request_center_panel.dart';
import 'employee_engagement_center_panel.dart';
import 'employee_exit_readiness_center_panel.dart';
import 'employee_job_assignment_center_panel.dart';
import 'employee_job_history_center_panel.dart';
import 'employee_leave_center_panel.dart';
import 'employee_lifecycle_task_center_panel.dart';
import 'employee_management_snapshot_panel.dart';
import 'employee_manager_change_readiness_center_panel.dart';
import 'employee_mobility_readiness_center_panel.dart';
import 'employee_org_center_panel.dart';
import 'employee_payslip_delivery_panel.dart';
import 'employee_payroll_center_panel.dart';
import 'employee_payroll_close_panel.dart';
import 'employee_payroll_cutoff_reconciliation_panel.dart';
import 'employee_payroll_payment_panel.dart';
import 'employee_payroll_run_preview_panel.dart';
import 'employee_payroll_variance_review_panel.dart';
import 'employee_performance_review_panel.dart';
import 'employee_performance_support_center_panel.dart';
import 'employee_personal_records_center_panel.dart';
import 'employee_position_control_center_panel.dart';
import 'employee_profile_completeness_panel.dart';
import 'employee_profile_change_governance_panel.dart';
import 'employee_record_action_center_panel.dart';
import 'employee_relations_center_panel.dart';
import 'employee_reimbursement_center_panel.dart';
import 'employee_schedule_center_panel.dart';
import 'employee_skill_inventory_center_panel.dart';
import 'employee_succession_plan_center_panel.dart';
import 'employee_talent_calibration_center_panel.dart';
import 'employee_timekeeping_center_panel.dart';
import 'employee_timeline_center_panel.dart';
import 'employee_work_authorization_center_panel.dart';

enum EmployeeProfileSection {
  overview('Overview', Icons.dashboard_outlined),
  records('Records', Icons.folder_copy_outlined),
  work('Work', Icons.work_history_outlined),
  growth('Growth', Icons.insights_outlined),
  pay('Pay', Icons.payments_outlined),
  security('Security', Icons.admin_panel_settings_outlined);

  final String label;
  final IconData icon;

  const EmployeeProfileSection(this.label, this.icon);
}

class EmployeeProfileSectionSwitcher extends StatelessWidget {
  final EmployeeProfileSection selected;
  final ValueChanged<EmployeeProfileSection> onChanged;

  const EmployeeProfileSectionSwitcher({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<EmployeeProfileSection>(
        showSelectedIcon: false,
        segments:
            EmployeeProfileSection.values
                .map(
                  (section) => ButtonSegment(
                    value: section,
                    icon: Icon(section.icon, size: 18),
                    label: Text(
                      section.label,
                      key: ValueKey('employee-profile-section-${section.name}'),
                    ),
                  ),
                )
                .toList(),
        selected: {selected},
        onSelectionChanged: (selection) => onChanged(selection.single),
      ),
    );
  }
}

class EmployeeProfileSectionContent extends StatelessWidget {
  final EmployeeProfileSection section;
  final EmployeeManagementSnapshot snapshot;

  const EmployeeProfileSectionContent({
    super.key,
    required this.section,
    required this.snapshot,
  });

  @override
  Widget build(BuildContext context) {
    final children = _childrenFor(section, snapshot);
    final spacedChildren = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) {
        spacedChildren.add(const SizedBox(height: 12));
      }
      spacedChildren.add(children[index]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: spacedChildren,
    );
  }

  List<Widget> _childrenFor(
    EmployeeProfileSection section,
    EmployeeManagementSnapshot snapshot,
  ) {
    return switch (section) {
      EmployeeProfileSection.overview => [
        EmployeeManagementSnapshotPanel(snapshot: snapshot),
        EmployeeProfileCompletenessPanel(snapshot: snapshot),
        EmployeeDataQualityPanel(snapshot: snapshot),
        EmployeeDataCorrectionPanel(snapshot: snapshot),
        EmployeeDataCorrectionGovernancePanel(snapshot: snapshot),
        EmployeeAuditTrailCenterPanel(snapshot: snapshot),
        EmployeeTimelineCenterPanel(snapshot: snapshot),
      ],
      EmployeeProfileSection.records => [
        EmployeePersonalRecordsCenterPanel(snapshot: snapshot),
        EmployeeDocumentVaultCenterPanel(snapshot: snapshot),
        EmployeeWorkAuthorizationCenterPanel(snapshot: snapshot),
        EmployeeAccommodationCenterPanel(snapshot: snapshot),
        EmployeeDocumentRequestCenterPanel(snapshot: snapshot),
        EmployeeDocumentLifecycleAuditPanel(snapshot: snapshot),
        EmployeeComplianceCenterPanel(snapshot: snapshot),
        EmployeeHrCaseLogCenterPanel(snapshot: snapshot),
      ],
      EmployeeProfileSection.work => [
        EmployeeOrgCenterPanel(snapshot: snapshot),
        EmployeePositionControlCenterPanel(snapshot: snapshot),
        EmployeeProfileChangeGovernancePanel(snapshot: snapshot),
        EmployeeManagerChangeReadinessCenterPanel(snapshot: snapshot),
        EmployeeApprovalCoverageCenterPanel(snapshot: snapshot),
        EmployeeApprovalPolicyCenterPanel(snapshot: snapshot),
        EmployeeJobAssignmentCenterPanel(snapshot: snapshot),
        EmployeeJobHistoryCenterPanel(snapshot: snapshot),
        EmployeeContractLifecycleCenterPanel(snapshot: snapshot),
        EmployeeScheduleCenterPanel(snapshot: snapshot),
        EmployeeTimekeepingCenterPanel(snapshot: snapshot),
        EmployeeLeaveCenterPanel(snapshot: snapshot),
        EmployeeLifecycleTaskCenterPanel(snapshot: snapshot),
        EmployeeExitReadinessCenterPanel(snapshot: snapshot),
        EmployeeRecordActionCenterPanel(snapshot: snapshot),
      ],
      EmployeeProfileSection.growth => [
        EmployeePerformanceReviewPanel(snapshot: snapshot),
        EmployeePerformanceSupportCenterPanel(snapshot: snapshot),
        EmployeeSkillInventoryCenterPanel(snapshot: snapshot),
        EmployeeTalentCalibrationCenterPanel(snapshot: snapshot),
        EmployeeCareerPathCenterPanel(snapshot: snapshot),
        EmployeeSuccessionPlanCenterPanel(snapshot: snapshot),
        EmployeeMobilityReadinessCenterPanel(snapshot: snapshot),
        EmployeeEngagementCenterPanel(snapshot: snapshot),
        EmployeeRelationsCenterPanel(snapshot: snapshot),
        EmployeeDevelopmentCenterPanel(snapshot: snapshot),
      ],
      EmployeeProfileSection.pay => [
        EmployeePayrollCenterPanel(snapshot: snapshot),
        EmployeePayrollCutoffReconciliationPanel(snapshot: snapshot),
        EmployeePayrollVarianceReviewPanel(snapshot: snapshot),
        EmployeePayrollRunPreviewPanel(snapshot: snapshot),
        EmployeePayrollPaymentPanel(snapshot: snapshot),
        EmployeePayslipDeliveryPanel(snapshot: snapshot),
        EmployeePayrollClosePanel(snapshot: snapshot),
        EmployeeCompensationReviewPanel(snapshot: snapshot),
        EmployeeReimbursementCenterPanel(snapshot: snapshot),
        EmployeeBenefitsCenterPanel(snapshot: snapshot),
      ],
      EmployeeProfileSection.security => [
        EmployeeAccessGovernanceCenterPanel(snapshot: snapshot),
        EmployeeAssetAccessCenterPanel(snapshot: snapshot),
      ],
    };
  }
}
