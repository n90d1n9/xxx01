import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_spend_authority_service.dart';

void main() {
  test(
    'spend authority delegates bands when finance controls are configured',
    () {
      final summary = buildProjectSpendAuthoritySummary(
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
      );

      expect(summary.level, ProjectSpendAuthorityLevel.delegated);
      expect(summary.ruleCount, 3);
      expect(summary.delegatedCount, 3);
      expect(summary.guardedCount, 0);
      expect(summary.escalationCount, 0);
      expect(summary.title, 'Spend authority delegated');
    },
  );

  test('spend authority escalates bands when budget pressure is critical', () {
    final summary = buildProjectSpendAuthoritySummary(
      _project(progress: 0.42, budgetUsed: 0.74, health: ProjectHealth.atRisk),
    );

    expect(summary.level, ProjectSpendAuthorityLevel.escalation);
    expect(summary.ruleCount, 4);
    expect(summary.delegatedCount, 0);
    expect(summary.escalationCount, 4);
    expect(summary.title, 'Spend escalation required');
    expect(summary.rules.first.band, ProjectSpendAuthorityBand.budgetException);
    expect(
      summary.rules.map((rule) => rule.title),
      containsAll([
        'Budget exception authority',
        'Project float authority',
        'Reimbursement authority',
        'Vendor commitment authority',
      ]),
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
    id: 'project-authority',
    name: 'Project Authority',
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
