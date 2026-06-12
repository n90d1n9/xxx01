import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/screens/project_approvals_screen.dart';
import 'package:kaysir/features/project_management/project/widgets/project_approval_action_flow_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_approval_workspace_panel.dart';

void main() {
  testWidgets('project approvals screen renders workspace panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectApprovalsScreen(initialProjectId: 'warehouse-automation'),
      ),
    );

    expect(find.text('Project Approvals'), findsWidgets);
    expect(
      find.textContaining('Warehouse Automation approvals workspace'),
      findsOneWidget,
    );
    expect(find.text('Approval Action Flow'), findsOneWidget);
    expect(find.text('Approval Workspace'), findsOneWidget);
    expect(find.byType(ProjectApprovalActionFlowPanel), findsOneWidget);
    expect(find.byType(ProjectApprovalWorkspacePanel), findsOneWidget);
    expect(find.text('Budget variance recovery request'), findsWidgets);
  });

  testWidgets('project approvals screen can switch selected project', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectApprovalsScreen(initialProjectId: 'warehouse-automation'),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retail Modernization').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Retail Modernization approvals workspace'),
      findsOneWidget,
    );
    expect(find.text('Contingency release request'), findsWidgets);
    expect(find.text('Freight acceleration exception'), findsNothing);
  });

  testWidgets('project approvals screen handles empty portfolios', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectApprovalsScreen(repository: _EmptyProjectRepository()),
      ),
    );

    expect(find.text('No projects available'), findsOneWidget);
    expect(
      find.textContaining('Add a project before routing spend authority'),
      findsOneWidget,
    );
  });
}

/// Test repository that allows the approvals empty state to be verified.
class _EmptyProjectRepository extends ProjectPortfolioRepository {
  const _EmptyProjectRepository();

  @override
  List<ProjectPortfolioItem> fetchProjects() => const [];
}
