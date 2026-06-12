import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_cost_structure_service.dart';

void main() {
  test('cost structure adapts software delivery baseline', () {
    final summary = buildProjectCostStructureSummary(
      _project(
        businessDomain: 'Software Development',
        progress: 0.64,
        budgetUsed: 0.5,
        customAttributes: const [
          ProjectCustomAttribute(
            key: 'expense-owner',
            label: 'Expense Owner',
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
          ProjectCustomAttribute(
            key: 'vendor-package',
            label: 'Vendor Package',
            type: ProjectCustomAttributeType.text,
            value: 'QA lab',
          ),
        ],
      ),
    );

    expect(summary.profileLabel, 'Software delivery');
    expect(summary.categoryCount, 5);
    expect(summary.readyCount, 5);
    expect(summary.level, ProjectCostStructureLevel.ready);
    expect(summary.primaryLine.title, 'Product and engineering');
    expect(summary.contingencySharePercent, 10);
  });

  test('cost structure flags critical baseline when budget is pressured', () {
    final summary = buildProjectCostStructureSummary(
      _project(
        businessDomain: 'Construction',
        progress: 0.38,
        budgetUsed: 0.72,
        health: ProjectHealth.atRisk,
      ),
    );

    expect(summary.profileLabel, 'Construction delivery');
    expect(summary.level, ProjectCostStructureLevel.critical);
    expect(summary.criticalCount, greaterThan(0));
    expect(summary.title, 'Cost baseline needs reset');
    expect(summary.primaryLine.title, 'Materials and fixtures');
  });
}

ProjectPortfolioItem _project({
  String businessDomain = 'General Business',
  double progress = 0.5,
  double budgetUsed = 0.5,
  ProjectHealth health = ProjectHealth.onTrack,
  List<ProjectCustomAttribute> customAttributes = const [],
}) {
  return ProjectPortfolioItem(
    id: 'project-cost',
    name: 'Project Cost',
    owner: 'Owner',
    client: 'Client',
    businessDomain: businessDomain,
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 8, 1),
    progress: progress,
    budgetUsed: budgetUsed,
    health: health,
    milestones: const [],
    customAttributes: customAttributes,
  );
}
