import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_decision_record.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_decision_register_service.dart';
import 'package:kaysir/features/project_management/project/services/project_decisions_workspace_service.dart';

void main() {
  test(
    'decision register merges decision, governance, risk, and domain records',
    () {
      final workspace = buildProjectDecisionsWorkspaceSummary(
        project: demoProjectPortfolio.first,
        dependencyTasks: const [],
        today: DateTime(2026, 6, 11),
      );
      final register = workspace.decisionRegisterSummary;

      expect(register.recordCount, greaterThan(10));
      expect(register.openCount, greaterThan(0));
      expect(register.awaitingDecisionCount, greaterThan(0));
      expect(register.priorityRecord, isNotNull);
      expect(
        register.records.map((record) => record.source),
        containsAll([
          ProjectDecisionSource.nextDecision,
          ProjectDecisionSource.governance,
          ProjectDecisionSource.risk,
          ProjectDecisionSource.milestone,
          ProjectDecisionSource.domainExtension,
        ]),
      );
      expect(
        register
            .recordsFor(ProjectDecisionRegisterLens.domain)
            .map((record) => record.title),
        contains('Confirm Store Cluster'),
      );
      expect(
        register.countFor(ProjectDecisionRegisterLens.urgent),
        greaterThan(0),
      );
    },
  );

  test(
    'decision register creates records for missing required domain fields',
    () {
      final project = ProjectPortfolioItem(
        id: 'retail-gap',
        name: 'Retail Gap',
        owner: 'Maya',
        client: 'Retail Ops',
        sponsor: 'Retail Sponsor',
        businessDomain: 'Retail Operations',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 8, 1),
        progress: 0.2,
        budgetUsed: 0.32,
        health: ProjectHealth.atRisk,
        milestones: [
          ProjectMilestone(
            label: 'Launch Review',
            dueDate: DateTime(2026, 6, 20),
            isComplete: false,
          ),
        ],
      );
      final workspace = buildProjectDecisionsWorkspaceSummary(
        project: project,
        dependencyTasks: const [],
        today: DateTime(2026, 6, 11),
      );
      final domainTitles =
          workspace.decisionRegisterSummary
              .recordsFor(ProjectDecisionRegisterLens.domain)
              .map((record) => record.title)
              .toList();

      expect(
        domainTitles,
        containsAll(['Capture Store Cluster', 'Capture Launch Wave']),
      );
    },
  );
}
