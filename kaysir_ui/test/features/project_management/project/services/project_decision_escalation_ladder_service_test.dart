import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_escalation_ladder_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test('decision escalation ladder routes open records into tiers', () {
    final workspace = buildProjectDecisionsWorkspaceSummary(
      project: demoProjectPortfolio.first,
      dependencyTasks: const [],
      today: DateTime(2026, 6, 11),
    );
    final ladder = workspace.decisionEscalationLadderSummary;
    final tieredCount =
        ladder.sponsorCount +
        ladder.ownerCount +
        ladder.deliveryTeamCount +
        ladder.monitorCount;

    expect(ladder.openCount, workspace.decisionRegisterSummary.openCount);
    expect(ladder.stepCount, greaterThan(0));
    expect(tieredCount, ladder.openCount);
    expect(ladder.sponsorCount, greaterThan(0));
    expect(ladder.ownerCount, greaterThan(0));
    expect(ladder.primaryStep, isNotNull);
    expect(ladder.primaryStep!.tier, ProjectDecisionEscalationTier.sponsor);
    expect(ladder.signal, ProjectDecisionEscalationSignal.urgent);
    expect(ladder.briefText, contains('decision escalation ladder'));
    expect(ladder.briefText, contains('Escalation steps:'));
  });
}
