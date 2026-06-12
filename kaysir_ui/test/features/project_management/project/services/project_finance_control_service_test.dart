import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_control_service.dart';

void main() {
  test(
    'finance control summary escalates budget pressure and missing policy',
    () {
      final summary = buildProjectFinanceControlSummary(
        _project(
          progress: 0.42,
          budgetUsed: 0.74,
          health: ProjectHealth.atRisk,
          risks: const [
            ProjectDeliveryRisk(
              title: 'Budget pressure',
              detail: 'Supplier costs need approval before the next order.',
              severity: ProjectHealth.atRisk,
            ),
          ],
        ),
      );

      expect(summary.level, ProjectFinanceControlLevel.actionRequired);
      expect(summary.configuredControlCount, 0);
      expect(summary.actionCount, greaterThanOrEqualTo(4));
      expect(summary.title, 'Finance action required');
      expect(
        summary.signals.map((signal) => signal.title),
        containsAll([
          'Approve budget recovery',
          'Define project float',
          'Assign expense owner',
          'Set approval threshold',
          'Resolve finance risk',
        ]),
      );
    },
  );

  test('finance control summary uses adaptive software finance labels', () {
    final summary = buildProjectFinanceControlSummary(
      _project(
        businessDomain: 'Software Development',
        customAttributes: const [
          ProjectCustomAttribute(
            key: 'expense-reserve',
            label: 'Expense Reserve',
            type: ProjectCustomAttributeType.number,
            value: '4000',
            unit: 'USD',
          ),
          ProjectCustomAttribute(
            key: 'finance-owner',
            label: 'Finance Owner',
            type: ProjectCustomAttributeType.text,
            value: 'Cloud FinOps',
          ),
          ProjectCustomAttribute(
            key: 'approval-threshold',
            label: 'Approval Threshold',
            type: ProjectCustomAttributeType.number,
            value: '1000',
            unit: 'USD',
          ),
        ],
      ),
    );

    expect(summary.profile.floatLabel, 'Expense reserve');
    expect(summary.profile.expenseOwnerLabel, 'Vendor or cloud spend owner');
    expect(summary.configuredControlCount, 3);
    expect(summary.level, ProjectFinanceControlLevel.stable);
    expect(summary.actionCount, 0);
    expect(summary.title, 'Finance controls ready');
  });
}

ProjectPortfolioItem _project({
  String businessDomain = 'General Business',
  double progress = 0.62,
  double budgetUsed = 0.58,
  ProjectHealth health = ProjectHealth.onTrack,
  List<ProjectDeliveryRisk> risks = const [],
  List<ProjectCustomAttribute> customAttributes = const [],
}) {
  return ProjectPortfolioItem(
    id: 'project-finance',
    name: 'Project Finance',
    owner: 'Owner',
    client: 'Client',
    businessDomain: businessDomain,
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 8, 1),
    progress: progress,
    budgetUsed: budgetUsed,
    health: health,
    milestones: const [],
    risks: risks,
    customAttributes: customAttributes,
  );
}
