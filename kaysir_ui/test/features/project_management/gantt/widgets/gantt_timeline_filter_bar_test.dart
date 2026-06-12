import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/data/gantt_chart_workspace_preferences_repository.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_filter_presentation_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_preferences_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_timeline_range_preset_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_timeline_filter_bar.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_timeline_search_field.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/widgets/ui/app_select_field.dart';

void main() {
  testWidgets('gantt timeline filter bar uses wide field widths', (
    tester,
  ) async {
    final fixture = _FilterBarFixture();
    addTearDown(fixture.dispose);

    await fixture.pump(tester, width: 1000);

    expect(find.byKey(GanttTimelineFilterBar.wideLayoutKey), findsOneWidget);
    expect(find.byKey(GanttTimelineFilterBar.compactLayoutKey), findsNothing);
    expect(
      tester.widget<GanttTimelineSearchField>(_search()).width,
      _fieldWidth(GanttTimelineFilterFieldRole.search),
    );
    expect(
      tester.widget<AppSelectField<String>>(_project()).width,
      _fieldWidth(GanttTimelineFilterFieldRole.project),
    );
    expect(
      tester.widget<AppSelectField<GanttTaskStatusFilter>>(_status()).width,
      _fieldWidth(GanttTimelineFilterFieldRole.status),
    );
    expect(
      tester.widget<AppSelectField<gantt.ViewMode>>(_view()).width,
      _fieldWidth(GanttTimelineFilterFieldRole.view),
    );
    expect(
      tester.widget<AppSelectField<GanttTimelineRangePreset>>(_range()).width,
      _fieldWidth(GanttTimelineFilterFieldRole.range),
    );
  });

  testWidgets('gantt timeline filter bar stacks compact fields', (
    tester,
  ) async {
    final fixture = _FilterBarFixture();
    addTearDown(fixture.dispose);

    await fixture.pump(tester, width: 520);

    expect(find.byKey(GanttTimelineFilterBar.compactLayoutKey), findsOneWidget);
    expect(find.byKey(GanttTimelineFilterBar.wideLayoutKey), findsNothing);
    expect(tester.widget<GanttTimelineSearchField>(_search()).width, isNull);
    expect(tester.widget<AppSelectField<String>>(_project()).width, isNull);
    expect(
      tester.widget<AppSelectField<GanttTaskStatusFilter>>(_status()).width,
      isNull,
    );
    expect(
      tester.widget<AppSelectField<gantt.ViewMode>>(_view()).width,
      isNull,
    );
    expect(
      tester.widget<AppSelectField<GanttTimelineRangePreset>>(_range()).width,
      isNull,
    );
  });

  testWidgets('gantt timeline filter bar writes filter providers', (
    tester,
  ) async {
    final fixture = _FilterBarFixture();
    addTearDown(fixture.dispose);

    await fixture.pump(tester, width: 1000);

    await tester.enterText(find.byType(TextField), 'launch');
    await tester.pump();
    expect(fixture.container.read(gantt.searchQueryProvider), 'launch');

    await tester.tap(find.byKey(GanttTimelineSearchField.clearButtonKey));
    await tester.pump();
    expect(fixture.container.read(gantt.searchQueryProvider), isEmpty);
    expect(fixture.controller.text, isEmpty);

    tester.widget<AppSelectField<String>>(_project()).onChanged('alpha');
    expect(fixture.container.read(ganttProjectFilterProvider), 'alpha');

    tester.widget<AppSelectField<String>>(_project()).onChanged('all');
    expect(fixture.container.read(ganttProjectFilterProvider), isNull);

    tester.widget<AppSelectField<String>>(_project()).onChanged('alpha');
    tester
        .widget<AppSelectField<GanttTaskStatusFilter>>(_status())
        .onChanged(GanttTaskStatusFilter.inProgress);
    tester
        .widget<AppSelectField<gantt.ViewMode>>(_view())
        .onChanged(gantt.ViewMode.month);
    tester
        .widget<AppSelectField<GanttTimelineRangePreset>>(_range())
        .onChanged(GanttTimelineRangePreset.projectSpan);

    expect(fixture.container.read(ganttProjectFilterProvider), 'alpha');
    expect(
      fixture.container.read(ganttTaskStatusFilterProvider),
      GanttTaskStatusFilter.inProgress,
    );
    expect(
      fixture.container.read(gantt.viewModeProvider),
      gantt.ViewMode.month,
    );
    expect(
      fixture.container.read(ganttTimelineRangePresetProvider),
      GanttTimelineRangePreset.projectSpan,
    );
    expect(
      fixture.container.read(gantt.dateRangeProvider),
      const GanttTimelineRangePresetService().rangeFor(
        preset: GanttTimelineRangePreset.projectSpan,
        tasks: fixture.tasks,
      ),
    );
  });
}

double _fieldWidth(GanttTimelineFilterFieldRole role) {
  return ganttTimelineFilterFieldPresentation(role).expandedWidth;
}

Finder _search() => find.byType(GanttTimelineSearchField);

Finder _project() => find.byType(AppSelectField<String>);

Finder _status() => find.byType(AppSelectField<GanttTaskStatusFilter>);

Finder _view() => find.byType(AppSelectField<gantt.ViewMode>);

Finder _range() => find.byType(AppSelectField<GanttTimelineRangePreset>);

/// Test fixture that keeps filter providers and disposable inputs together.
class _FilterBarFixture {
  _FilterBarFixture()
    : container = ProviderContainer(
        overrides: [
          ganttChartWorkspacePreferencesRepositoryProvider.overrideWithValue(
            GanttChartWorkspacePreferencesRepository(
              store: MemoryGanttChartWorkspacePreferencesSnapshotStore(),
            ),
          ),
        ],
      );

  final ProviderContainer container;
  final controller = TextEditingController();
  final focusNode = FocusNode(debugLabel: 'Gantt timeline filter test');
  final projects = [_projectAlpha];
  final tasks = [_taskAlpha];

  Future<void> pump(WidgetTester tester, {required double width}) {
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: GanttTimelineFilterBar(
                viewMode: container.read(gantt.viewModeProvider),
                projects: projects,
                selectedProjectId: container.read(ganttProjectFilterProvider),
                searchController: controller,
                searchFocusNode: focusNode,
                statusFilter: container.read(ganttTaskStatusFilterProvider),
                tasks: tasks,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
    container.dispose();
  }
}

final _projectAlpha = ProjectPortfolioItem(
  id: 'alpha',
  name: 'Project Alpha',
  owner: 'Ayu',
  client: 'Retail',
  startDate: DateTime(2026, 5, 1),
  endDate: DateTime(2026, 5, 30),
  progress: 0.4,
  budgetUsed: 0.5,
  health: ProjectHealth.onTrack,
  milestones: const [],
);

final _taskAlpha = gantt.GanttTask(
  id: 'alpha-task',
  title: 'Project Alpha Discovery',
  startDate: DateTime(2026, 5, 1),
  endDate: DateTime(2026, 5, 12),
  progress: 0.4,
  projectId: _projectAlpha.id,
);
