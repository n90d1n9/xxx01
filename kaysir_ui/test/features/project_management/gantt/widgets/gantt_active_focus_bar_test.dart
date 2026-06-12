import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_saved_view_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_timeline_range_preset_service.dart';
import 'package:kaysir/features/project_management/gantt/states/gantt_filter_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_active_focus_bar.dart';
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';

void main() {
  testWidgets('gantt active focus bar stays hidden without active filters', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttActiveFocusBar(
            query: '',
            selectedProject: null,
            statusFilter: GanttTaskStatusFilter.all,
            viewPreset: GanttTimelineViewPreset.all,
            rangePreset: GanttTimelineRangePreset.planningWindow,
            visibleTaskCount: 5,
            totalTaskCount: 5,
            onClear: () {},
          ),
        ),
      ),
    );

    expect(find.text('Active focus'), findsNothing);
    expect(find.text('5 of 5 shown'), findsNothing);
  });

  testWidgets('gantt active focus bar summarizes active timeline focus', (
    tester,
  ) async {
    var clearCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttActiveFocusBar(
            query: 'release',
            selectedProject: _project,
            statusFilter: GanttTaskStatusFilter.inProgress,
            viewPreset: GanttTimelineViewPreset.dependencyWatch,
            rangePreset: GanttTimelineRangePreset.attentionWindow,
            visibleTaskCount: 3,
            totalTaskCount: 9,
            onClear: () => clearCount++,
          ),
        ),
      ),
    );

    expect(find.text('Active focus'), findsOneWidget);
    expect(find.text('5 focus layers active'), findsOneWidget);
    expect(find.text('3 of 9 shown'), findsOneWidget);
    expect(
      find.byTooltip('6 filtered out by the current focus'),
      findsOneWidget,
    );
    expect(find.text(_project.name), findsOneWidget);
    expect(find.text(GanttTaskStatusFilter.inProgress.label), findsOneWidget);
    expect(find.text('"release"'), findsOneWidget);

    await tester.tap(find.text('Clear Filters'));
    await tester.pump();

    expect(clearCount, 1);
  });

  testWidgets('gantt active focus bar clears individual focus chips', (
    tester,
  ) async {
    final clearCounts = <String, int>{
      'project': 0,
      'branch': 0,
      'view': 0,
      'range': 0,
      'status': 0,
      'query': 0,
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttActiveFocusBar(
            query: 'release',
            selectedProject: _project,
            branchFocusTitle: 'Launch Readiness',
            statusFilter: GanttTaskStatusFilter.inProgress,
            viewPreset: GanttTimelineViewPreset.dependencyWatch,
            rangePreset: GanttTimelineRangePreset.attentionWindow,
            visibleTaskCount: 3,
            totalTaskCount: 9,
            onClearProject: () => clearCounts['project'] = 1,
            onClearBranchFocus: () => clearCounts['branch'] = 1,
            onClearViewPreset: () => clearCounts['view'] = 1,
            onClearRangePreset: () => clearCounts['range'] = 1,
            onClearStatus: () => clearCounts['status'] = 1,
            onClearQuery: () => clearCounts['query'] = 1,
            onClear: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(GanttActiveFocusBar.clearProjectButtonKey));
    await tester.tap(find.byKey(GanttActiveFocusBar.clearBranchButtonKey));
    await tester.tap(find.byKey(GanttActiveFocusBar.clearViewButtonKey));
    await tester.tap(find.byKey(GanttActiveFocusBar.clearRangeButtonKey));
    await tester.tap(find.byKey(GanttActiveFocusBar.clearStatusButtonKey));
    await tester.tap(find.byKey(GanttActiveFocusBar.clearQueryButtonKey));
    await tester.pump();

    expect(clearCounts['project'], 1);
    expect(clearCounts['branch'], 1);
    expect(clearCounts['view'], 1);
    expect(clearCounts['range'], 1);
    expect(clearCounts['status'], 1);
    expect(clearCounts['query'], 1);
  });
}

final _project = ProjectPortfolioItem(
  id: 'project-alpha',
  name: 'Project Alpha',
  owner: 'Maya',
  client: 'Kaysir',
  startDate: DateTime(2026, 1, 5),
  endDate: DateTime(2026, 2, 20),
  progress: 0.45,
  budgetUsed: 0.5,
  health: ProjectHealth.atRisk,
  milestones: const [],
);
