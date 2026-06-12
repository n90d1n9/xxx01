import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_action_summary.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/dashboard_analytics.dart';
import 'package:kaysir/features/hris/hr_dashboard/models/hris_workspace.dart';

import '../fixtures/dashboard_action_test_fixtures.dart';

void main() {
  const insightSummary = DashboardInsightSummary(
    averageDepartmentPerformance: 87,
    strongestDepartment: 'Sales',
    fastestImprovingDepartment: 'HR',
    totalHires: 95,
    peakHiringMonth: 'Jun',
    improvedMetricCount: 4,
  );

  test('dashboard action summary prioritizes critical risk work', () {
    final summary = DashboardActionSummary.fromSignals(
      insightSummary: insightSummary,
      riskRollup: DashboardRiskRollup(
        items: [
          DashboardRiskItem(
            workspace: hrisWorkspaceById(HrisWorkspaceId.manager),
            totalRisks: 12,
            timeSensitiveRisks: 6,
            leadingSignal: '6 urgent approvals',
          ),
          DashboardRiskItem(
            workspace: hrisWorkspaceById(HrisWorkspaceId.attendance),
            totalRisks: 4,
            timeSensitiveRisks: 1,
            leadingSignal: '1 late record',
          ),
        ],
      ),
    );

    expect(summary.recommendations.map((item) => item.id), [
      hrisDashboardCriticalActionId,
      hrisDashboardTimeSensitiveActionId,
      hrisDashboardScaleMomentumActionId,
    ]);
    expect(summary.primary?.title, hrisDashboardCriticalActionTitle);
    expect(summary.primary?.priority, DashboardActionPriority.critical);
    expect(summary.primary?.route, '/manager');
    expect(summary.primary?.ownerLabel, hrisDashboardCriticalOwnerLabel);
    expect(summary.primary?.dueLabel, hrisDashboardCriticalDueLabel);
    expect(
      summary.recommendations[1].ownerLabel,
      hrisDashboardTimeSensitiveOwnerLabel,
    );
    expect(
      summary.recommendations[1].dueLabel,
      hrisDashboardTimeSensitiveDueLabel,
    );
  });

  test('dashboard action summary flags weak KPI momentum', () {
    final summary = DashboardActionSummary.fromSignals(
      insightSummary: const DashboardInsightSummary(
        averageDepartmentPerformance: 72,
        strongestDepartment: 'Sales',
        fastestImprovingDepartment: 'Finance',
        totalHires: 24,
        peakHiringMonth: 'Mar',
        improvedMetricCount: 1,
      ),
      riskRollup: const DashboardRiskRollup(items: []),
    );

    expect(summary.recommendations, hasLength(1));
    expect(summary.primary?.id, 'recover-momentum');
    expect(summary.primary?.priority, DashboardActionPriority.high);
    expect(summary.primary?.ownerLabel, hrisDashboardCriticalOwnerLabel);
    expect(summary.primary?.dueLabel, '48 hours');
    expect(summary.primary?.description, contains('Only 1 KPIs improved'));
  });
}
