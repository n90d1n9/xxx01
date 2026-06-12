import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/screens/project_decisions_screen.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_action_plan_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_brief_pack_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_cadence_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_escalation_ladder_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_evidence_intake_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_evidence_matrix_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_governance_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_impact_matrix_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_intake_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_readiness_gate_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_register_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_review_flow_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_sla_tracker_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_decision_workflow_board_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_next_decision_panel.dart';

void main() {
  testWidgets('project decisions screen renders governance workspace', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProjectDecisionsScreen(initialProjectId: 'mobile-field-app'),
        ),
      ),
    );

    expect(find.text('Project Decisions'), findsWidgets);
    expect(
      find.textContaining('Mobile Field App decisions workspace'),
      findsOneWidget,
    );
    expect(find.text('Decision Intake Flow'), findsOneWidget);
    expect(find.text('Decision Review Flow'), findsOneWidget);
    expect(find.text('Decision Evidence Intake'), findsOneWidget);
    expect(find.text('Decision Brief Pack'), findsOneWidget);
    expect(find.text('Decision Cadence'), findsOneWidget);
    expect(find.text('Decision Evidence Matrix'), findsOneWidget);
    expect(find.text('Decision Impact Matrix'), findsOneWidget);
    expect(find.text('Decision Workflow Board'), findsOneWidget);
    expect(find.text('Decision Escalation Ladder'), findsOneWidget);
    expect(find.text('Decision SLA Tracker'), findsOneWidget);
    expect(find.text('Decision Readiness Gate'), findsOneWidget);
    expect(find.text('Next Decisions'), findsOneWidget);
    expect(find.text('Decision Governance'), findsOneWidget);
    expect(find.text('Owner Action Plan'), findsOneWidget);
    expect(find.text('Decision Register'), findsOneWidget);
    expect(find.byType(ProjectDecisionIntakePanel), findsOneWidget);
    expect(find.byType(ProjectDecisionReviewFlowPanel), findsOneWidget);
    expect(find.byType(ProjectDecisionEvidenceIntakePanel), findsOneWidget);
    expect(find.byType(ProjectNextDecisionPanel), findsOneWidget);
    expect(find.byType(ProjectDecisionBriefPackPanel), findsOneWidget);
    expect(find.byType(ProjectDecisionCadencePanel), findsOneWidget);
    expect(find.byType(ProjectDecisionEvidenceMatrixPanel), findsOneWidget);
    expect(find.byType(ProjectDecisionImpactMatrixPanel), findsOneWidget);
    expect(find.byType(ProjectDecisionWorkflowBoardPanel), findsOneWidget);
    expect(find.byType(ProjectDecisionEscalationLadderPanel), findsOneWidget);
    expect(find.byType(ProjectDecisionSlaTrackerPanel), findsOneWidget);
    expect(find.byType(ProjectDecisionReadinessGatePanel), findsOneWidget);
    expect(find.byType(ProjectDecisionGovernancePanel), findsOneWidget);
    expect(find.byType(ProjectDecisionActionPlanPanel), findsOneWidget);
    expect(find.byType(ProjectDecisionRegisterPanel), findsOneWidget);
    expect(find.text('Software decision governance'), findsOneWidget);
  });

  testWidgets('project decisions screen can switch selected project', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProjectDecisionsScreen(initialProjectId: 'mobile-field-app'),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retail Modernization').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Retail Modernization decisions workspace'),
      findsOneWidget,
    );
    expect(find.text('Retail decision governance'), findsOneWidget);
    expect(
      find.textContaining('Mobile Field App decisions workspace'),
      findsNothing,
    );
  });

  testWidgets('project decisions screen handles empty portfolios', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProjectDecisionsScreen(repository: _EmptyProjectRepository()),
        ),
      ),
    );

    expect(find.text('No projects available'), findsOneWidget);
    expect(
      find.textContaining('Add a project before preparing next decisions'),
      findsOneWidget,
    );
  });
}

/// Test repository that allows the decisions workspace empty state to be verified.
class _EmptyProjectRepository extends ProjectPortfolioRepository {
  const _EmptyProjectRepository();

  @override
  List<ProjectPortfolioItem> fetchProjects() => const [];
}
