import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_finance_reconciliation_service.dart';

void main() {
  test(
    'finance reconciliation blocks closeout when budget exception is open',
    () {
      final summary = buildProjectFinanceReconciliationSummary(
        _project(
          progress: 0.42,
          budgetUsed: 0.74,
          health: ProjectHealth.atRisk,
        ),
        today: DateTime(2026, 6, 9),
      );

      expect(summary.level, ProjectFinanceReconciliationLevel.blocked);
      expect(summary.title, 'Finance reconciliation blocked');
      expect(summary.itemCount, 6);
      expect(summary.blockedCount, 6);
      expect(summary.cleanCount, 0);
      expect(
        summary.primaryItem.kind,
        ProjectFinanceReconciliationKind.budgetException,
      );
      expect(
        summary.items.map((item) => item.title),
        containsAll([
          'Reconcile budget exception',
          'Reconcile petty cash evidence',
          'Complete reimbursement proof',
          'Validate vendor delivery proof',
          'Review reserve guardrail',
          'Prepare finance closeout package',
        ]),
      );
    },
  );

  test(
    'finance reconciliation is clean when controls and runway are healthy',
    () {
      final summary = buildProjectFinanceReconciliationSummary(
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

      expect(summary.level, ProjectFinanceReconciliationLevel.clean);
      expect(summary.title, 'Finance reconciliation clean');
      expect(summary.itemCount, 5);
      expect(summary.cleanCount, 5);
      expect(summary.actionCount, 0);
      expect(summary.blockedCount, 0);
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
    id: 'project-reconciliation',
    name: 'Project Reconciliation',
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
    ],
    customAttributes: customAttributes,
  );
}
