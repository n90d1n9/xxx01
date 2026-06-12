import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/screens/project_evidence_vault_screen.dart';
import 'package:kaysir/features/project_management/project/widgets/project_evidence_vault_panel.dart';

void main() {
  testWidgets('project evidence vault screen renders workspace panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectEvidenceVaultScreen(
          initialProjectId: 'warehouse-automation',
        ),
      ),
    );

    expect(find.text('Project Evidence Vault'), findsWidgets);
    expect(
      find.textContaining('Warehouse Automation evidence vault'),
      findsOneWidget,
    );
    expect(find.text('Evidence Vault'), findsOneWidget);
    expect(find.byType(ProjectEvidenceVaultPanel), findsOneWidget);
    expect(find.text('Freight exception evidence'), findsOneWidget);
  });

  testWidgets('project evidence vault screen can switch selected project', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectEvidenceVaultScreen(
          initialProjectId: 'warehouse-automation',
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retail Modernization').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Retail Modernization evidence vault'),
      findsOneWidget,
    );
    expect(find.text('Training delivery proof'), findsOneWidget);
    expect(find.text('Freight exception evidence'), findsNothing);
  });

  testWidgets('project evidence vault screen handles empty portfolios', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectEvidenceVaultScreen(repository: _EmptyProjectRepository()),
      ),
    );

    expect(find.text('No projects available'), findsOneWidget);
    expect(
      find.textContaining('Add a project before organizing receipts'),
      findsOneWidget,
    );
  });
}

/// Test repository that allows the evidence-vault empty state to be verified.
class _EmptyProjectRepository extends ProjectPortfolioRepository {
  const _EmptyProjectRepository();

  @override
  List<ProjectPortfolioItem> fetchProjects() => const [];
}
