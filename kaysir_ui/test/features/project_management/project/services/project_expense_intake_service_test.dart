import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_expense_intake_service.dart';

void main() {
  test(
    'expense intake summary prioritizes budget exceptions and missing controls',
    () {
      final summary = buildProjectExpenseIntakeSummary(
        _project(
          progress: 0.42,
          budgetUsed: 0.74,
          health: ProjectHealth.atRisk,
        ),
      );

      expect(summary.level, ProjectExpenseIntakeLevel.approvalRequired);
      expect(summary.routeCount, 4);
      expect(summary.readyCount, 0);
      expect(summary.setupNeededCount, 3);
      expect(summary.approvalRequiredCount, 1);
      expect(summary.title, 'Expense approvals required');
      expect(
        summary.routes.first.kind,
        ProjectExpenseIntakeKind.budgetException,
      );
      expect(
        summary.routes.map((route) => route.title),
        containsAll([
          'Submit budget recovery exception',
          'Configure project float',
          'Assign expense owner',
          'Prepare vendor spend route',
        ]),
      );
    },
  );

  test('expense intake summary is ready when finance controls exist', () {
    final summary = buildProjectExpenseIntakeSummary(
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
        ],
      ),
    );

    expect(summary.level, ProjectExpenseIntakeLevel.ready);
    expect(summary.routeCount, 3);
    expect(summary.readyCount, 3);
    expect(summary.setupNeededCount, 0);
    expect(summary.approvalRequiredCount, 0);
    expect(
      summary.detail,
      '3 of 3 routes ready - 3/3 finance controls configured.',
    );
  });
}

ProjectPortfolioItem _project({
  double progress = 0.5,
  double budgetUsed = 0.5,
  ProjectHealth health = ProjectHealth.onTrack,
  List<ProjectCustomAttribute> customAttributes = const [],
}) {
  return ProjectPortfolioItem(
    id: 'project-expense',
    name: 'Project Expense',
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 8, 1),
    progress: progress,
    budgetUsed: budgetUsed,
    health: health,
    milestones: const [],
    customAttributes: customAttributes,
  );
}
