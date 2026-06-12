import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_decision_record.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_workflow_board_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test('decision workflow board groups register records by status', () {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );
    final board = workspace.decisionWorkflowBoardSummary;

    expect(board.stageCount, ProjectDecisionStatus.values.length);
    expect(board.recordCount, workspace.decisionRegisterSummary.recordCount);
    expect(board.signal, ProjectDecisionWorkflowSignal.active);
    expect(board.awaitingCount, greaterThan(0));
    expect(board.reviewCount, greaterThan(0));
    expect(board.closedCount, greaterThan(0));
    expect(board.activeCount, greaterThan(0));
    expect(board.primaryStage.status, ProjectDecisionStatus.awaitingDecision);
    expect(board.snapshotText, contains('decision workflow board'));
    expect(board.snapshotText, contains('Workflow stages:'));
  });
}
