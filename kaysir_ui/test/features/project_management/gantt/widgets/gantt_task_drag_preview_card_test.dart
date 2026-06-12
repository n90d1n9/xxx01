import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_drag_preview_card.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_drag_preview_delta_strip.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_drag_preview_ghost_bar.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_drag_preview_visuals.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  testWidgets('gantt task drag preview card shows blocked edit context', (
    tester,
  ) async {
    final preview = KyGanttTaskDragPreview(
      task: GanttTask(
        id: 'build',
        title: 'Build',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 14),
      ),
      startDate: DateTime(2026, 1, 8),
      endDate: DateTime(2026, 1, 21),
      deltaDays: 7,
      snap: KyGanttTaskDragSnap.week,
      validation: const KyGanttTaskDateRangeValidation.blocked(
        'Would overlap Testing',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: GanttTaskDragPreviewCard(preview: preview)),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('gantt-task-drag-preview-build')),
      findsOneWidget,
    );
    expect(find.byKey(GanttTaskDragPreviewCard.statusRailKey), findsOneWidget);
    expect(
      tester
          .widget<Semantics>(
            find.byKey(GanttTaskDragPreviewCard.summarySemanticsKey),
          )
          .properties
          .label,
      'Move +7d, Jan 8-21, Moves later, 2w, Week snap, Blocked, Would overlap Testing',
    );
    expect(find.text('Move +7d'), findsOneWidget);
    expect(find.text('Jan 1-14 to Jan 8-21'), findsOneWidget);
    expect(find.byKey(GanttTaskDragPreviewGhostBar.barKey), findsOneWidget);
    expect(
      find.byKey(GanttTaskDragPreviewGhostBar.originalBarKey),
      findsOneWidget,
    );
    expect(
      find.byKey(GanttTaskDragPreviewGhostBar.targetBarKey),
      findsOneWidget,
    );
    expect(
      find.byKey(GanttTaskDragPreviewGhostBar.connectorKey),
      findsOneWidget,
    );
    expect(find.byKey(GanttTaskDragPreviewDeltaStrip.stripKey), findsOneWidget);
    expect(find.text('Before'), findsOneWidget);
    expect(find.text('After'), findsOneWidget);
    expect(find.text('Jan 1-14'), findsOneWidget);
    expect(find.text('Jan 8-21'), findsOneWidget);
    expect(find.text('Moves later'), findsOneWidget);
    expect(find.text('2w'), findsOneWidget);
    expect(find.text('Week snap'), findsOneWidget);
    expect(find.text('Blocked'), findsWidgets);
    expect(find.text('Would overlap Testing'), findsOneWidget);
  });

  test('gantt task drag preview visuals expose state-specific tone', () {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    final ready = GanttTaskDragPreviewVisuals.from(
      colorScheme,
      const KyGanttTaskDateRangeValidation.valid(),
    );
    final check = GanttTaskDragPreviewVisuals.from(
      colorScheme,
      const KyGanttTaskDateRangeValidation.warning('Check dependency'),
    );
    final blocked = GanttTaskDragPreviewVisuals.from(
      colorScheme,
      const KyGanttTaskDateRangeValidation.blocked('Would overlap Testing'),
    );

    expect(ready.tone, GanttTaskDragPreviewTone.ready);
    expect(check.tone, GanttTaskDragPreviewTone.check);
    expect(blocked.tone, GanttTaskDragPreviewTone.blocked);
    expect(blocked.shadowBlur, greaterThan(ready.shadowBlur));
    expect(blocked.shadowOffset.dy, greaterThan(ready.shadowOffset.dy));
  });

  testWidgets('gantt task drag preview card shows ready state', (tester) async {
    final preview = KyGanttTaskDragPreview(
      task: GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      ),
      startDate: DateTime(2026, 1, 2),
      endDate: DateTime(2026, 1, 5),
      deltaDays: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: GanttTaskDragPreviewCard(preview: preview)),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('gantt-task-drag-preview-design')),
      findsOneWidget,
    );
    expect(find.text('Move +1d'), findsOneWidget);
    expect(find.text('Moves later'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('gantt task drag preview card can hide delta strip only', (
    tester,
  ) async {
    final preview = KyGanttTaskDragPreview(
      task: GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      ),
      startDate: DateTime(2026, 1, 2),
      endDate: DateTime(2026, 1, 5),
      deltaDays: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GanttTaskDragPreviewCard(
              preview: preview,
              showDeltaStrip: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Moves later'), findsOneWidget);
    expect(find.text('4d'), findsOneWidget);
    expect(find.text('Day snap'), findsOneWidget);
    expect(find.byKey(GanttTaskDragPreviewGhostBar.barKey), findsOneWidget);
    expect(find.byKey(GanttTaskDragPreviewDeltaStrip.stripKey), findsNothing);
  });

  testWidgets('gantt task drag preview card can hide ghost bar only', (
    tester,
  ) async {
    final preview = KyGanttTaskDragPreview(
      task: GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      ),
      startDate: DateTime(2026, 1, 2),
      endDate: DateTime(2026, 1, 5),
      deltaDays: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GanttTaskDragPreviewCard(
              preview: preview,
              showGhostBar: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Moves later'), findsOneWidget);
    expect(find.byKey(GanttTaskDragPreviewGhostBar.barKey), findsNothing);
    expect(find.byKey(GanttTaskDragPreviewDeltaStrip.stripKey), findsOneWidget);
  });

  testWidgets('gantt task drag preview card can hide impact summary', (
    tester,
  ) async {
    final preview = KyGanttTaskDragPreview(
      task: GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      ),
      startDate: DateTime(2026, 1, 2),
      endDate: DateTime(2026, 1, 5),
      deltaDays: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GanttTaskDragPreviewCard(
              preview: preview,
              showImpactSummary: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Jan 2-5 - 4d - Day snap'), findsOneWidget);
    expect(find.byKey(GanttTaskDragPreviewGhostBar.barKey), findsNothing);
    expect(find.byKey(GanttTaskDragPreviewDeltaStrip.stripKey), findsNothing);
    expect(
      tester
          .widget<Semantics>(
            find.byKey(GanttTaskDragPreviewCard.summarySemanticsKey),
          )
          .properties
          .label,
      'Move +1d, Jan 2-5, 4d, Day snap, Ready',
    );
    expect(find.text('Moves later'), findsNothing);
  });
}
