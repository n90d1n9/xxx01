import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kaysir/features/hris/attendance/states/attendance_provider.dart';
import 'package:kaysir/features/hris/company/states/company_management_provider.dart';
import 'package:kaysir/features/hris/compensation/states/compensation_provider.dart';
import 'package:kaysir/features/hris/compliance/states/compliance_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/ess_provider.dart';
import 'package:kaysir/features/hris/engagement/states/engagement_provider.dart';
import 'package:kaysir/features/hris/holidays/states/holiday_provider.dart';
import 'package:kaysir/features/hris/leave/states/leave_provider.dart';
import 'package:kaysir/features/hris/manager/states/manager_provider.dart';
import 'package:kaysir/features/hris/payroal/states/payroll_provider.dart';
import 'package:kaysir/features/hris/people_ops/states/people_ops_provider.dart';
import 'package:kaysir/features/hris/performance/states/performance_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/service_center/states/service_center_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';
import 'package:kaysir/features/hris/workforce_planning/states/workforce_planning_provider.dart';

import '../data/dashboard_seed_data.dart';
import '../models/dashboard_action_summary.dart';
import '../models/dashboard_analytics.dart';
import '../models/dashboard_risk_rollup_builder.dart';
import '../models/hr_metric.dart';
import '../models/hr_dashboard_view_model.dart';
import '../models/report_type.dart';
import '../widgets/dashboard_operational_workspace_entries.dart';
import '../widgets/dashboard_workspace_entries.dart';

final selectedPeriodProvider = StateProvider<String>((ref) => 'This Month');
final isLoadingProvider = StateProvider<bool>((ref) => false);
final hrDashboardClockProvider = Provider<DateTime Function()>(
  (ref) => () => DateTime.now(),
);
final dashboardLastUpdatedProvider = StateProvider<DateTime>(
  (ref) => ref.watch(hrDashboardClockProvider)(),
);

final hrMetricsProvider = Provider<List<HRMetric>>((ref) {
  final selectedPeriod = ref.watch(selectedPeriodProvider);
  return buildHrMetrics(selectedPeriod);
});

final reportTypesProvider = Provider<List<ReportType>>((ref) {
  return buildReportTypes();
});

final departmentPerformanceProvider =
    Provider<List<DepartmentPerformancePoint>>((ref) {
      return dashboardDepartmentPerformance;
    });

final hiringTrendsProvider = Provider<List<HiringTrendPoint>>((ref) {
  return dashboardHiringTrends;
});

final dashboardInsightSummaryProvider = Provider<DashboardInsightSummary>((
  ref,
) {
  final metrics = ref.watch(hrMetricsProvider);
  final departmentPerformance = ref.watch(departmentPerformanceProvider);
  final hiringTrends = ref.watch(hiringTrendsProvider);

  return DashboardInsightSummary.fromData(
    metrics: metrics,
    departmentPerformance: departmentPerformance,
    hiringTrends: hiringTrends,
  );
});

final dashboardRiskRollupProvider = Provider<DashboardRiskRollup>((ref) {
  return buildDashboardRiskRollup(
    DashboardRiskRollupSummaries(
      companyManagement: ref.watch(companyManagementSummaryProvider),
      peopleOps: ref.watch(peopleOpsRiskSummaryProvider),
      compliance: ref.watch(complianceEscalationSummaryProvider),
      workforcePlanning: ref.watch(workforcePlanningRiskSummaryProvider),
      recruitment: ref.watch(recruitmentPipelineRiskProvider),
      talent: ref.watch(talentRiskSummaryProvider),
      performance: ref.watch(performanceRiskSummaryProvider),
      compensation: ref.watch(compensationRiskSummaryProvider),
      engagement: ref.watch(engagementRiskSummaryProvider),
      serviceCenter: ref.watch(serviceCenterRiskSummaryProvider),
      attendance: ref.watch(attendanceRiskSummaryProvider),
      leave: ref.watch(leaveRiskSummaryProvider),
      holidays: ref.watch(holidayRiskSummaryProvider),
      payroll: ref.watch(payrollRiskSummaryProvider),
      employeeDirectory: ref.watch(employeeDirectoryRiskSummaryProvider),
      employeeSelfService: ref.watch(employeeSelfServiceRiskSummaryProvider),
      manager: ref.watch(managerRiskSummaryProvider),
    ),
  );
});

final dashboardActionSummaryProvider = Provider<DashboardActionSummary>((ref) {
  return DashboardActionSummary.fromSignals(
    insightSummary: ref.watch(dashboardInsightSummaryProvider),
    riskRollup: ref.watch(dashboardRiskRollupProvider),
  );
});

final hrDashboardViewModelProvider = Provider<HRDashboardViewModel>((ref) {
  final riskRollup = ref.watch(dashboardRiskRollupProvider);

  return HRDashboardViewModel(
    selectedPeriod: ref.watch(selectedPeriodProvider),
    isLoading: ref.watch(isLoadingProvider),
    lastUpdated: ref.watch(dashboardLastUpdatedProvider),
    hrMetrics: ref.watch(hrMetricsProvider),
    reportTypes: ref.watch(reportTypesProvider),
    departmentPerformance: ref.watch(departmentPerformanceProvider),
    hiringTrends: ref.watch(hiringTrendsProvider),
    insightSummary: ref.watch(dashboardInsightSummaryProvider),
    riskRollup: riskRollup,
    actionSummary: ref.watch(dashboardActionSummaryProvider),
    workspaceEntries: buildDashboardWorkspaceEntries(
      companyManagementSummary: ref.watch(companyManagementSummaryProvider),
      peopleOpsSummary: ref.watch(peopleOpsSummaryProvider),
      complianceSummary: ref.watch(complianceSummaryProvider),
      workforcePlanningSummary: ref.watch(workforcePlanningSummaryProvider),
      recruitmentSummary: ref.watch(recruitmentSummaryProvider),
      talentSummary: ref.watch(talentSummaryProvider),
      performanceSummary: ref.watch(performanceSummaryProvider),
      compensationSummary: ref.watch(compensationSummaryProvider),
      engagementSummary: ref.watch(engagementSummaryProvider),
      serviceCenterSummary: ref.watch(serviceCenterSummaryProvider),
      riskRollup: riskRollup,
      operationalSummaries: DashboardOperationalWorkspaceSummaries(
        attendance: ref.watch(attendanceSummaryProvider),
        leave: ref.watch(leaveSummaryProvider),
        holidays: ref.watch(holidaySummaryProvider),
        payroll: ref.watch(payrollSummaryProvider),
        employeeDirectory: ref.watch(employeeDirectorySummaryProvider),
        employeeSelfService: ref.watch(employeeSelfServiceSummaryProvider),
        manager: ref.watch(managerSelfServiceSummaryProvider),
      ),
    ),
  );
});
