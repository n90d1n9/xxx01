import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/screens/project_funding_releases_screen.dart';
import 'package:kaysir/features/project_management/project/widgets/project_cash_flow_forecast_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_funding_release_request_intake_panel.dart';
import 'package:kaysir/features/project_management/project/widgets/project_funding_release_panel.dart';

void main() {
  testWidgets('project funding releases screen renders release workspace', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectFundingReleasesScreen(
          initialProjectId: 'warehouse-automation',
        ),
      ),
    );

    expect(find.text('Project Funding Releases'), findsWidgets);
    expect(
      find.textContaining('Warehouse Automation funding release workspace'),
      findsOneWidget,
    );
    expect(find.text('Funding Release Request Flow'), findsOneWidget);
    expect(find.text('Funding Release Board'), findsOneWidget);
    expect(
      find.byType(ProjectFundingReleaseRequestIntakePanel),
      findsOneWidget,
    );
    expect(find.byType(ProjectFundingReleasePanel), findsOneWidget);
    expect(find.byType(ProjectCashFlowForecastPanel), findsOneWidget);
    expect(find.text('Funding releases blocked'), findsOneWidget);
  });

  testWidgets('project funding releases screen can switch selected project', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectFundingReleasesScreen(
          initialProjectId: 'warehouse-automation',
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retail Modernization').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Retail Modernization funding release workspace'),
      findsOneWidget,
    );
    expect(find.text('Funding releases need review'), findsOneWidget);
    expect(find.text('Funding releases blocked'), findsNothing);
  });

  testWidgets('project funding releases screen handles empty portfolios', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectFundingReleasesScreen(
          repository: _EmptyProjectRepository(),
        ),
      ),
    );

    expect(find.text('No projects available'), findsOneWidget);
    expect(
      find.textContaining('Add a project before planning funding windows'),
      findsOneWidget,
    );
  });
}

/// Test repository that allows the funding release empty state to be verified.
class _EmptyProjectRepository extends ProjectPortfolioRepository {
  const _EmptyProjectRepository();

  @override
  List<ProjectPortfolioItem> fetchProjects() => const [];
}
