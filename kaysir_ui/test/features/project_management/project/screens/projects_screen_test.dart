import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kaysir/features/project_management/project/data/project_created_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_view_repository.dart';
import 'package:kaysir/features/project_management/project/screens/projects_screen.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_gap_focus_service.dart';
import 'package:kaysir/features/project_management/project/services/project_priority_service.dart';
import 'package:kaysir/features/project_management/project/states/project_portfolio_provider.dart';
import 'package:kaysir/features/project_management/project/widgets/project_portfolio_components.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('project screen renders portfolio dashboard and filters search', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectPortfolioViewRepositoryProvider.overrideWithValue(
            ProjectPortfolioViewRepository(
              store: MemoryProjectPortfolioViewSnapshotStore(),
            ),
          ),
          projectCreatedPortfolioRepositoryProvider.overrideWithValue(
            ProjectCreatedPortfolioRepository(
              store: MemoryProjectCreatedPortfolioSnapshotStore(),
            ),
          ),
        ],
        child: const MaterialApp(home: ProjectScreen()),
      ),
    );

    expect(find.text('Project Portfolio'), findsOneWidget);
    expect(find.text('Board Briefing'), findsOneWidget);
    expect(find.text('Unblock Mobile Field App'), findsOneWidget);
    expect(find.byType(AppMetricGrid), findsNWidgets(2));
    expect(find.byType(AppSelectField<String>), findsOneWidget);
    expect(find.byType(AppSelectField<ProjectDomainGapFocus>), findsOneWidget);
    expect(
      find.byType(AppSelectField<ProjectPortfolioSortOption>),
      findsOneWidget,
    );
    expect(find.byType(ProjectPortfolioCard), findsNWidgets(4));
    expect(find.text('Needs Attention'), findsWidgets);
    expect(find.text('All Projects'), findsWidgets);
    expect(find.widgetWithText(ChoiceChip, 'Domain Gaps'), findsOneWidget);
    expect(find.text('Budget Pressure'), findsWidgets);
    expect(find.text('Retail Modernization'), findsOneWidget);

    final budgetPressureChip = find.widgetWithText(
      ChoiceChip,
      'Budget Pressure',
    );
    expect(budgetPressureChip, findsOneWidget);

    await tester.ensureVisible(budgetPressureChip);
    await tester.tap(budgetPressureChip);
    await tester.pump();

    expect(find.text('Warehouse Automation'), findsOneWidget);
    expect(find.text('Retail Modernization'), findsNothing);
    expect(find.text('Active view'), findsOneWidget);
    expect(find.text('1 of 4 projects'), findsOneWidget);

    await tester.ensureVisible(find.text('Clear View'));
    await tester.tap(find.text('Clear View'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectPortfolioCard), findsNWidgets(4));
    expect(find.text('Retail Modernization'), findsOneWidget);

    final gapFocusSelect = find.byKey(
      const ValueKey('project-board-domain-gap-focus-select'),
    );
    await tester.ensureVisible(gapFocusSelect);
    await tester.tap(gapFocusSelect);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Required Gaps').last);
    await tester.pumpAndSettle();

    expect(find.text('Required Gaps'), findsWidgets);
    expect(find.byType(ProjectPortfolioCard), findsNWidgets(3));
    expect(find.text('Retail Modernization'), findsNothing);

    await tester.ensureVisible(find.text('Clear View'));
    await tester.tap(find.text('Clear View'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectPortfolioCard), findsNWidgets(4));
    expect(find.text('Retail Modernization'), findsOneWidget);

    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.keyF,
    );
    await tester.pumpAndSettle();

    final searchTextField = find.byType(TextField);
    expect(
      tester.widget<TextField>(searchTextField).focusNode?.hasFocus,
      isTrue,
    );

    await tester.enterText(searchTextField, 'mobile');
    await tester.pump();

    expect(find.text('Mobile Field App'), findsOneWidget);
    expect(find.text('Retail Modernization'), findsNothing);
    expect(find.text('Active view'), findsOneWidget);
    expect(find.text('1 of 4 projects'), findsOneWidget);

    await _pressShortcut(
      tester,
      modifier: LogicalKeyboardKey.controlLeft,
      trigger: LogicalKeyboardKey.keyL,
      shift: true,
    );
    await tester.pumpAndSettle();

    expect(find.text('Active view'), findsNothing);
    expect(tester.widget<TextField>(searchTextField).controller?.text, isEmpty);
    expect(find.byType(ProjectPortfolioCard), findsNWidgets(4));
    expect(find.text('Retail Modernization'), findsOneWidget);
  });

  testWidgets('project screen opens focused gantt route from portfolio card', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/projects',
      routes: [
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectScreen(),
        ),
        GoRoute(
          path: '/gantt/chart',
          builder:
              (context, state) => Scaffold(
                body: Text(
                  'Focused Gantt: ${state.uri.queryParameters['project']}',
                ),
              ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectPortfolioViewRepositoryProvider.overrideWithValue(
            ProjectPortfolioViewRepository(
              store: MemoryProjectPortfolioViewSnapshotStore(),
            ),
          ),
          projectCreatedPortfolioRepositoryProvider.overrideWithValue(
            ProjectCreatedPortfolioRepository(
              store: MemoryProjectCreatedPortfolioSnapshotStore(),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final searchTextField = find.byType(TextField);
    await tester.enterText(searchTextField, 'mobile');
    await tester.pumpAndSettle();

    expect(find.text('Mobile Field App'), findsOneWidget);
    expect(find.text('Focus Gantt'), findsOneWidget);

    await tester.ensureVisible(find.text('Focus Gantt'));
    await tester.tap(find.text('Focus Gantt'));
    await tester.pumpAndSettle();

    expect(find.text('Focused Gantt: mobile-field-app'), findsOneWidget);
  });
}

Future<void> _pressShortcut(
  WidgetTester tester, {
  required LogicalKeyboardKey modifier,
  required LogicalKeyboardKey trigger,
  bool shift = false,
}) async {
  await tester.sendKeyDownEvent(modifier);
  if (shift) {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  }
  await tester.sendKeyEvent(trigger);
  if (shift) {
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  }
  await tester.sendKeyUpEvent(modifier);
}
