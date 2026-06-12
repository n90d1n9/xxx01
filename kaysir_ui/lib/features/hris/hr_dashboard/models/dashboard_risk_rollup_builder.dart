import 'package:kaysir/features/hris/attendance/models/attendance_record.dart';
import 'package:kaysir/features/hris/company/models/company_management_summary.dart';
import 'package:kaysir/features/hris/compensation/models/compensation_models.dart';
import 'package:kaysir/features/hris/compliance/models/compliance_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_directory_models.dart';
import 'package:kaysir/features/hris/employee/models/employee_self_service_summary.dart';
import 'package:kaysir/features/hris/engagement/models/engagement_models.dart';
import 'package:kaysir/features/hris/holidays/models/holiday_models.dart';
import 'package:kaysir/features/hris/leave/models/leave_request.dart';
import 'package:kaysir/features/hris/manager/models/manager_models.dart';
import 'package:kaysir/features/hris/payroal/models/payroll_detail.dart';
import 'package:kaysir/features/hris/people_ops/models/people_ops_models.dart';
import 'package:kaysir/features/hris/performance/models/performance_models.dart';
import 'package:kaysir/features/hris/recruitment/models/recruitment_models.dart';
import 'package:kaysir/features/hris/service_center/models/service_center_models.dart';
import 'package:kaysir/features/hris/talent/models/talent_models.dart';
import 'package:kaysir/features/hris/workforce_planning/models/workforce_planning_models.dart';

import 'dashboard_analytics.dart';
import 'hris_workspace.dart';

class DashboardRiskRollupSummaries {
  final CompanyManagementSummary companyManagement;
  final PeopleOpsRiskSummary peopleOps;
  final ComplianceEscalationSummary compliance;
  final WorkforcePlanningRiskSummary workforcePlanning;
  final RecruitmentPipelineRiskSummary recruitment;
  final TalentRiskSummary talent;
  final PerformanceRiskSummary performance;
  final CompensationRiskSummary compensation;
  final EngagementRiskSummary engagement;
  final ServiceCenterRiskSummary serviceCenter;
  final AttendanceRiskSummary attendance;
  final LeaveRiskSummary leave;
  final HolidayRiskSummary holidays;
  final PayrollRiskSummary payroll;
  final EmployeeDirectoryRiskSummary employeeDirectory;
  final EmployeeSelfServiceRiskSummary employeeSelfService;
  final ManagerRiskSummary manager;

  const DashboardRiskRollupSummaries({
    required this.companyManagement,
    required this.peopleOps,
    required this.compliance,
    required this.workforcePlanning,
    required this.recruitment,
    required this.talent,
    required this.performance,
    required this.compensation,
    required this.engagement,
    required this.serviceCenter,
    required this.attendance,
    required this.leave,
    required this.holidays,
    required this.payroll,
    required this.employeeDirectory,
    required this.employeeSelfService,
    required this.manager,
  });
}

