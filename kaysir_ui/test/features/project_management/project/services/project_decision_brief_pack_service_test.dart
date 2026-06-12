import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_brief_pack_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test('decision brief pack builds copy-ready sponsor and team context', () {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );
    final briefPack = workspace.decisionBriefPackSummary;

    expect(briefPack.signal, ProjectDecisionBriefPackSignal.attention);
    expect(briefPack.title, 'Retail Modernization decision brief pack');
    expect(briefPack.routeLabel, contains('Retail'));
    expect(briefPack.primaryDecisionLabel, isNotEmpty);
    expect(briefPack.ownerFocusLabel, contains(':'));
    expect(briefPack.highlightCount, 4);
    expect(briefPack.actionCount, greaterThan(0));
    expect(briefPack.evidenceCount, greaterThan(1));
    expect(briefPack.briefText, contains('Highlights:'));
    expect(briefPack.briefText, contains('Actions:'));
    expect(briefPack.briefText, contains('Evidence:'));
  });
}
