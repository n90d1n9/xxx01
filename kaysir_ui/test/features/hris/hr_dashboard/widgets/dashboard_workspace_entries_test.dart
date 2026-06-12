import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/attendance/states/attendance_provider.dart';
import 'package:kaysir/features/hris/company/states/company_management_provider.dart';
import 'package:kaysir/features/hris/compliance/states/compliance_provider.dart';
import 'package:kaysir/features/hris/compensation/states/compensation_provider.dart';
import 'package:kaysir/features/hris/employee/states/employee_directory_provider.dart';
import 'package:kaysir/features/hris/employee/states/ess_provider.dart';
import 'package:kaysir/features/hris/engagement/states/engagement_provider.dart';
import 'package:kaysir/features/hris/holidays/states/holiday_provider.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/states/metric_provider.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_operational_workspace_entries.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_workspace_entries.dart';
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
  test('dashboard workspace entries expose the full HRIS workspace set', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final riskRollup = container.read(dashboardRiskRollupProvider);

    final entries = buildDashboardWorkspaceEntries(
      companyManagementSummary: container.read(
        companyManagementSummaryProvider,
      ),
      peopleOpsSummary: container.read(peopleOpsSummaryProvider),
      complianceSummary: container.read(complianceSummaryProvider),
      workforcePlanningSummary: container.read(
        workforcePlanningSummaryProvider,
      ),
      recruitmentSummary: container.read(recruitmentSummaryProvider),
      talentSummary: container.read(talentSummaryProvider),
      performanceSummary: container.read(performanceSummaryProvider),
      compensationSummary: container.read(compensationSummaryProvider),
      engagementSummary: container.read(engagementSummaryProvider),
      serviceCenterSummary: container.read(serviceCenterSummaryProvider),
      riskRollup: riskRollup,
      operationalSummaries: DashboardOperationalWorkspaceSummaries(
        attendance: container.read(attendanceSummaryProvider),
        leave: container.read(leaveSummaryProvider),
        holidays: container.read(holidaySummaryProvider),
        payroll: container.read(payrollSummaryProvider),
        employeeDirectory: container.read(employeeDirectorySummaryProvider),
        employeeSelfService: container.read(employeeSelfServiceSummaryProvider),
        manager: container.read(managerSelfServiceSummaryProvider),
      ),
    );

    expect(entries, hasLength(17));
    expect(
      entries.where(
        (entry) => entry.category == DashboardWorkspaceCategory.strategic,
      ),
      hasLength(10),
    );
    expect(
      entries.where(
        (entry) => entry.category == DashboardWorkspaceCategory.operational,
      ),
      hasLength(7),
    );
    expect(entries.map((entry) => entry.path), [
      '/hris-company-management',
      '/hris-people-ops',
      '/hris-compliance',
      '/hris-workforce-planning',
      '/hris-recruitment',
      '/hris-talent-development',
      '/hris-performance',
      '/hris-compensation',
      '/hris-engagement',
      '/hris-service-center',
      '/attendance',
      '/leave',
      '/holidays',
      '/payroll',
      '/employee',
      '/employee-self-service',
      '/manager',
    ]);

    final company = entries.singleWhere(
      (entry) => entry.path == '/hris-company-management',
    );
    expect(company.title, 'Company Management');
    expect(company.metrics.map((metric) => metric.label), [
      'Entities',
      'Changes',
      'Risks',
    ]);

    final employeeSelfService = entries.singleWhere(
      (entry) => entry.path == '/employee-self-service',
    );
    expect(employeeSelfService.title, 'Employee Self-Service');
    expect(employeeSelfService.metrics.map((metric) => metric.label), [
      'Stubs',
      'Time off',
      'Pending',
    ]);

    final manager = entries.singleWhere((entry) => entry.path == '/manager');
    expect(manager.metrics.last.value, '5');

    final holidays = entries.singleWhere((entry) => entry.path == '/holidays');
    expect(holidays.title, 'Holidays');
    expect(holidays.metrics.map((metric) => metric.label), [
      'Rules',
      'Upcoming',
      'Custom',
    ]);

    expect(
      entries.where((entry) => entry.riskSignal != null),
      hasLength(riskRollup.items.length),
    );
    final managerRisk = riskRollup.items.singleWhere(
      (item) => item.workspace.id == HrisWorkspaceId.manager,
    );
    expect(manager.riskSignal?.leadingSignal, managerRisk.leadingSignal);
  });
}