DashboardRiskRollup buildDashboardRiskRollup(
  DashboardRiskRollupSummaries summaries,
) {
  return DashboardRiskRollup(
    items: [
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.companyManagement),
        totalRisks: summaries.companyManagement.totalRisks,
        timeSensitiveRisks:
            summaries.companyManagement.policyRiskCount +
            summaries.companyManagement.documentRiskCount +
            summaries.companyManagement.documentRenewalRiskCount +
            summaries.companyManagement.operatingRiskCount +
            summaries.companyManagement.governanceContactRiskCount +
            summaries.companyManagement.entityLifecycleRiskCount +
            summaries.companyManagement.controlRiskCount +
            summaries.companyManagement.jobProfileRiskCount +
            summaries.companyManagement.contractTemplateRiskCount +
            summaries.companyManagement.onboardingPackRiskCount +
            summaries.companyManagement.probationPlanRiskCount +
            summaries.companyManagement.offboardingPackRiskCount +
            summaries.companyManagement.documentRequirementRiskCount +
            summaries.companyManagement.employeeDocumentGapRiskCount +
            summaries.companyManagement.positionControlRiskCount +
            summaries.companyManagement.compensationBandRiskCount +
            summaries.companyManagement.employerAccountRiskCount +
            summaries.companyManagement.vendorAgreementRiskCount +
            summaries.companyManagement.filingRiskCount +
            summaries.companyManagement.signatoryRiskCount +
            summaries.companyManagement.changeRequestRiskCount,
        leadingSignal:
            '${summaries.companyManagement.openChangeCount} open company changes',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.peopleOps),
        totalRisks: summaries.peopleOps.totalRisks,
        timeSensitiveRisks: summaries.peopleOps.dueWithinFourteenDays,
        leadingSignal:
            '${summaries.peopleOps.blockedOnboarding} blocked onboarding',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.compliance),
        totalRisks: summaries.compliance.totalEscalations,
        timeSensitiveRisks: summaries.compliance.dueWithinSevenDays,
        leadingSignal:
            '${summaries.compliance.criticalFindings} critical findings',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.workforcePlanning),
        totalRisks: summaries.workforcePlanning.totalRisks,
        timeSensitiveRisks: summaries.workforcePlanning.startsWithinThirtyDays,
        leadingSignal:
            '${summaries.workforcePlanning.blockedRequests} blocked requests',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.recruitment),
        totalRisks: summaries.recruitment.totalRisks,
        timeSensitiveRisks: summaries.recruitment.expiringOffers,
        leadingSignal: '${summaries.recruitment.feedbackDue} feedback due',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.talent),
        totalRisks: summaries.talent.totalRisks,
        timeSensitiveRisks: summaries.talent.dueWithinFourteenDays,
        leadingSignal:
            '${summaries.talent.expiredCertifications} expired certs',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.performance),
        totalRisks: summaries.performance.totalRisks,
        timeSensitiveRisks: summaries.performance.dueWithinFourteenDays,
        leadingSignal:
            '${summaries.performance.highRetentionRisks} retention risks',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.compensation),
        totalRisks: summaries.compensation.totalRisks,
        timeSensitiveRisks: summaries.compensation.dueWithinFourteenDays,
        leadingSignal:
            '${summaries.compensation.blockedReviews} blocked reviews',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.engagement),
        totalRisks: summaries.engagement.totalRisks,
        timeSensitiveRisks: summaries.engagement.dueWithinSevenDays,
        leadingSignal:
            '${summaries.engagement.highWellbeingRisks} wellbeing risks',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.serviceCenter),
        totalRisks: summaries.serviceCenter.totalRisks,
        timeSensitiveRisks: summaries.serviceCenter.dueWithinTwentyFourHours,
        leadingSignal: '${summaries.serviceCenter.slaRiskCases} SLA risks',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.attendance),
        totalRisks: summaries.attendance.totalRisks,
        timeSensitiveRisks: summaries.attendance.openRecords,
        leadingSignal: '${summaries.attendance.lateRecords} late records',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.leave),
        totalRisks: summaries.leave.totalRisks,
        timeSensitiveRisks: summaries.leave.upcomingPendingRequests,
        leadingSignal: '${summaries.leave.pendingDays} pending days',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.holidays),
        totalRisks: summaries.holidays.totalRisks,
        timeSensitiveRisks: summaries.holidays.upcomingWithinThirtyDays,
        leadingSignal: '${summaries.holidays.coverageGaps} coverage gaps',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.payroll),
        totalRisks: summaries.payroll.totalRisks,
        timeSensitiveRisks: summaries.payroll.pendingPayments,
        leadingSignal: '${summaries.payroll.pendingPayments} pending payments',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.employeeDirectory),
        totalRisks: summaries.employeeDirectory.totalRisks,
        timeSensitiveRisks: summaries.employeeDirectory.onboardingCount,
        leadingSignal:
            '${summaries.employeeDirectory.watchlistCount} watchlist profiles',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.employeeSelfService),
        totalRisks: summaries.employeeSelfService.totalAlerts,
        timeSensitiveRisks:
            summaries.employeeSelfService.pendingTimeOffRequests,
        leadingSignal:
            '${summaries.employeeSelfService.lowBalanceTypes} low balance types',
      ),
      DashboardRiskItem(
        workspace: hrisWorkspaceById(HrisWorkspaceId.manager),
        totalRisks: summaries.manager.totalRisks,
        timeSensitiveRisks: summaries.manager.stalePendingRequests,
        leadingSignal:
            '${summaries.manager.urgentPendingRequests} urgent approvals',
      ),
    ],
  );
}
