import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_action_bar.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_collapsible_section.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_content.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_section_config.dart';

void main() {
  test('gantt task inspector section config supports copy updates', () {
    final config = GanttTaskInspectorSectionConfig.all.copyWith(
      showEditing: false,
      showRelationships: false,
      collapsibleSections: const {GanttTaskInspectorSection.editing},
      initiallyCollapsedSections: const {GanttTaskInspectorSection.editing},
    );

    expect(config.showSummary, true);
    expect(config.showEditing, false);
    expect(config.showReadiness, true);
    expect(config.showRelationships, false);
    expect(config.showActions, true);
    expect(config.hasVisibleSections, true);
    expect(config.isVisible(GanttTaskInspectorSection.editing), false);
    expect(config.isCollapsible(GanttTaskInspectorSection.editing), true);
    expect(
      config.isInitiallyCollapsed(GanttTaskInspectorSection.editing),
      true,
    );
    expect(config, config.copyWith());
  });

  testWidgets('gantt task inspector content renders selected task sections', (
    tester,
  ) async {
    var cleared = false;

    await tester.pumpWidget(
      _contentHarness(
        GanttTaskInspectorContent(
          task: gantt.GanttTask(
            id: 'design',
            title: 'Design Phase',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            color: Colors.green,
          ),
          projectName: 'Warehouse Automation',
          dependencyTitle: null,
          today: DateTime(2026, 5, 5),
          onClearSelection: () => cleared = true,
        ),
      ),
    );

    expect(find.text('Design Phase'), findsWidgets);
    expect(find.text('Warehouse Automation'), findsOneWidget);
    expect(find.text('Progress Control'), findsOneWidget);
    expect(find.text('Schedule Health'), findsOneWidget);
    expect(find.text('No Upstream Dependencies'), findsOneWidget);
    expect(find.text('No Downstream Impact'), findsOneWidget);
    expect(find.text('Clear Selection'), findsOneWidget);

    final clearButton = find.byKey(
      GanttTaskInspectorActionBar.clearSelectionButtonKey,
    );
    await tester.ensureVisible(clearButton);
    await tester.tap(clearButton);
    expect(cleared, true);
  });

  testWidgets('gantt task inspector content hides configured sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      _contentHarness(
        GanttTaskInspectorContent(
          task: gantt.GanttTask(
            id: 'design',
            title: 'Design Phase',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            color: Colors.green,
          ),
          projectName: 'Warehouse Automation',
          dependencyTitle: null,
          sectionConfig: const GanttTaskInspectorSectionConfig(
            showEditing: false,
            showReadiness: false,
            showRelationships: false,
            showActions: false,
          ),
          onClearSelection: () {},
        ),
      ),
    );

    expect(find.text('Design Phase'), findsWidgets);
    expect(find.text('Warehouse Automation'), findsOneWidget);
    expect(find.text('Progress Control'), findsNothing);
    expect(find.text('Schedule Health'), findsNothing);
    expect(find.text('No Upstream Dependencies'), findsNothing);
    expect(find.text('Clear Selection'), findsNothing);
  });

  testWidgets('gantt task inspector content expands collapsible sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      _contentHarness(
        GanttTaskInspectorContent(
          task: gantt.GanttTask(
            id: 'design',
            title: 'Design Phase',
            startDate: DateTime(2026, 5, 4),
            endDate: DateTime(2026, 5, 12),
            progress: 0.5,
            color: Colors.green,
          ),
          projectName: 'Warehouse Automation',
          dependencyTitle: null,
          sectionConfig: const GanttTaskInspectorSectionConfig(
            showSummary: false,
            showReadiness: false,
            showRelationships: false,
            showActions: false,
            collapsibleSections: {GanttTaskInspectorSection.editing},
            initiallyCollapsedSections: {GanttTaskInspectorSection.editing},
          ),
          onClearSelection: () {},
        ),
      ),
    );

    expect(find.text('Edit Controls'), findsOneWidget);
    expect(find.text('Progress Control'), findsNothing);

    await tester.tap(
      find.byKey(
        GanttTaskInspectorCollapsibleSection.toggleButtonKey(
          GanttTaskInspectorSection.editing,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Progress Control'), findsOneWidget);
    expect(find.text('Task Type'), findsOneWidget);
  });
}

Widget _contentHarness(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    ),
  );
}
