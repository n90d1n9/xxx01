import 'dashboard_analytics.dart';
import 'dashboard_action_summary.dart';
import 'dashboard_workspace_entry.dart';
import 'hr_metric.dart';
import 'report_type.dart';

class HRDashboardViewModel {
  final String selectedPeriod;
  final bool isLoading;
  final DateTime lastUpdated;
  final List<HRMetric> hrMetrics;
  final List<ReportType> reportTypes;
  final List<DepartmentPerformancePoint> departmentPerformance;
  final List<HiringTrendPoint> hiringTrends;
  final DashboardInsightSummary insightSummary;
  final DashboardRiskRollup riskRollup;
  final DashboardActionSummary actionSummary;
  final List<DashboardWorkspaceEntry> workspaceEntries;

  const HRDashboardViewModel({
    required this.selectedPeriod,
    required this.isLoading,
    required this.lastUpdated,
    required this.hrMetrics,
    required this.reportTypes,
    required this.departmentPerformance,
    required this.hiringTrends,
    required this.insightSummary,
    required this.riskRollup,
    required this.actionSummary,
    required this.workspaceEntries,
  });
}
