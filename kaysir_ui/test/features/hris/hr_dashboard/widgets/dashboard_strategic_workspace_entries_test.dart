import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/company/states/company_management_provider.dart';
import 'package:kaysir/features/hris/compensation/states/compensation_provider.dart';
import 'package:kaysir/features/hris/compliance/states/compliance_provider.dart';
import 'package:kaysir/features/hris/engagement/states/engagement_provider.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_workspace_risk_signal.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';
import 'package:kaysir/features/hris/hr_dashboard/states/metric_provider.dart';
import 'package:kaysir/features/hris/hr_dashboard/widgets/dashboard_strategic_workspace_entries.dart';
import 'package:kaysir/features/hris/people_ops/states/people_ops_provider.dart';
import 'package:kaysir/features/hris/performance/states/performance_provider.dart';
import 'package:kaysir/features/hris/recruitment/states/recruitment_provider.dart';
import 'package:kaysir/features/hris/service_center/states/service_center_provider.dart';
import 'package:kaysir/features/hris/talent/states/talent_provider.dart';
import 'package:kaysir/features/hris/workforce_planning/states/workforce_planning_provider.dart';

void main() {
  test('strategic workspace entries map summaries and risk signals', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final company = container.read(companyManagementSummaryProvider);
    final peopleOps = container.read(peopleOpsSummaryProvider);
    final compliance = container.read(complianceSummaryProvider);
    final workforcePlanning = container.read(workforcePlanningSummaryProvider);
    final recruitment = container.read(recruitmentSummaryProvider);
    final talent = container.read(talentSummaryProvider);
    final performance = container.read(performanceSummaryProvider);
    final compensation = container.read(compensationSummaryProvider);
    final engagement = container.read(engagementSummaryProvider);
    final serviceCenter = container.read(serviceCenterSummaryProvider);
    final riskRollup = container.read(dashboardRiskRollupProvider);

    final entries = buildStrategicDashboardWorkspaceEntries(
      DashboardStrategicWorkspaceSummaries(
        companyManagement: company,
        peopleOps: peopleOps,
        compliance: compliance,
        workforcePlanning: workforcePlanning,
        recruitment: recruitment,
        talent: talent,
        performance: performance,
        compensation: compensation,
        engagement: engagement,
        serviceCenter: serviceCenter,
      ),
      riskSignals: buildDashboardWorkspaceRiskSignalMap(riskRollup),
    );

    expect(entries, hasLength(10));
    expect(
      entries.every(
        (entry) => entry.category == DashboardWorkspaceCategory.strategic,
      ),
      isTrue,
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
    ]);

    final companyEntry = entries.firstWhere(
      (entry) => entry.workspace.id == HrisWorkspaceId.companyManagement,
    );
    expect(companyEntry.metrics.map((metric) => metric.label), [
      'Entities',
      'Changes',
      'Risks',
    ]);
    expect(companyEntry.metrics.map((metric) => metric.value), [
      '${company.legalEntities}',
      '${company.openChangeCount}/${company.changeRequestCount}',
      '${company.totalRisks}',
    ]);

    final peopleOpsEntry = entries.firstWhere(
      (entry) => entry.workspace.id == HrisWorkspaceId.peopleOps,
    );
    expect(peopleOpsEntry.metrics.map((metric) => metric.label), [
      'Hires',
      'Tasks',
      'Risks',
    ]);
    expect(peopleOpsEntry.metrics.map((metric) => metric.value), [
      '${peopleOps.hiresNeeded}',
      '${peopleOps.onboardingTasksDue}',
      '${peopleOps.complianceRisks}',
    ]);

    final serviceCenterEntry = entries.firstWhere(
      (entry) => entry.workspace.id == HrisWorkspaceId.serviceCenter,
    );
    expect(serviceCenterEntry.metrics.map((metric) => metric.label), [
      'Cases',
      'SLA',
      'Docs',
    ]);
    expect(serviceCenterEntry.metrics.map((metric) => metric.value), [
      '${serviceCenter.openCases}',
      '${serviceCenter.slaRisks}',
      '${serviceCenter.documentBacklog}',
    ]);

    final serviceCenterRisk = riskRollup.items.singleWhere(
      (item) => item.workspace.id == HrisWorkspaceId.serviceCenter,
    );
    expect(
      serviceCenterEntry.riskSignal?.leadingSignal,
      serviceCenterRisk.leadingSignal,
    );
  });
}
