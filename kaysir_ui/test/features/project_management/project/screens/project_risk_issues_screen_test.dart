import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/screens/project_risk_issues_screen.dart';
import 'package:kaysir/features/project_management/project/widgets/project_risk_issue_workspace_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_risk_response_flow_panel.dart';

void main() {
  testWidgets('project risk issues screen renders risk workspace', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectRiskIssuesScreen(initialProjectId: 'warehouse-automation'),
      ),
    );

    expect(find.text('Project Risk & Issues'), findsWidgets);
    expect(
      find.textContaining('Warehouse Automation risk workspace'),
      findsOneWidget,
    );
    expect(find.text('Risk Response Flow'), findsOneWidget);
    expect(find.byType(ProjectRiskResponseFlowPanel), findsOneWidget);
    expect(find.text('Risk & Issue Board'), findsOneWidget);
    expect(find.byType(ProjectRiskIssueWorkspacePanel), findsOneWidget);
    expect(find.text('Risk and issues critical'), findsOneWidget);
  });

  testWidgets('project risk issues screen can switch selected project', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectRiskIssuesScreen(initialProjectId: 'warehouse-automation'),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retail Modernization').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Retail Modernization risk workspace'),
      findsOneWidget,
    );
    expect(find.text('Risk and issues need review'), findsOneWidget);
    expect(find.text('Risk and issues critical'), findsNothing);
  });

  testWidgets('project risk issues screen handles empty portfolios', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectRiskIssuesScreen(repository: _EmptyProjectRepository()),
      ),
    );

    expect(find.text('No projects available'), findsOneWidget);
    expect(
      find.textContaining('Add a project before triaging blockers'),
      findsOneWidget,
    );
  });
}

/// Test repository that allows the risk workspace empty state to be verified.
class _EmptyProjectRepository extends ProjectPortfolioRepository {
  const _EmptyProjectRepository();

  @override
  List<ProjectPortfolioItem> fetchProjects() => const [];
}
