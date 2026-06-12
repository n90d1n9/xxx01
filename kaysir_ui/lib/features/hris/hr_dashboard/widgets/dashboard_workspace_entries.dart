import 'package:kaysir/features/hris/compensation/models/compensation_models.dart';
import 'package:kaysir/features/hris/compliance/models/compliance_models.dart';
import 'package:kaysir/features/hris/company/models/company_management_summary.dart';
import 'package:kaysir/features/hris/engagement/models/engagement_models.dart';
import 'package:kaysir/features/hris/people_ops/models/people_ops_models.dart';
import 'package:kaysir/features/hris/performance/models/performance_models.dart';
import 'package:kaysir/features/hris/recruitment/models/recruitment_models.dart';
import 'package:kaysir/features/hris/service_center/models/service_center_models.dart';
import 'package:kaysir/features/hris/talent/models/talent_models.dart';
import 'package:kaysir/features/hris/workforce_planning/models/workforce_planning_models.dart';

import '../models/dashboard_analytics.dart';
import '../models/dashboard_workspace_entry.dart';
import '../models/dashboard_workspace_risk_signal.dart';
import 'dashboard_operational_workspace_entries.dart';
import 'dashboard_strategic_workspace_entries.dart';

List<DashboardWorkspaceEntry> buildDashboardWorkspaceEntries({
  required CompanyManagementSummary companyManagementSummary,
  required PeopleOpsSummary peopleOpsSummary,
  required ComplianceSummary complianceSummary,
  required WorkforcePlanningSummary workforcePlanningSummary,
  required RecruitmentSummary recruitmentSummary,
  required TalentSummary talentSummary,
  required PerformanceSummary performanceSummary,
  required CompensationSummary compensationSummary,
  required EngagementSummary engagementSummary,
  required ServiceCenterSummary serviceCenterSummary,
  required DashboardOperationalWorkspaceSummaries operationalSummaries,
  DashboardRiskRollup? riskRollup,
}) {
  final riskSignals = buildDashboardWorkspaceRiskSignalMap(riskRollup);

  return [
    ...buildStrategicDashboardWorkspaceEntries(
      DashboardStrategicWorkspaceSummaries(
        companyManagement: companyManagementSummary,
        peopleOps: peopleOpsSummary,
        compliance: complianceSummary,
        workforcePlanning: workforcePlanningSummary,
        recruitment: recruitmentSummary,
        talent: talentSummary,
        performance: performanceSummary,
        compensation: compensationSummary,
        engagement: engagementSummary,
        serviceCenter: serviceCenterSummary,
      ),
      riskSignals: riskSignals,
    ),
    ...buildOperationalDashboardWorkspaceEntries(
      operationalSummaries,
      riskSignals: riskSignals,
    ),
  ];
}
