import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_cash_flow_forecast_service.dart';

void main() {
  test(
    'cash-flow forecast constrains releases when budget pressure is critical',
    () {
      final summary = buildProjectCashFlowForecastSummary(
        _project(
          progress: 0.42,
          budgetUsed: 0.74,
          health: ProjectHealth.atRisk,
        ),
        today: DateTime(2026, 6, 9),
      );

      expect(summary.level, ProjectCashFlowForecastLevel.constrained);
      expect(summary.title, 'Cash flow constrained');
      expect(summary.projectedAtCompletionPercent, 176);
      expect(summary.remainingBudgetPercent, 26);
      expect(summary.windowCount, 4);
      expect(summary.constrainedWindowCount, 4);
      expect(summary.nextWindow.kind, ProjectCashFlowWindowKind.active);
      expect(summary.nextWindow.releaseSharePercent, 9);
    },
  );

  test(
    'cash-flow forecast stays healthy when controls and pace are aligned',
    () {
      final summary = buildProjectCashFlowForecastSummary(
        _project(
          progress: 0.72,
          budgetUsed: 0.63,
          customAttributes: const [
            ProjectCustomAttribute(
              key: 'petty-cash-limit',
              label: 'Petty Cash Limit',
              type: ProjectCustomAttributeType.number,
              value: '5000000',
              unit: 'IDR',
            ),
            ProjectCustomAttribute(
              key: 'expense-owner',
              label: 'Expense Owner',
              type: ProjectCustomAttributeType.text,
              value: 'Site Finance',
            ),
            ProjectCustomAttribute(
              key: 'approval-threshold',
              label: 'Approval Threshold',
              type: ProjectCustomAttributeType.number,
              value: '1000000',
              unit: 'IDR',
            ),
            ProjectCustomAttribute(
              key: 'vendor-package',
              label: 'Vendor Package',
              type: ProjectCustomAttributeType.text,
              value: 'AV supplier',
            ),
          ],
        ),
        today: DateTime(2026, 6, 9),
      );

      expect(summary.level, ProjectCashFlowForecastLevel.healthy);
      expect(summary.title, 'Cash flow forecast healthy');
      expect(summary.projectedAtCompletionPercent, 88);
      expect(summary.remainingBudgetPercent, 37);
      expect(summary.windowCount, 4);
      expect(summary.constrainedWindowCount, 0);
      expect(summary.detail, contains('next gate: Pilot'));
    },
  );
}

ProjectPortfolioItem _project({
  double progress = 0.5,
  double budgetUsed = 0.5,
  ProjectHealth health = ProjectHealth.onTrack,
  List<ProjectCustomAttribute> customAttributes = const [],
}) {
  return ProjectPortfolioItem(
    id: 'project-cash-flow',
    name: 'Project Cash Flow',
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 8, 1),
    progress: progress,
    budgetUsed: budgetUsed,
    health: health,
    milestones: [
      ProjectMilestone(
        label: 'Pilot',
        dueDate: DateTime(2026, 6, 21),
        isComplete: false,
      ),
      ProjectMilestone(
        label: 'Launch',
        dueDate: DateTime(2026, 7, 21),
        isComplete: false,
      ),
    ],
    customAttributes: customAttributes,
  );
}
