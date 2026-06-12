import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_readiness_gate_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test('decision readiness gate scores and groups decision records', () {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );
    final gate = workspace.decisionReadinessGateSummary;
    final laneCount =
        gate.blockedCount +
        gate.needsDecisionCount +
        gate.needsEvidenceCount +
        gate.readyCount;

    expect(gate.recordCount, workspace.decisionRegisterSummary.recordCount);
    expect(laneCount, gate.recordCount);
    expect(gate.averageScore, inInclusiveRange(0, 100));
    expect(gate.laneCount, greaterThan(0));
    expect(gate.primaryLane, isNotNull);
    expect(ProjectDecisionReadinessSignal.values, contains(gate.signal));
    expect(gate.needsDecisionCount, greaterThan(0));
    expect(gate.briefText, contains('decision readiness gate'));
    expect(gate.briefText, contains('Readiness lanes:'));
  });
}
