import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_action_plan_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test('decision action plan groups open register records by owner', () {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );
    final actionPlan = buildProjectDecisionActionPlan(
      workspace.decisionRegisterSummary,
    );

    expect(actionPlan.ownerCount, greaterThanOrEqualTo(2));
    expect(actionPlan.openCount, workspace.decisionRegisterSummary.openCount);
    expect(actionPlan.awaitingCount, greaterThan(0));
    expect(actionPlan.signal, ProjectDecisionOwnerSignal.attention);
    expect(actionPlan.primaryAction, isNotNull);
    expect(
      actionPlan.ownerActions.map((action) => action.owner),
      containsAll(['Maya Santoso', 'Retail Operations']),
    );
    expect(actionPlan.ownerActions.first.sourceMixLabel, isNotEmpty);
  });
}
