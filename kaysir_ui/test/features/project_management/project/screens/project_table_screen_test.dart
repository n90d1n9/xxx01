import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_created_portfolio_repository.dart';
import 'package:kaysir/features/project_management/project/data/project_portfolio_view_repository.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/screens/project_table_screen.dart';
import 'package:kaysir/features/project_management/project/services/project_table_view_service.dart';
import 'package:kaysir/features/project_management/project/states/project_portfolio_provider.dart';
import 'package:kaysir/features/project_management/project/widgets/project_table.dart';

void main() {
  testWidgets(
    'project table screen renders project records and filters search',
    (tester) async {
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
          child: const MaterialApp(home: ProjectTableScreen()),
        ),
      );

      expect(find.text('Project Table'), findsWidgets);
      expect(find.text('Project Records'), findsOneWidget);
      expect(find.text('Operations Profile'), findsOneWidget);
      expect(find.byType(ProjectPortfolioTable), findsOneWidget);
      expect(find.text('Retail Modernization'), findsOneWidget);
      expect(find.text('Warehouse Automation'), findsOneWidget);
      expect(find.text('New Project'), findsOneWidget);

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
      expect(find.text('1 of 4 projects'), findsOneWidget);

      await _pressShortcut(
        tester,
        modifier: LogicalKeyboardKey.controlLeft,
        trigger: LogicalKeyboardKey.keyL,
        shift: true,
      );
      await tester.pumpAndSettle();

      expect(find.text('Active view'), findsNothing);
      expect(
        tester.widget<TextField>(searchTextField).controller?.text,
        isEmpty,
      );
      expect(find.text('Retail Modernization'), findsOneWidget);
      expect(find.text('Warehouse Automation'), findsOneWidget);
    },
  );

  testWidgets('project table saved views recommend adaptive profiles', (
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
        child: const MaterialApp(home: ProjectTableScreen()),
      ),
    );

    expect(
      _visibleTableColumns(tester),
      equals(ProjectTableColumnProfile.operations.columns),
    );

    final budgetPressureChip = find.widgetWithText(
      ChoiceChip,
      'Budget Pressure',
    );
    await tester.ensureVisible(budgetPressureChip);
    await tester.tap(budgetPressureChip);
    await tester.pump();

    expect(find.text('Financial Profile'), findsOneWidget);
    expect(
      _visibleTableColumns(tester),
      equals(ProjectTableColumnProfile.financial.columns),
    );

    final domainGapsChip = find.widgetWithText(ChoiceChip, 'Domain Gaps');
    await tester.ensureVisible(domainGapsChip);
    await tester.tap(domainGapsChip);
    await tester.pump();

    expect(find.text('Domain Context Profile'), findsOneWidget);
    expect(
      _visibleTableColumns(tester),
      equals(ProjectTableColumnProfile.domainContext.columns),
    );
    expect(_customTableColumnKeys(tester), contains('workstream'));
    expect(find.text('Domain Gap Workbench'), findsOneWidget);
    expect(find.text('Any Field Gaps'), findsWidgets);
    expect(find.text('Workstream'), findsOneWidget);

    final requiredGapFocus = find.byKey(
      const ValueKey('project-table-brief-required-gap-focus'),
    );
    await tester.ensureVisible(requiredGapFocus);
    await tester.tap(requiredGapFocus);
    await tester.pumpAndSettle();

    expect(find.text('Required Gaps'), findsWidgets);
    expect(find.text('Retail Modernization'), findsNothing);
    expect(find.text('Mobile Field App'), findsOneWidget);
    expect(find.text('Warehouse Automation'), findsOneWidget);
    expect(find.text('Finance Close Suite'), findsOneWidget);
  });

  testWidgets('project table repair queue focuses domain gap filters', (
    tester,
  ) async {
    final createdStore = MemoryProjectCreatedPortfolioSnapshotStore();
    await ProjectCreatedPortfolioRepository(
      store: createdStore,
    ).save([_createdSoftwareProject()]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          projectPortfolioViewRepositoryProvider.overrideWithValue(
            ProjectPortfolioViewRepository(
              store: MemoryProjectPortfolioViewSnapshotStore(),
            ),
          ),
          projectCreatedPortfolioRepositoryProvider.overrideWithValue(
            ProjectCreatedPortfolioRepository(store: createdStore),
          ),
        ],
        child: const MaterialApp(home: ProjectTableScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final domainGapsChip = find.widgetWithText(ChoiceChip, 'Domain Gaps');
    await tester.ensureVisible(domainGapsChip);
    await tester.tap(domainGapsChip);
    await tester.pumpAndSettle();

    final requiredFocus = find.byKey(
      const ValueKey('project-domain-gap-repair-focus-requiredField'),
    );
    await tester.ensureVisible(requiredFocus);
    await tester.tap(requiredFocus);
    await tester.pumpAndSettle();

    expect(find.text('Required Gaps'), findsWidgets);
    expect(find.text('Created Release Hub'), findsOneWidget);
    expect(
      _visibleTableColumns(tester),
      equals(ProjectTableColumnProfile.domainContext.columns),
    );
  });
}

Set<ProjectTableColumn> _visibleTableColumns(WidgetTester tester) {
  return tester
      .widget<ProjectPortfolioTable>(find.byType(ProjectPortfolioTable))
      .visibleColumns;
}

List<String> _customTableColumnKeys(WidgetTester tester) {
  return tester
      .widget<ProjectPortfolioTable>(find.byType(ProjectPortfolioTable))
      .customColumns
      .map((column) => column.key)
      .toList(growable: false);
}

ProjectPortfolioItem _createdSoftwareProject() {
  return ProjectPortfolioItem(
    id: 'created-release-hub',
    name: 'Created Release Hub',
    owner: 'Nadia Putri',
    client: 'Service Team',
    businessDomain: 'Software Development',
    startDate: DateTime(2026, 6),
    endDate: DateTime(2026, 8),
    progress: 0.28,
    budgetUsed: 0.32,
    health: ProjectHealth.atRisk,
    milestones: const [],
  );
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
