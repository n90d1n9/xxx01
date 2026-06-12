import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_created_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_form_focus.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/project_management_routes.dart';
import 'package:kaysir/features/project_management/project/screens/project_form_screen.dart';
import 'package:kaysir/features/project_management/project/states/project_portfolio_provider.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_edit_guard_state.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_loading_state.dart';
import 'package:kaysir/features/project_management/project/widgets/project_form_panel.dart';

void main() {
  test('project form focus parses attributes query value', () {
    expect(
      projectFormPanelFocusFromQuery('attributes'),
      ProjectFormPanelFocus.domainExtensions,
    );
    expect(
      projectFormPanelFocusFromQuery('domain_extensions'),
      ProjectFormPanelFocus.domainExtensions,
    );
    expect(
      projectFormFocusedAttributeKeyFromQuery('Repository URL'),
      'repository-url',
    );
    expect(projectFormPanelFocusFromQuery(null), ProjectFormPanelFocus.none);
    expect(
      ProjectManagementRoutes.formUri(
        projectId: ' field-app ',
        focusedAttributeKey: 'Repository',
      ),
      '/project-form?project=field-app&focus=attributes&attribute=repository',
    );
  });

  testWidgets('project form screen validates and submits a draft', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectCreatedPortfolioRepositoryProvider.overrideWithValue(
            ProjectCreatedPortfolioRepository(
              store: MemoryProjectCreatedPortfolioSnapshotStore(),
            ),
          ),
        ],
        child: const MaterialApp(home: ProjectFormScreen()),
      ),
    );

    expect(find.text('Create Project'), findsOneWidget);
    expect(find.byType(ProjectFormPanel), findsOneWidget);
    expect(find.text('Construction'), findsWidgets);
    expect(find.byTooltip('Open project table'), findsOneWidget);
    expect(find.byTooltip('Open project dashboard'), findsOneWidget);
    expect(find.byTooltip('Open project detail'), findsNothing);

    await tester.ensureVisible(find.text('Add Project'));
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();

    expect(find.text('Project name is required.'), findsOneWidget);
    expect(find.text('Client or business unit is required.'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Campus Renovation');
    await tester.enterText(fields.at(1), 'Education Office');
    await tester.enterText(fields.at(2), 'Dewi Lestari');
    await tester.enterText(fields.at(3), 'Academic Operations');
    await tester.enterText(
      fields.at(4),
      'Coordinates classroom renovation, inspection proof, and opening readiness.',
    );

    await tester.ensureVisible(find.text('Add Project'));
    await tester.tap(find.text('Add Project'));
    await tester.pump();

    expect(find.text('Project created: Campus Renovation'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'View'), findsOneWidget);
  });

  testWidgets('project form screen edits a local project', (tester) async {
    final store = MemoryProjectCreatedPortfolioSnapshotStore();
    final repository = ProjectCreatedPortfolioRepository(store: store);
    await repository.save([_project()]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectCreatedPortfolioRepositoryProvider.overrideWithValue(
            repository,
          ),
        ],
        child: const MaterialApp(
          home: ProjectFormScreen(projectId: 'campus-renovation'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Project'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
    expect(find.text('Campus Renovation'), findsWidgets);
    expect(find.byTooltip('Open project detail'), findsOneWidget);
    expect(find.byTooltip('Open project table'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Campus Phase 2');
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pump();

    expect(find.text('Project updated: Campus Phase 2'), findsOneWidget);
    expect(find.widgetWithText(SnackBarAction, 'View'), findsOneWidget);
  });

  testWidgets('project form screen guards non-local edit targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectCreatedPortfolioRepositoryProvider.overrideWithValue(
            ProjectCreatedPortfolioRepository(
              store: MemoryProjectCreatedPortfolioSnapshotStore(),
            ),
          ),
        ],
        child: const MaterialApp(
          home: ProjectFormScreen(projectId: 'retail-modernization'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormEditGuardState), findsOneWidget);
    expect(find.text('Project cannot be edited'), findsOneWidget);
    expect(find.text('Open Project Table'), findsOneWidget);
    expect(find.text('Back to Projects'), findsOneWidget);
  });

  testWidgets('project form screen shows loading state while hydrating edits', (
    tester,
  ) async {
    final hydration = Completer<void>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createdProjectPortfolioHydrationProvider.overrideWith(
            (ref) => hydration.future,
          ),
        ],
        child: const MaterialApp(
          home: ProjectFormScreen(projectId: 'campus-renovation'),
        ),
      ),
    );

    expect(find.byType(ProjectFormLoadingState), findsOneWidget);
    expect(find.text('Loading project form'), findsOneWidget);
    expect(find.textContaining('campus-renovation'), findsOneWidget);
  });
}

ProjectPortfolioItem _project() {
  return ProjectPortfolioItem(
    id: 'campus-renovation',
    name: 'Campus Renovation',
    owner: 'Dewi Lestari',
    client: 'Education Office',
    sponsor: 'Academic Operations',
    businessDomain: 'Education Program',
    summary:
        'Coordinates classroom renovation, inspection proof, and opening readiness.',
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.2,
    budgetUsed: 0.1,
    health: ProjectHealth.onTrack,
    milestones: const [],
  );
}
