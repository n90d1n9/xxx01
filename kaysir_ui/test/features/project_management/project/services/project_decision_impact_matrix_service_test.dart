import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_impact_matrix_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test('decision impact matrix scores operational consequence by area', () {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );
    final matrix = workspace.decisionImpactMatrixSummary;

    expect(matrix.itemCount, workspace.decisionRegisterSummary.recordCount);
    expect(matrix.impactIndex, greaterThan(0));
    expect(matrix.elevatedCount, greaterThan(0));
    expect(matrix.ownerCount, greaterThan(0));
    expect(matrix.primaryItem, isNotNull);
    expect(matrix.impactText, contains('decision impact matrix'));
    expect(matrix.impactText, contains('Impact priorities:'));
    expect(
      matrix.items.map((item) => item.area),
      containsAll([
        ProjectDecisionImpactArea.delivery,
        ProjectDecisionImpactArea.governance,
        ProjectDecisionImpactArea.risk,
        ProjectDecisionImpactArea.milestone,
        ProjectDecisionImpactArea.domain,
      ]),
    );
  });
}
