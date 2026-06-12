import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/attendance/states/attendance_provider.dart';
import 'package:kaysir/features/hris/company/states/company_management_provider.dart';
import 'package:kaysir/features/hris/compensation/states/compensation_provider.dart';
import 'package:kaysir/features/hris/compliance/states/compliance_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/ess_provider.dart';
import 'package:kaysir/features/hris/engagement/states/engagement_provider.dart';
import 'package:kaysir/features/hris/holidays/states/holiday_provider.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_risk_rollup_builder.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/leave/states/leave_provider.dart';
import 'package:kaysir/features/hris/manager/states/manager_provider.dart';
import 'package:kaysir/features/hris/payroal/states/payroll_provider.dart';
import 'package:kaysir/features/hris/people_ops/states/people_ops_provider.dart';
import 'package:kaysir/features/hris/performance/states/performance_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/service_center/states/service_center_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';
import 'package:kaysir/features/hris/workforce_planning/states/workforce_planning_provider.dart';

void main() {
  test('risk rollup builder maps workspace summaries into rollup items', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final peopleOps = container.read(peopleOpsRiskSummaryProvider);
    final companyManagement = container.read(companyManagementSummaryProvider);
    final compliance = container.read(complianceEscalationSummaryProvider);
    final employeeSelfService = container.read(
      employeeSelfServiceRiskSummaryProvider,
    );
    final holidays = container.read(holidayRiskSummaryProvider);
    final manager = container.read(managerRiskSummaryProvider);

    final rollup = buildDashboardRiskRollup(
      DashboardRiskRollupSummaries(
        companyManagement: companyManagement,
        peopleOps: peopleOps,
        compliance: compliance,
        workforcePlanning: container.read(workforcePlanningRiskSummaryProvider),
        recruitment: container.read(recruitmentPipelineRiskProvider),
        talent: container.read(talentRiskSummaryProvider),
        performance: container.read(performanceRiskSummaryProvider),
        compensation: container.read(compensationRiskSummaryProvider),
        engagement: container.read(engagementRiskSummaryProvider),
        serviceCenter: container.read(serviceCenterRiskSummaryProvider),
        attendance: container.read(attendanceRiskSummaryProvider),
        leave: container.read(leaveRiskSummaryProvider),
        holidays: holidays,
        payroll: container.read(payrollRiskSummaryProvider),
        employeeDirectory: container.read(employeeDirectoryRiskSummaryProvider),
        employeeSelfService: employeeSelfService,
        manager: manager,
      ),
    );

    expect(rollup.workspaceCount, hrisWorkspaces.length);
    expect(rollup.items.map((item) => item.workspace.id), [
      HrisWorkspaceId.companyManagement,
      HrisWorkspaceId.peopleOps,
      HrisWorkspaceId.compliance,
      HrisWorkspaceId.workforcePlanning,
      HrisWorkspaceId.recruitment,
      HrisWorkspaceId.talent,
      HrisWorkspaceId.performance,
      HrisWorkspaceId.compensation,
      HrisWorkspaceId.engagement,
      HrisWorkspaceId.serviceCenter,
      HrisWorkspaceId.attendance,
      HrisWorkspaceId.leave,
      HrisWorkspaceId.holidays,
      HrisWorkspaceId.payroll,
      HrisWorkspaceId.employeeDirectory,
      HrisWorkspaceId.employeeSelfService,
      HrisWorkspaceId.manager,
    ]);

    final itemsById = {
      for (final item in rollup.items) item.workspace.id: item,
    };
    final companyItem = itemsById[HrisWorkspaceId.companyManagement]!;
    expect(companyItem.totalRisks, companyManagement.totalRisks);
    expect(
      companyItem.timeSensitiveRisks,
      companyManagement.policyRiskCount +
          companyManagement.documentRiskCount +
          companyManagement.documentRenewalRiskCount +
          companyManagement.operatingRiskCount +
          companyManagement.governanceContactRiskCount +
          companyManagement.entityLifecycleRiskCount +
          companyManagement.controlRiskCount +
          companyManagement.jobProfileRiskCount +
          companyManagement.contractTemplateRiskCount +
          companyManagement.onboardingPackRiskCount +
          companyManagement.probationPlanRiskCount +
          companyManagement.offboardingPackRiskCount +
          companyManagement.documentRequirementRiskCount +
          companyManagement.employeeDocumentGapRiskCount +
          companyManagement.positionControlRiskCount +
          companyManagement.compensationBandRiskCount +
          companyManagement.employerAccountRiskCount +
          companyManagement.vendorAgreementRiskCount +
          companyManagement.filingRiskCount +
          companyManagement.signatoryRiskCount +
          companyManagement.changeRequestRiskCount,
    );
    expect(
      companyItem.leadingSignal,
      '${companyManagement.openChangeCount} open company changes',
    );

    final peopleOpsItem = itemsById[HrisWorkspaceId.peopleOps]!;
    expect(peopleOpsItem.totalRisks, peopleOps.totalRisks);
    expect(peopleOpsItem.timeSensitiveRisks, peopleOps.dueWithinFourteenDays);
    expect(
      peopleOpsItem.leadingSignal,
      '${peopleOps.blockedOnboarding} blocked onboarding',
    );

    final complianceItem = itemsById[HrisWorkspaceId.compliance]!;
    expect(complianceItem.totalRisks, compliance.totalEscalations);
    expect(complianceItem.timeSensitiveRisks, compliance.dueWithinSevenDays);
    expect(
      complianceItem.leadingSignal,
      '${compliance.criticalFindings} critical findings',
    );

    final employeeSelfServiceItem =
        itemsById[HrisWorkspaceId.employeeSelfService]!;
    expect(employeeSelfServiceItem.totalRisks, employeeSelfService.totalAlerts);
    expect(
      employeeSelfServiceItem.timeSensitiveRisks,
      employeeSelfService.pendingTimeOffRequests,
    );
    expect(
      employeeSelfServiceItem.leadingSignal,
      '${employeeSelfService.lowBalanceTypes} low balance types',
    );

    final managerItem = itemsById[HrisWorkspaceId.manager]!;
    expect(managerItem.totalRisks, manager.totalRisks);
    expect(managerItem.timeSensitiveRisks, manager.stalePendingRequests);
    expect(
      managerItem.leadingSignal,
      '${manager.urgentPendingRequests} urgent approvals',
    );

    final holidaysItem = itemsById[HrisWorkspaceId.holidays]!;
    expect(holidaysItem.totalRisks, holidays.totalRisks);
    expect(holidaysItem.timeSensitiveRisks, holidays.upcomingWithinThirtyDays);
    expect(
      holidaysItem.leadingSignal,
      '${holidays.coverageGaps} coverage gaps',
    );

    expect(rollup.totalRisks, 164);
    expect(rollup.timeSensitiveRisks, 121);
    expect(rollup.topItems.map((item) => item.workspace.id), [
      HrisWorkspaceId.companyManagement,
      HrisWorkspaceId.manager,
      HrisWorkspaceId.serviceCenter,
    ]);
    expect(rollup.topItems.first.severity, DashboardRiskSeverity.critical);
  });
}
