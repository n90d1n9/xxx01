import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/screens/project_budget_changes_screen.dart';
import 'package:kaysir/features/project_management/project/widgets/project_budget_change_request_intake_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_budget_change_workspace_panel.dart';

void main() {
  testWidgets('project budget changes screen renders workspace panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectBudgetChangesScreen(
          initialProjectId: 'warehouse-automation',
        ),
      ),
    );

    expect(find.text('Project Budget Changes'), findsWidgets);
    expect(
      find.textContaining('Warehouse Automation budget-change workspace'),
      findsOneWidget,
    );
    expect(find.text('Budget Change Request Flow'), findsOneWidget);
    expect(find.text('Budget Change Workspace'), findsOneWidget);
    expect(find.byType(ProjectBudgetChangeRequestIntakePanel), findsOneWidget);
    expect(find.byType(ProjectBudgetChangeWorkspacePanel), findsOneWidget);
    expect(find.text('Budget variance recovery request'), findsOneWidget);
  });

  testWidgets('project budget changes screen can switch selected project', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectBudgetChangesScreen(
          initialProjectId: 'warehouse-automation',
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retail Modernization').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Retail Modernization budget-change workspace'),
      findsOneWidget,
    );
    expect(find.text('Evidence-bound budget change'), findsOneWidget);
    expect(find.text('Budget variance recovery request'), findsNothing);
  });

  testWidgets('project budget changes screen handles empty portfolios', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectBudgetChangesScreen(repository: _EmptyProjectRepository()),
      ),
    );

    expect(find.text('No projects available'), findsOneWidget);
    expect(
      find.textContaining('Add a project before preparing budget changes'),
      findsOneWidget,
    );
  });
}

/// Test repository that allows the budget-changes empty state to be verified.
class _EmptyProjectRepository extends ProjectPortfolioRepository {
  const _EmptyProjectRepository();

  @override
  List<ProjectPortfolioItem> fetchProjects() => const [];
}
