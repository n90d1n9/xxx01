import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_cadence_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test(
    'decision cadence builds review rhythm and agenda from open decisions',
    () {
      final workspace = buildProjectDecisionsWorkspaceSummary(
        project: demoProjectPortfolio.first,
        dependencyTasks: const [],
        today: DateTime(2026, 6, 11),
      );
      final cadence = workspace.decisionCadenceSummary;

      expect(cadence.signal, ProjectDecisionCadenceSignal.accelerated);
      expect(cadence.title, 'Decision cadence needs review');
      expect(cadence.reviewCadenceLabel, 'Twice-weekly decision review');
      expect(cadence.cadenceMetricLabel, '2x weekly');
      expect(cadence.escalationWindowLabel, contains('48h'));
      expect(cadence.ownerCount, greaterThan(0));
      expect(cadence.itemCount, greaterThanOrEqualTo(3));
      expect(
        cadence.items.map((item) => item.title),
        containsAll([
          'Run decision review',
          'Clear owner next action',
          'Lock decision proof',
        ]),
      );
      expect(
        cadence.agendaText,
        contains('Retail Modernization decision cadence agenda'),
      );
      expect(cadence.agendaText, contains('Agenda:'));
    },
  );
}
