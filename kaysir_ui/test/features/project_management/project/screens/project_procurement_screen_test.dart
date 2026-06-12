import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/screens/project_procurement_screen.dart';
import 'package:kaysir/features/project_management/project/widgets/project_expense_intake_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_procurement_commitment_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_procurement_request_flow_panel.dart';

void main() {
  testWidgets('project procurement screen renders procurement workspace', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectProcurementScreen(
          initialProjectId: 'warehouse-automation',
        ),
      ),
    );

    expect(find.text('Project Procurement'), findsWidgets);
    expect(
      find.textContaining('Warehouse Automation procurement workspace'),
      findsOneWidget,
    );
    expect(find.text('Procurement Commitments'), findsOneWidget);
    expect(find.text('Procurement Request Flow'), findsOneWidget);
    expect(find.byType(ProjectProcurementRequestFlowPanel), findsOneWidget);
    expect(find.byType(ProjectProcurementCommitmentPanel), findsOneWidget);
    expect(find.byType(ProjectExpenseIntakePanel), findsOneWidget);
    expect(find.text('Procurement commitments blocked'), findsOneWidget);
  });

  testWidgets('project procurement screen can switch selected project', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectProcurementScreen(
          initialProjectId: 'warehouse-automation',
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retail Modernization').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Retail Modernization procurement workspace'),
      findsOneWidget,
    );
    expect(find.text('Procurement commitments need review'), findsOneWidget);
    expect(find.text('Procurement commitments blocked'), findsNothing);
  });

  testWidgets('project procurement screen handles empty portfolios', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectProcurementScreen(repository: _EmptyProjectRepository()),
      ),
    );

    expect(find.text('No projects available'), findsOneWidget);
    expect(
      find.textContaining('Add a project before tracking vendor commitments'),
      findsOneWidget,
    );
  });
}

/// Test repository that allows the procurement empty state to be verified.
class _EmptyProjectRepository extends ProjectPortfolioRepository {
  const _EmptyProjectRepository();

  @override
  List<ProjectPortfolioItem> fetchProjects() => const [];
}
