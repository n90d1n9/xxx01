import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/screens/project_petty_cash_screen.dart';
import 'package:kaysir/features/project_management/project/widgets/project_petty_cash_request_intake_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_petty_cash_workspace_panel.dart';

void main() {
  testWidgets('project petty cash screen renders workspace panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectPettyCashScreen(initialProjectId: 'retail-modernization'),
      ),
    );

    expect(find.text('Project Petty Cash'), findsWidgets);
    expect(
      find.textContaining('Retail Modernization petty-cash workspace'),
      findsOneWidget,
    );
    expect(find.text('Petty Cash Request Flow'), findsOneWidget);
    expect(find.text('Petty Cash Workspace'), findsOneWidget);
    expect(find.byType(ProjectPettyCashRequestIntakePanel), findsOneWidget);
    expect(find.byType(ProjectPettyCashWorkspacePanel), findsOneWidget);
    expect(find.text('Pilot store project float'), findsOneWidget);
  });

  testWidgets('project petty cash screen can switch selected project', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectPettyCashScreen(initialProjectId: 'retail-modernization'),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Warehouse Automation').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Warehouse Automation petty-cash workspace'),
      findsOneWidget,
    );
    expect(find.text('Fulfillment floor float'), findsOneWidget);
    expect(find.text('Pilot store project float'), findsNothing);
  });

  testWidgets('project petty cash screen handles empty project portfolios', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectPettyCashScreen(repository: _EmptyProjectRepository()),
      ),
    );

    expect(find.text('No projects available'), findsOneWidget);
    expect(
      find.textContaining('Add a project before managing petty cash'),
      findsOneWidget,
    );
  });
}

/// Test repository that allows the petty-cash empty state to be verified.
class _EmptyProjectRepository extends ProjectPortfolioRepository {
  const _EmptyProjectRepository();

  @override
  List<ProjectPortfolioItem> fetchProjects() => const [];
}
