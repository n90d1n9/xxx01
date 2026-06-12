import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/states/gantt_chart_interaction_provider.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_actions.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_overlay.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_overlay_layout.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_inspector_overlay_motion.dart';

void main() {
  group('GanttTaskInspectorOverlayLayout', () {
    test('resolves adaptive placement to a side sheet on wide screens', () {
      final layout = GanttTaskInspectorOverlayLayout.resolve(
        constraints: BoxConstraints.tight(const Size(1000, 700)),
        placement: GanttTaskInspectorPlacement.adaptive,
      );

      expect(layout.resolvedPlacement, GanttTaskInspectorPlacement.side);
      expect(layout.isBottomSheet, isFalse);
      expect(layout.padding, 12);
      expect(layout.sheetWidth, 480);
      expect(layout.sheetHeight, 676);
      expect(layout.alignment, Alignment.centerRight);
    });

    test(
      'resolves adaptive placement to a bottom sheet on compact screens',
      () {
        final layout = GanttTaskInspectorOverlayLayout.resolve(
          constraints: BoxConstraints.tight(const Size(600, 700)),
          placement: GanttTaskInspectorPlacement.adaptive,
        );

        expect(layout.resolvedPlacement, GanttTaskInspectorPlacement.bottom);
        expect(layout.isBottomSheet, isTrue);
        expect(layout.padding, 8);
        expect(layout.sheetWidth, 584);
        expect(layout.sheetHeight, 588);
        expect(layout.alignment, Alignment.bottomCenter);
      },
    );
  });

  testWidgets('gantt task inspector overlay renders animated side chrome', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var dismissed = false;

    await tester.pumpWidget(
      _overlayHarness(
        placement: GanttTaskInspectorPlacement.side,
        onDismiss: () => dismissed = true,
      ),
    );

    expect(find.byKey(GanttTaskInspectorOverlay.scrimKey), findsOneWidget);
    expect(
      find.byKey(GanttTaskInspectorOverlayMotion.motionKey),
      findsOneWidget,
    );

    await tester.pumpAndSettle();

    final panelRect = tester.getRect(
      find.byKey(GanttTaskInspectorOverlay.panelKey),
    );
    expect(panelRect.width, 480);
    expect(panelRect.height, 676);
    expect(panelRect.right, closeTo(988, 0.1));
    expect(panelRect.top, closeTo(12, 0.1));

    await tester.tapAt(const Offset(4, 4));
    expect(dismissed, isTrue);
  });

  testWidgets('gantt task inspector overlay renders compact bottom chrome', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _overlayHarness(placement: GanttTaskInspectorPlacement.adaptive),
    );
    await tester.pumpAndSettle();

    final panelRect = tester.getRect(
      find.byKey(GanttTaskInspectorOverlay.panelKey),
    );
    expect(panelRect.width, 584);
    expect(panelRect.height, 588);
    expect(panelRect.left, closeTo(8, 0.1));
    expect(panelRect.bottom, closeTo(692, 0.1));
  });
}

Widget _overlayHarness({
  required GanttTaskInspectorPlacement placement,
  VoidCallback? onDismiss,
}) {
  return MaterialApp(
    home: Scaffold(
      body: GanttTaskInspectorOverlay(
        task: _task,
        projectName: 'Retail Modernization',
        dependencyTitle: 'Planning',
        dependencyTasks: const [],
        recentEdits: const [],
        placement: placement,
        taskPositionLabel: '2 of 4 visible',
        previousTaskTitle: 'Planning',
        nextTaskTitle: 'Testing',
        actions: GanttTaskInspectorActions(
          onDismiss: onDismiss ?? () {},
          onClearSelection: () {},
        ),
      ),
    ),
  );
}

final _task = gantt.GanttTask(
  id: 'build',
  title: 'Build',
  startDate: DateTime(2026, 1, 5),
  endDate: DateTime(2026, 1, 12),
  progress: 0.5,
  dependsOn: 'plan',
  projectId: 'retail',
);
