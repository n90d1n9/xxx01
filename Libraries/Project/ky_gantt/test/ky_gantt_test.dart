import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_gantt/ky_gantt.dart';
import 'package:ky_gantt/widgets/ky_gantt_dependency_painter.dart';
import 'package:ky_gantt/widgets/ky_gantt_grid_painter.dart';

void main() {
  test('flattens gantt task trees with depth', () {
    final tasks = [
      GanttTask(
        id: '1',
        title: 'Planning',
        startDate: DateTime(2026),
        endDate: DateTime(2026, 1, 3),
        subtasks: [
          GanttTask(
            id: '1.1',
            title: 'Requirements',
            startDate: DateTime(2026),
            endDate: DateTime(2026, 1, 2),
          ),
        ],
      ),
    ];

    final nodes = flattenGanttTaskNodes(tasks);

    expect(nodes.map((node) => node.task.id), ['1', '1.1']);
    expect(nodes.map((node) => node.depth), [0, 1]);
    expect(nodes.first.hasChildren, isTrue);
    expect(nodes.first.collapsed, isFalse);

    final collapsedNodes = flattenGanttTaskNodes(
      tasks,
      collapsedTaskIds: const {'1'},
    );

    expect(collapsedNodes.map((node) => node.task.id), ['1']);
    expect(collapsedNodes.single.hasChildren, isTrue);
    expect(collapsedNodes.single.collapsed, isTrue);
  });

  test('clips task layout segments to the visible range', () {
    final task = GanttTask(
      id: 'long',
      title: 'Long running task',
      startDate: DateTime(2025, 12, 28),
      endDate: DateTime(2026, 1, 14),
    );

    final segment = visibleSegmentForTask(
      task: task,
      rangeStart: DateTime(2026, 1, 5),
      rangeEnd: DateTime(2026, 1, 10),
    );

    expect(segment, isNotNull);
    expect(segment!.startOffsetDays, 0);
    expect(segment.durationDays, 6);
    expect(segment.startsBeforeRange, isTrue);
    expect(segment.endsAfterRange, isTrue);
    expect(segment.isClipped, isTrue);

    final outsideSegment = visibleSegmentForTask(
      task: task.copyWith(
        id: 'outside',
        startDate: DateTime(2026, 1, 20),
        endDate: DateTime(2026, 1, 21),
      ),
      rangeStart: DateTime(2026, 1, 5),
      rangeEnd: DateTime(2026, 1, 10),
    );

    expect(outsideSegment, isNull);

    final reversedRangeSegment = visibleSegmentForTask(
      task: task,
      rangeStart: DateTime(2026, 1, 10),
      rangeEnd: DateTime(2026, 1, 5),
    );

    expect(reversedRangeSegment, isNotNull);
    expect(reversedRangeSegment!.durationDays, 6);
  });

  test('resolves milestone offsets from the milestone start date', () {
    final milestone = GanttTask(
      id: 'launch',
      title: 'Launch',
      startDate: DateTime(2026, 1, 3, 18),
      endDate: DateTime(2026, 1, 12),
      kind: GanttTaskKind.milestone,
    );

    expect(milestone.isMilestone, isTrue);
    expect(milestone.copyWith().kind, GanttTaskKind.milestone);
    expect(
      milestoneOffsetDaysForTask(
        task: milestone,
        rangeStart: DateTime(2026, 1, 1),
        rangeEnd: DateTime(2026, 1, 5),
      ),
      2,
    );
    expect(
      milestoneOffsetDaysForTask(
        task: milestone,
        rangeStart: DateTime(2026, 1, 4),
        rangeEnd: DateTime(2026, 1, 10),
      ),
      isNull,
    );
  });

  test('formats reusable gantt task labels', () {
    final task = GanttTask(
      id: 'handoff',
      title: 'Handoff',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 14),
      progress: 0.42,
      dependsOn: 'design',
    );

    expect(ganttTaskStatusLabel(task), 'Active');
    expect(ganttTaskProgressLabel(task), '42%');
    expect(ganttTaskDateRangeLabel(task), 'Jan 1-14');
    expect(ganttTaskDurationLabel(task), '2w');
    expect(ganttTaskHasDependency(task), isTrue);
    expect(
      ganttTaskScheduleStatusLabel(task, today: DateTime(2025, 12, 31)),
      'Planned',
    );
    expect(
      ganttTaskScheduleStatusLabel(task, today: DateTime(2026, 1, 6)),
      'In progress',
    );
    expect(
      ganttTaskScheduleStatusLabel(task, today: DateTime(2026, 1, 14)),
      'Due today',
    );
    expect(
      ganttTaskScheduleStatusLabel(task, today: DateTime(2026, 1, 15)),
      'Overdue',
    );
    expect(
      ganttTaskScheduleStatusLabel(
        task.copyWith(progress: 1),
        today: DateTime(2026, 1, 15),
      ),
      'Complete',
    );
  });

  test('formats reusable drag preview metadata', () {
    final preview = KyGanttTaskDragPreview(
      task: GanttTask(
        id: 'build',
        title: 'Build',
        startDate: DateTime(2026, 1, 14),
        endDate: DateTime(2026, 1, 1),
      ),
      startDate: DateTime(2026, 1, 14),
      endDate: DateTime(2026, 1, 1),
      deltaDays: 7,
      snap: KyGanttTaskDragSnap.week,
    );

    expect(preview.deltaLabel, '+7d');
    expect(preview.durationDays, 14);
    expect(preview.durationLabel, '2w');
    expect(preview.snapLabel, 'Week snap');
    expect(
        preview.copyWith(snap: KyGanttTaskDragSnap.day).snapLabel, 'Day snap');
  });

  test('normalizes and caps timeline ranges', () {
    final range = resolveGanttTimelineRange(
      start: DateTime(2026, 1, 10),
      end: DateTime(2026, 1, 1),
      maxDays: 5,
    );

    expect(range.start, DateTime(2026, 1, 1));
    expect(range.end, DateTime(2026, 1, 5));
    expect(range.totalDays, 5);
    expect(range.truncated, isTrue);

    final minimumRange = resolveGanttTimelineRange(
      start: DateTime(2026, 1, 1),
      end: DateTime(2026, 1, 1),
      maxDays: 0,
    );

    expect(minimumRange.totalDays, 1);
    expect(minimumRange.end, DateTime(2026, 1, 1));
  });

  test('calculates centered initial focus offsets', () {
    expect(
      initialGanttFocusScrollOffset(
        focusDate: DateTime(2026, 1, 10),
        rangeStart: DateTime(2026, 1, 1),
        totalDays: 30,
        dayWidth: 50,
        viewportWidth: 200,
      ),
      375,
    );
    expect(
      initialGanttFocusScrollOffset(
        focusDate: DateTime(2025, 12, 20),
        rangeStart: DateTime(2026, 1, 1),
        totalDays: 30,
        dayWidth: 50,
        viewportWidth: 200,
      ),
      0,
    );
    expect(
      initialGanttFocusScrollOffset(
        focusDate: DateTime(2026, 2, 20),
        rangeStart: DateTime(2026, 1, 1),
        totalDays: 30,
        dayWidth: 50,
        viewportWidth: 200,
      ),
      1300,
    );
    expect(
      initialGanttFocusScrollOffset(
        focusDate: DateTime(2026, 1, 10),
        rangeStart: DateTime(2026, 1, 1),
        totalDays: 3,
        dayWidth: 50,
        viewportWidth: 200,
      ),
      0,
    );
  });

  test('grid painter only repaints when inputs change', () {
    final painter = KyGanttGridPainter(
      rangeStart: DateTime(2026, 1, 1),
      totalDays: 30,
      dayWidth: 42,
      rowHeight: 58,
      rowCount: 4,
      weekendColor: const Color(0xFFEFF6FF),
      verticalLineColor: const Color(0xFFE5E7EB),
      horizontalLineColor: const Color(0xFFD1D5DB),
    );
    final samePainter = KyGanttGridPainter(
      rangeStart: DateTime(2026, 1, 1),
      totalDays: 30,
      dayWidth: 42,
      rowHeight: 58,
      rowCount: 4,
      weekendColor: const Color(0xFFEFF6FF),
      verticalLineColor: const Color(0xFFE5E7EB),
      horizontalLineColor: const Color(0xFFD1D5DB),
    );
    final hiddenWeekendPainter = KyGanttGridPainter(
      rangeStart: DateTime(2026, 1, 1),
      totalDays: 30,
      dayWidth: 42,
      rowHeight: 58,
      rowCount: 4,
      weekendColor: const Color(0xFFEFF6FF),
      verticalLineColor: const Color(0xFFE5E7EB),
      horizontalLineColor: const Color(0xFFD1D5DB),
      showWeekendBands: false,
    );
    final changedPainter = KyGanttGridPainter(
      rangeStart: DateTime(2026, 1, 1),
      totalDays: 31,
      dayWidth: 42,
      rowHeight: 58,
      rowCount: 4,
      weekendColor: const Color(0xFFEFF6FF),
      verticalLineColor: const Color(0xFFE5E7EB),
      horizontalLineColor: const Color(0xFFD1D5DB),
    );

    expect(painter.shouldRepaint(samePainter), isFalse);
    expect(painter.shouldRepaint(changedPainter), isTrue);
    expect(painter.shouldRepaint(hiddenWeekendPainter), isTrue);
  });

  testWidgets('grid widget exposes a stable layer and size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              KyGanttGrid(
                rangeStart: DateTime(2026, 1, 1),
                totalDays: 3,
                dayWidth: 24,
                rowHeight: 40,
                rowCount: 2,
              ),
            ],
          ),
        ),
      ),
    );

    final grid = find.byKey(KyGanttGrid.defaultGridKey);

    expect(grid, findsOneWidget);
    expect(tester.getSize(grid), const Size(72, 80));
  });

  testWidgets('grid widget configures weekend bands', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              KyGanttGrid(
                rangeStart: DateTime(2026, 1, 1),
                totalDays: 3,
                dayWidth: 24,
                rowHeight: 40,
                rowCount: 2,
                showWeekendBands: false,
                weekendBandColor: Colors.orange,
                weekendBandOpacity: 0.2,
              ),
            ],
          ),
        ),
      ),
    );

    final grid = tester.widget<CustomPaint>(
      find.byKey(KyGanttGrid.defaultGridKey),
    );
    final painter = grid.painter! as KyGanttGridPainter;

    expect(painter.showWeekendBands, isFalse);
    expect(painter.weekendColor, Colors.orange.withValues(alpha: 0.2));
  });

  testWidgets('timeline header configures weekend accents', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KyGanttTimelineHeader(
            rangeStart: DateTime(2026, 1, 1),
            totalDays: 4,
            dayWidth: 32,
            height: 62,
            viewMode: KyGanttViewMode.week,
            showWeekendBands: false,
            weekendBandColor: Colors.orange,
            weekendBandOpacity: 0.2,
          ),
        ),
      ),
    );

    final header = tester.widget<KyGanttTimelineHeader>(
      find.byKey(KyGanttTimelineHeader.defaultHeaderKey),
    );

    expect(header.showWeekendBands, isFalse);
    expect(header.weekendBandColor, Colors.orange);
    expect(header.weekendBandOpacity, 0.2);
  });

  testWidgets('timeline header renders today indicator when visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KyGanttTimelineHeader(
            rangeStart: DateTime(2026, 1, 1),
            totalDays: 5,
            dayWidth: 32,
            height: 62,
            viewMode: KyGanttViewMode.week,
            today: DateTime(2026, 1, 3, 18),
          ),
        ),
      ),
    );

    final indicator = find.byKey(
      KyGanttTimelineHeader.defaultTodayIndicatorKey,
    );

    expect(indicator, findsOneWidget);
    expect(tester.getTopLeft(indicator).dx, 64);
  });

  testWidgets('dependency layer exposes a stable layer and size', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
      GanttTask(
        id: 'delivery',
        title: 'Delivery',
        startDate: DateTime(2026, 1, 4),
        endDate: DateTime(2026, 1, 6),
        dependsOn: 'planning',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              KyGanttDependencyLayer(
                tasks: tasks,
                rangeStart: DateTime(2026, 1, 1),
                rangeEnd: DateTime(2026, 1, 8),
                totalDays: 8,
                dayWidth: 24,
                rowHeight: 40,
              ),
            ],
          ),
        ),
      ),
    );

    final layer = find.byKey(KyGanttDependencyLayer.defaultLayerKey);

    expect(layer, findsOneWidget);
    expect(tester.getSize(layer), const Size(192, 80));
  });

  testWidgets('dependency layer supports selected task focus styling', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
      GanttTask(
        id: 'delivery',
        title: 'Delivery',
        startDate: DateTime(2026, 1, 4),
        endDate: DateTime(2026, 1, 6),
        dependsOn: 'planning',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              KyGanttDependencyLayer(
                tasks: tasks,
                rangeStart: DateTime(2026, 1, 1),
                rangeEnd: DateTime(2026, 1, 8),
                totalDays: 8,
                dayWidth: 24,
                rowHeight: 40,
                selectedTaskId: 'delivery',
                highlightSelectedTask: true,
                highlightConflictedDependencies: true,
                focusScope: KyGanttDependencyLineFocusScope.chain,
                color: Colors.blue,
                highlightColor: Colors.orange,
                conflictColor: Colors.red,
                lineOpacity: 0.42,
                inactiveLineOpacity: 0.08,
                highlightLineOpacity: 0.96,
                conflictLineOpacity: 0.88,
                strokeWidth: 1.2,
                highlightStrokeWidth: 3,
                conflictStrokeWidth: 2.8,
              ),
            ],
          ),
        ),
      ),
    );

    final layer = tester.widget<CustomPaint>(
      find.byKey(KyGanttDependencyLayer.defaultLayerKey),
    );
    final painter = layer.painter! as KyGanttDependencyPainter;

    expect(painter.selectedTaskId, 'delivery');
    expect(painter.highlightSelectedTask, isTrue);
    expect(painter.highlightConflictedDependencies, isTrue);
    expect(painter.focusScope, KyGanttDependencyLineFocusScope.chain);
    expect(painter.color, Colors.blue);
    expect(painter.highlightColor, Colors.orange);
    expect(painter.conflictColor, Colors.red);
    expect(painter.lineOpacity, 0.42);
    expect(painter.inactiveLineOpacity, 0.08);
    expect(painter.highlightLineOpacity, 0.96);
    expect(painter.conflictLineOpacity, 0.88);
    expect(painter.strokeWidth, 1.2);
    expect(painter.highlightStrokeWidth, 3);
    expect(painter.conflictStrokeWidth, 2.8);
  });

  test('dependency painter resolves dependency focus scopes', () {
    final tasks = [
      GanttTask(
        id: 'strategy',
        title: 'Strategy',
        startDate: DateTime(2026, 1),
        endDate: DateTime(2026, 1, 2),
      ),
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 3),
        endDate: DateTime(2026, 1, 4),
        dependsOn: 'strategy',
      ),
      GanttTask(
        id: 'build',
        title: 'Build',
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 8),
        dependsOn: 'design',
      ),
      GanttTask(
        id: 'launch',
        title: 'Launch',
        startDate: DateTime(2026, 1, 9),
        endDate: DateTime(2026, 1, 10),
        dependsOn: 'build',
      ),
      GanttTask(
        id: 'finance',
        title: 'Finance',
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 7),
      ),
      GanttTask(
        id: 'audit',
        title: 'Audit',
        startDate: DateTime(2026, 1, 8),
        endDate: DateTime(2026, 1, 9),
        dependsOn: 'finance',
      ),
    ];

    KyGanttDependencyPainter painterFor(
      KyGanttDependencyLineFocusScope focusScope,
    ) {
      return KyGanttDependencyPainter(
        tasks: tasks,
        rangeStart: DateTime(2026, 1),
        rangeEnd: DateTime(2026, 1, 12),
        dayWidth: 24,
        rowHeight: 40,
        color: Colors.blue,
        selectedTaskId: 'build',
        focusScope: focusScope,
      );
    }

    final directPainter = painterFor(KyGanttDependencyLineFocusScope.direct);
    expect(
      directPainter.isDependencyHighlightedForTesting(
        predecessorId: 'strategy',
        taskId: 'design',
      ),
      isFalse,
    );
    expect(
      directPainter.isDependencyHighlightedForTesting(
        predecessorId: 'design',
        taskId: 'build',
      ),
      isTrue,
    );
    expect(
      directPainter.isDependencyHighlightedForTesting(
        predecessorId: 'build',
        taskId: 'launch',
      ),
      isTrue,
    );

    final upstreamPainter =
        painterFor(KyGanttDependencyLineFocusScope.upstream);
    expect(
      upstreamPainter.isDependencyHighlightedForTesting(
        predecessorId: 'strategy',
        taskId: 'design',
      ),
      isTrue,
    );
    expect(
      upstreamPainter.isDependencyHighlightedForTesting(
        predecessorId: 'design',
        taskId: 'build',
      ),
      isTrue,
    );
    expect(
      upstreamPainter.isDependencyHighlightedForTesting(
        predecessorId: 'build',
        taskId: 'launch',
      ),
      isFalse,
    );

    final downstreamPainter = painterFor(
      KyGanttDependencyLineFocusScope.downstream,
    );
    expect(
      downstreamPainter.isDependencyHighlightedForTesting(
        predecessorId: 'strategy',
        taskId: 'design',
      ),
      isFalse,
    );
    expect(
      downstreamPainter.isDependencyHighlightedForTesting(
        predecessorId: 'design',
        taskId: 'build',
      ),
      isFalse,
    );
    expect(
      downstreamPainter.isDependencyHighlightedForTesting(
        predecessorId: 'build',
        taskId: 'launch',
      ),
      isTrue,
    );

    final chainPainter = painterFor(KyGanttDependencyLineFocusScope.chain);
    expect(
      chainPainter.isDependencyHighlightedForTesting(
        predecessorId: 'strategy',
        taskId: 'design',
      ),
      isTrue,
    );
    expect(
      chainPainter.isDependencyHighlightedForTesting(
        predecessorId: 'design',
        taskId: 'build',
      ),
      isTrue,
    );
    expect(
      chainPainter.isDependencyHighlightedForTesting(
        predecessorId: 'build',
        taskId: 'launch',
      ),
      isTrue,
    );
    expect(
      chainPainter.isDependencyHighlightedForTesting(
        predecessorId: 'finance',
        taskId: 'audit',
      ),
      isFalse,
    );

    expect(
      focusedGanttDependencyTaskIds(
        tasks: tasks,
        selectedTaskId: 'build',
        enabled: true,
        focusScope: KyGanttDependencyLineFocusScope.upstream,
      ),
      {'strategy', 'design', 'build'},
    );
    expect(
      focusedGanttDependencyTaskIds(
        tasks: tasks,
        selectedTaskId: 'build',
        enabled: true,
        focusScope: KyGanttDependencyLineFocusScope.downstream,
      ),
      {'build', 'launch'},
    );
    expect(
      focusedGanttDependencyTaskIds(
        tasks: tasks,
        selectedTaskId: 'build',
        enabled: true,
        focusScope: KyGanttDependencyLineFocusScope.chain,
      ),
      {'strategy', 'design', 'build', 'launch'},
    );
  });

  test('resolves dependency conflicts from predecessor finish dates', () {
    final predecessor = GanttTask(
      id: 'strategy',
      title: 'Strategy',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 5),
    );
    final conflictedTask = GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 5),
      endDate: DateTime(2026, 1, 8),
      dependsOn: 'strategy',
    );
    final healthyTask = GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 1, 6),
      endDate: DateTime(2026, 1, 10),
      dependsOn: 'strategy',
    );
    final tasks = [predecessor, conflictedTask, healthyTask];

    expect(
      hasGanttDependencyConflict(
        task: conflictedTask,
        predecessor: predecessor,
      ),
      isTrue,
    );
    expect(
      hasGanttDependencyConflict(task: healthyTask, predecessor: predecessor),
      isFalse,
    );
    expect(
      conflictedGanttDependencyEdges(tasks: tasks),
      {const KyGanttDependencyEdge('strategy', 'design')},
    );
    expect(conflictedGanttDependencyTaskIds(tasks: tasks), {'design'});
  });

  test('dependency painter resolves conflicted dependency edges', () {
    final tasks = [
      GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 5),
      ),
      GanttTask(
        id: 'delivery',
        title: 'Delivery',
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 8),
        dependsOn: 'planning',
      ),
      GanttTask(
        id: 'handoff',
        title: 'Handoff',
        startDate: DateTime(2026, 1, 6),
        endDate: DateTime(2026, 1, 9),
        dependsOn: 'planning',
      ),
    ];

    final painter = KyGanttDependencyPainter(
      tasks: tasks,
      rangeStart: DateTime(2026, 1),
      rangeEnd: DateTime(2026, 1, 10),
      dayWidth: 24,
      rowHeight: 40,
      color: Colors.blue,
    );

    expect(
      painter.isDependencyConflictedForTesting(
        predecessorId: 'planning',
        taskId: 'delivery',
      ),
      isTrue,
    );
    expect(
      painter.isDependencyConflictedForTesting(
        predecessorId: 'planning',
        taskId: 'handoff',
      ),
      isFalse,
    );

    final disabledPainter = KyGanttDependencyPainter(
      tasks: tasks,
      rangeStart: DateTime(2026, 1),
      rangeEnd: DateTime(2026, 1, 10),
      dayWidth: 24,
      rowHeight: 40,
      color: Colors.blue,
      highlightConflictedDependencies: false,
    );

    expect(
      disabledPainter.isDependencyConflictedForTesting(
        predecessorId: 'planning',
        taskId: 'delivery',
      ),
      isFalse,
    );
  });

  testWidgets('chart can hide dependency lines from display options', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
      GanttTask(
        id: 'delivery',
        title: 'Delivery',
        startDate: DateTime(2026, 1, 4),
        endDate: DateTime(2026, 1, 6),
        dependsOn: 'planning',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 8),
              ),
              dayWidth: 24,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                dependencyLines: KyGanttDependencyLineOptions(visible: false),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(KyGanttDependencyLayer.defaultLayerKey), findsNothing);
  });

  testWidgets('chart can hide weekend bands from display options', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 8),
              ),
              dayWidth: 24,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showWeekendBands: false,
              ),
            ),
          ),
        ),
      ),
    );

    final grid = tester.widget<CustomPaint>(
      find.byKey(KyGanttGrid.defaultGridKey),
    );
    final painter = grid.painter! as KyGanttGridPainter;
    final header = tester.widget<KyGanttTimelineHeader>(
      find.byKey(KyGanttTimelineHeader.defaultHeaderKey),
    );

    expect(painter.showWeekendBands, isFalse);
    expect(header.showWeekendBands, isFalse);
  });

  testWidgets('chart passes timeline accent opacity from display options', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 8),
              ),
              today: DateTime(2026, 1, 3),
              dayWidth: 24,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                weekendBandOpacity: 0.24,
                todayIndicatorOpacity: 0.08,
                todayMarkerOpacity: 0.56,
              ),
            ),
          ),
        ),
      ),
    );

    final header = tester.widget<KyGanttTimelineHeader>(
      find.byKey(KyGanttTimelineHeader.defaultHeaderKey),
    );
    final marker = tester.widget<KyGanttTodayMarker>(
      find.byType(KyGanttTodayMarker),
    );

    expect(header.weekendBandOpacity, 0.24);
    expect(header.todayIndicatorOpacity, 0.08);
    expect(marker.opacity, 0.56);
  });

  testWidgets('chart renders selected task row highlight when enabled', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
      GanttTask(
        id: 'delivery',
        title: 'Delivery',
        startDate: DateTime(2026, 1, 4),
        endDate: DateTime(2026, 1, 6),
        dependsOn: 'planning',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              selectedTaskId: 'delivery',
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 8),
              ),
              rowHeight: 40,
              dayWidth: 24,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                selectedTaskRowHighlightColor: Colors.purple,
                selectedTaskRowHighlightOpacity: 0.12,
              ),
            ),
          ),
        ),
      ),
    );

    final highlight = tester.widget<KyGanttSelectedTaskRowHighlight>(
      find.byKey(KyGanttSelectedTaskRowHighlight.defaultHighlightKey),
    );

    expect(highlight.selectedRowIndex, 1);
    expect(highlight.width, 192);
    expect(highlight.rowHeight, 40);
    expect(highlight.color, Colors.purple);
    expect(highlight.opacity, 0.12);
  });

  testWidgets('chart can hide selected task row highlight', (tester) async {
    final tasks = [
      GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
      GanttTask(
        id: 'delivery',
        title: 'Delivery',
        startDate: DateTime(2026, 1, 4),
        endDate: DateTime(2026, 1, 6),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              selectedTaskId: 'delivery',
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 8),
              ),
              dayWidth: 24,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showSelectedTaskRowHighlight: false,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(KyGanttSelectedTaskRowHighlight.defaultHighlightKey),
      findsNothing,
    );
  });

  testWidgets('chart renders dependency conflict badges from task dates', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 5),
      ),
      GanttTask(
        id: 'delivery',
        title: 'Delivery',
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 11),
        dependsOn: 'planning',
      ),
      GanttTask(
        id: 'handoff',
        title: 'Handoff',
        startDate: DateTime(2026, 1, 6),
        endDate: DateTime(2026, 1, 12),
        dependsOn: 'planning',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            height: 260,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 14),
              ),
              dayWidth: 42,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDependencyConflictBadges: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey('ky-gantt-task-dependency-conflict-badge-delivery'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('ky-gantt-task-dependency-conflict-badge-handoff'),
      ),
      findsNothing,
    );
  });

  testWidgets('dependency focus highlights related task bars', (tester) async {
    final tasks = [
      GanttTask(
        id: 'strategy',
        title: 'Strategy',
        startDate: DateTime(2026, 1),
        endDate: DateTime(2026, 1, 2),
      ),
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 3),
        endDate: DateTime(2026, 1, 4),
        dependsOn: 'strategy',
      ),
      GanttTask(
        id: 'build',
        title: 'Build',
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 7),
        dependsOn: 'design',
      ),
      GanttTask(
        id: 'launch',
        title: 'Launch',
        startDate: DateTime(2026, 1, 8),
        endDate: DateTime(2026, 1, 9),
        dependsOn: 'build',
      ),
      GanttTask(
        id: 'finance',
        title: 'Finance',
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 7),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            height: 360,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1),
                end: DateTime(2026, 1, 12),
              ),
              dayWidth: 34,
              stickyWidth: 160,
              selectedTaskId: 'build',
              displayOptions: const KyGanttChartDisplayOptions(
                dependencyLines: KyGanttDependencyLineOptions(
                  focusScope: KyGanttDependencyLineFocusScope.chain,
                  highlightColor: Colors.orange,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    BoxDecoration decorationFor(String taskId) {
      final taskBar = find.byKey(ValueKey('ky-gantt-task-bar-$taskId'));
      final animatedContainer = find.descendant(
        of: taskBar,
        matching: find.byType(AnimatedContainer),
      );
      return tester.widget<AnimatedContainer>(animatedContainer).decoration!
          as BoxDecoration;
    }

    expect((decorationFor('strategy').border! as Border).top.width, 2);
    expect((decorationFor('launch').border! as Border).top.width, 2);
    expect((decorationFor('finance').border! as Border).top.width, 1);
    expect(
      find.byTooltip(
        'Strategy\n'
        'Status: Planned\n'
        'Progress: 0%\n'
        'Dates: Jan 1-2\n'
        'Duration: 2d\n'
        'Focus: dependency relationship',
      ),
      findsOneWidget,
    );
  });

  testWidgets('task bar exposes progress tooltip and tap handling', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 42,
            child: KyGanttTaskBar(
              task: GanttTask(
                id: 'design',
                title: 'Design',
                startDate: DateTime(2026, 1, 1),
                endDate: DateTime(2026, 1, 3),
                progress: 0.65,
                color: Colors.teal,
              ),
              selected: true,
              startsBeforeRange: true,
              endsAfterRange: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byTooltip(
        'Design\n'
        'Status: Active\n'
        'Progress: 65%\n'
        'Dates: Jan 1-3\n'
        'Duration: 3d\n'
        'Visible range clips both ends',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byType(KyGanttTaskBar));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('task bar can hide metadata tooltips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 42,
            child: KyGanttTaskBar(
              task: GanttTask(
                id: 'design',
                title: 'Design',
                startDate: DateTime(2026, 1, 1),
                endDate: DateTime(2026, 1, 3),
                progress: 0.65,
                color: Colors.teal,
              ),
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                taskBarTooltip: KyGanttTaskBarTooltipOptions(visible: false),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(Tooltip), findsNothing);
    expect(find.byType(KyGanttTaskBar), findsOneWidget);
  });

  testWidgets('task bar can render schedule badges when enabled', (
    tester,
  ) async {
    final task = GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 3),
      progress: 0.25,
      color: Colors.teal,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 260,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              today: DateTime(2026, 1, 4),
              displayOptions: const KyGanttChartDisplayOptions(
                taskBarScheduleBadge: KyGanttTaskBarScheduleBadgeOptions(
                  visible: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-schedule-badge-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-schedule-accent-design')),
      findsOneWidget,
    );
    expect(find.text('Late'), findsOneWidget);
    expect(
      find.byTooltip(
        'Design\n'
        'Status: Active\n'
        'Progress: 25%\n'
        'Dates: Jan 1-3\n'
        'Duration: 3d\n'
        'Schedule: Overdue',
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 260,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              today: DateTime(2026, 1, 4),
              displayOptions: const KyGanttChartDisplayOptions(
                taskBarScheduleBadge: KyGanttTaskBarScheduleBadgeOptions(
                  visible: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-schedule-badge-design')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-schedule-accent-design')),
      findsNothing,
    );
  });

  testWidgets('chart passes today into schedule badges', (tester) async {
    final tasks = [
      GanttTask(
        id: 'handoff',
        title: 'Handoff',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 5),
        progress: 0.25,
        color: Colors.teal,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 180,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 8),
              ),
              today: DateTime(2026, 1, 6),
              dayWidth: 42,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                taskBarScheduleBadge: KyGanttTaskBarScheduleBadgeOptions(
                  visible: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-schedule-badge-handoff')),
      findsOneWidget,
    );
    expect(find.text('Late'), findsOneWidget);
  });

  testWidgets('task bar can render width-aware progress labels', (
    tester,
  ) async {
    final task = GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 3),
      progress: 0.65,
      color: Colors.teal,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarProgressLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-progress-label-design')),
      findsOneWidget,
    );
    expect(find.text('65%'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 90,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarProgressLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-progress-label-design')),
      findsNothing,
    );
  });

  testWidgets('task bar can render width-aware date labels', (tester) async {
    final task = GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 3),
      progress: 0.65,
      color: Colors.teal,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDateLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-date-label-design')),
      findsOneWidget,
    );
    expect(find.text('Jan 1-3'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDateLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-date-label-design')),
      findsNothing,
    );
  });

  testWidgets('task bar can render width-aware duration labels', (
    tester,
  ) async {
    final task = GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 14),
      progress: 0.65,
      color: Colors.teal,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDurationLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-duration-label-design')),
      findsOneWidget,
    );
    expect(find.text('2w'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDurationLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-duration-label-design')),
      findsNothing,
    );
  });

  testWidgets('task bar can render width-aware dependency badges', (
    tester,
  ) async {
    final task = GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 3),
      dependsOn: 'strategy',
      progress: 0.65,
      color: Colors.teal,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDependencyBadges: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-dependency-badge-design')),
      findsOneWidget,
    );
    expect(find.text('1 dep'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 42,
            child: KyGanttTaskBar(
              task: task.copyWith(dependsOn: ''),
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDependencyBadges: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-dependency-badge-design')),
      findsNothing,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDependencyBadges: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-dependency-badge-design')),
      findsNothing,
    );
  });

  testWidgets('task bar can render width-aware dependency conflict badges', (
    tester,
  ) async {
    final task = GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 3),
      dependsOn: 'strategy',
      progress: 0.65,
      color: Colors.teal,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              dependencyConflicted: true,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDependencyConflictBadges: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey('ky-gantt-task-dependency-conflict-badge-design'),
      ),
      findsOneWidget,
    );
    expect(find.text('Risk'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              dependencyConflicted: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDependencyConflictBadges: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey('ky-gantt-task-dependency-conflict-badge-design'),
      ),
      findsNothing,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              dependencyConflicted: true,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDependencyConflictBadges: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(
        const ValueKey('ky-gantt-task-dependency-conflict-badge-design'),
      ),
      findsNothing,
    );
  });

  testWidgets('task bar can render width-aware status labels', (tester) async {
    final task = GanttTask(
      id: 'design',
      title: 'Design',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 3),
      progress: 0.65,
      color: Colors.teal,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarStatusLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-status-label-design')),
      findsOneWidget,
    );
    expect(find.text('Active'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 42,
            child: KyGanttTaskBar(
              task: task,
              selected: false,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarStatusLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-status-label-design')),
      findsNothing,
    );
  });

  testWidgets('milestone marker exposes tooltip and tap handling', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 64,
            height: 64,
            child: KyGanttMilestoneMarker(
              task: GanttTask(
                id: 'launch',
                title: 'Launch',
                startDate: DateTime(2026, 1, 3),
                endDate: DateTime(2026, 1, 3),
                kind: GanttTaskKind.milestone,
                color: Colors.purple,
              ),
              selected: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.byTooltip('Launch - milestone'), findsOneWidget);

    await tester.tap(find.byType(KyGanttMilestoneMarker));
    await tester.pump();

    expect(tapped, isTrue);
  });

  test('today marker resolves visible offsets', () {
    expect(
      KyGanttTodayMarker.todayOffsetDays(
        today: DateTime(2026, 1, 3, 18),
        rangeStart: DateTime(2026, 1, 1),
        totalDays: 5,
      ),
      2,
    );
    expect(
      KyGanttTodayMarker.todayOffsetDays(
        today: DateTime(2025, 12, 31),
        rangeStart: DateTime(2026, 1, 1),
        totalDays: 5,
      ),
      isNull,
    );
    expect(
      KyGanttTodayMarker.todayOffsetDays(
        today: DateTime(2026, 1, 6),
        rangeStart: DateTime(2026, 1, 1),
        totalDays: 5,
      ),
      isNull,
    );
  });

  testWidgets('today marker renders at the expected timeline offset', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 80,
            child: Stack(
              children: [
                KyGanttTodayMarker(
                  rangeStart: DateTime(2026, 1, 1),
                  totalDays: 5,
                  dayWidth: 20,
                  height: 60,
                  today: DateTime(2026, 1, 3, 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final marker = find.byKey(KyGanttTodayMarker.defaultMarkerKey);

    expect(marker, findsOneWidget);
    expect(tester.getTopLeft(marker).dx, 40);
  });

  testWidgets('renders a selectable gantt chart', (tester) async {
    String? selectedTaskId;
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
        progress: 0.5,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KyGanttChart(
            tasks: tasks,
            dateRange: DateTimeRange(
              start: DateTime(2026, 1),
              end: DateTime(2026, 1, 10),
            ),
            onTaskSelected: (taskId) => selectedTaskId = taskId,
          ),
        ),
      ),
    );

    expect(find.byType(KyGanttChart), findsOneWidget);
    expect(find.byKey(const ValueKey('ky-gantt-grid')), findsOneWidget);
    expect(find.widgetWithText(KyGanttTaskListRow, 'Design'), findsOneWidget);

    await tester.tap(find.widgetWithText(KyGanttTaskListRow, 'Design'));
    await tester.pump();

    expect(selectedTaskId, 'design');
  });

  testWidgets('chart constrains timeline header height in tight layouts', (
    tester,
  ) async {
    final tasks = [
      for (var index = 0; index < 7; index++)
        GanttTask(
          id: 'task-$index',
          title: 'Task $index',
          startDate: DateTime(2026, 1, index + 1),
          endDate: DateTime(2026, 1, index + 4),
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            height: 204,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1),
                end: DateTime(2026, 1, 20),
              ),
              headerHeight: 62,
              rowHeight: 58,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('ky-gantt-timeline-header-scroll')),
          )
          .height,
      62,
    );
    expect(find.widgetWithText(KyGanttTaskListRow, 'Task 0'), findsOneWidget);
  });

  testWidgets('chart scrolls app-like task trees in tight layouts', (
    tester,
  ) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final tasks = [
      GanttTask(
        id: '1',
        title: 'Project Planning',
        startDate: today.subtract(const Duration(days: 5)),
        endDate: today.add(const Duration(days: 2)),
        subtasks: [
          GanttTask(
            id: '1.1',
            title: 'Requirements Gathering',
            startDate: today.subtract(const Duration(days: 5)),
            endDate: today.subtract(const Duration(days: 2)),
          ),
          GanttTask(
            id: '1.2',
            title: 'Resource Allocation',
            startDate: today.subtract(const Duration(days: 1)),
            endDate: today.add(const Duration(days: 2)),
          ),
        ],
      ),
      GanttTask(
        id: '2',
        title: 'Design Phase',
        startDate: today.add(const Duration(days: 3)),
        endDate: today.add(const Duration(days: 10)),
        dependsOn: '1',
      ),
      GanttTask(
        id: '3',
        title: 'Development',
        startDate: today.add(const Duration(days: 11)),
        endDate: today.add(const Duration(days: 25)),
        dependsOn: '2',
      ),
      GanttTask(
        id: '4',
        title: 'Testing',
        startDate: today.add(const Duration(days: 25)),
        endDate: today.add(const Duration(days: 30)),
        dependsOn: '3',
      ),
      GanttTask(
        id: '5',
        title: 'Launch Readiness',
        startDate: today.add(const Duration(days: 30)),
        endDate: today.add(const Duration(days: 30)),
        kind: GanttTaskKind.milestone,
        dependsOn: '4',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 768,
            height: 204,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(today.year, today.month),
                end: DateTime(today.year, today.month + 1, 0),
              ),
              viewMode: KyGanttViewMode.week,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarDateLabels: true,
                showTaskBarDurationLabels: true,
                showTaskBarDependencyBadges: true,
                showTaskBarDependencyConflictBadges: true,
                showTaskBarProgressLabels: true,
                showTaskBarStatusLabels: true,
                taskBarScheduleBadge: KyGanttTaskBarScheduleBadgeOptions(
                  visible: true,
                ),
                showMilestoneLabels: true,
                showMilestoneDateLabels: true,
                dependencyLines: KyGanttDependencyLineOptions(
                  visible: true,
                  highlightSelectedTask: true,
                  highlightRelatedTaskBars: true,
                  highlightConflictedDependencies: true,
                  focusScope: KyGanttDependencyLineFocusScope.chain,
                ),
              ),
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                enableTaskBarResize: true,
                resizeHandleVisibility:
                    KyGanttTaskResizeHandleVisibility.focused,
              ),
              dayWidth: 42,
              headerHeight: 62,
              rowHeight: 58,
              initialFocusDate: today,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.widgetWithText(KyGanttTaskListRow, 'Project Planning'),
        findsOneWidget);
    expect(find.widgetWithText(KyGanttTaskListRow, 'Launch Readiness'),
        findsOneWidget);
  });

  testWidgets('chart shrinks header during compressed layout transitions', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 768,
            height: 12,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1),
                end: DateTime(2026, 1, 10),
              ),
              headerHeight: 62,
              rowHeight: 58,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('ky-gantt-timeline-header-scroll')),
          )
          .height,
      12,
    );
  });

  testWidgets('collapses and expands gantt task tree rows', (tester) async {
    var collapsedTaskIds = <String>{};
    final tasks = [
      GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
        subtasks: [
          GanttTask(
            id: 'requirements',
            title: 'Requirements',
            startDate: DateTime(2026, 1, 2),
            endDate: DateTime(2026, 1, 3),
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return KyGanttChart(
                tasks: tasks,
                dateRange: DateTimeRange(
                  start: DateTime(2026, 1),
                  end: DateTime(2026, 1, 10),
                ),
                collapsedTaskIds: collapsedTaskIds,
                onTaskCollapseToggled: (taskId) {
                  setState(() {
                    collapsedTaskIds = {...collapsedTaskIds};
                    if (!collapsedTaskIds.add(taskId)) {
                      collapsedTaskIds.remove(taskId);
                    }
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.widgetWithText(KyGanttTaskListRow, 'Planning'), findsOneWidget);
    expect(
      find.widgetWithText(KyGanttTaskListRow, 'Requirements'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('ky-gantt-task-collapse-toggle-planning')),
    );
    await tester.pump();

    expect(collapsedTaskIds, {'planning'});
    expect(
      find.widgetWithText(KyGanttTaskListRow, 'Requirements'),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('ky-gantt-task-collapse-toggle-planning')),
    );
    await tester.pump();

    expect(collapsedTaskIds, isEmpty);
    expect(
      find.widgetWithText(KyGanttTaskListRow, 'Requirements'),
      findsOneWidget,
    );
  });

  testWidgets('clips timeline bars to the visible date range', (tester) async {
    final tasks = [
      GanttTask(
        id: 'long',
        title: 'Long running task',
        startDate: DateTime(2025, 12, 28),
        endDate: DateTime(2026, 1, 14),
      ),
      GanttTask(
        id: 'outside',
        title: 'Outside range task',
        startDate: DateTime(2026, 1, 20),
        endDate: DateTime(2026, 1, 21),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            height: 260,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 5),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 20,
              stickyWidth: 180,
            ),
          ),
        ),
      ),
    );

    final clippedBar = find.byKey(const ValueKey('ky-gantt-task-bar-long'));
    expect(clippedBar, findsOneWidget);
    expect(tester.getSize(clippedBar).width, 120);
    expect(
      find.byKey(const ValueKey('ky-gantt-task-bar-outside')),
      findsNothing,
    );
  });

  testWidgets('drags task bars to report a new date range', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];
    GanttTask? movedTask;
    DateTime? movedStartDate;
    DateTime? movedEndDate;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
              ),
              onTaskDateRangeChanged: (task, startDate, endDate) {
                movedTask = task;
                movedStartDate = startDate;
                movedEndDate = endDate;
              },
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey('ky-gantt-task-bar-design')),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();

    expect(movedTask?.id, 'design');
    expect(movedStartDate, DateTime(2026, 1, 3));
    expect(movedEndDate, DateTime(2026, 1, 5));
  });

  testWidgets('reports rejected task bar date range changes', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];
    var commitCount = 0;
    GanttTask? rejectedTask;
    DateTime? rejectedStartDate;
    DateTime? rejectedEndDate;
    KyGanttTaskDateRangeValidation? rejectedValidation;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
              ),
              taskDateRangeValidator: (_, __, ___) =>
                  const KyGanttTaskDateRangeValidation.blocked(
                'Dependency guard',
              ),
              onTaskDateRangeChanged: (_, __, ___) => commitCount++,
              onTaskDateRangeChangeRejected: (
                task,
                startDate,
                endDate,
                validation,
              ) {
                rejectedTask = task;
                rejectedStartDate = startDate;
                rejectedEndDate = endDate;
                rejectedValidation = validation;
              },
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey('ky-gantt-task-bar-design')),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();

    expect(commitCount, 0);
    expect(rejectedTask?.id, 'design');
    expect(rejectedStartDate, DateTime(2026, 1, 3));
    expect(rejectedEndDate, DateTime(2026, 1, 5));
    expect(rejectedValidation?.message, 'Dependency guard');
  });

  testWidgets('shows blocked drop pattern while dragging invalid ranges', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
              ),
              taskDateRangeValidator: (_, __, ___) =>
                  const KyGanttTaskDateRangeValidation.blocked(
                'Dependency guard',
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey('ky-gantt-task-interaction-blocked-pattern-design'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey('ky-gantt-task-drop-target-blocked-pattern-design'),
      ),
      findsOneWidget,
    );

    await gesture.up();
  });

  testWidgets('can hide blocked drop pattern while dragging invalid ranges', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarBlockedDropPattern: false,
              ),
              taskDateRangeValidator: (_, __, ___) =>
                  const KyGanttTaskDateRangeValidation.blocked(
                'Dependency guard',
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(
        const ValueKey('ky-gantt-task-interaction-blocked-pattern-design'),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey('ky-gantt-task-drop-target-blocked-pattern-design'),
      ),
      findsNothing,
    );

    await gesture.up();
  });

  testWidgets('shows configurable drag handles for selected draggable bars', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              selectedTaskId: 'design',
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-drag-handle-design')),
      findsOneWidget,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              selectedTaskId: 'design',
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarDragHandle: false,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-drag-handle-design')),
      findsNothing,
    );
  });

  testWidgets('configures resize handle visibility', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarResize: true,
                resizeHandleVisibility:
                    KyGanttTaskResizeHandleVisibility.focused,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-resize-end-handle-design')),
      findsNothing,
    );

    final hover = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await hover.addPointer();
    await hover.moveTo(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-resize-end-handle-design')),
      findsOneWidget,
    );

    await hover.removePointer();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-resize-end-handle-design')),
      findsNothing,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              selectedTaskId: 'design',
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarResize: true,
                resizeHandleVisibility:
                    KyGanttTaskResizeHandleVisibility.focused,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-resize-start-handle-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-resize-end-handle-design')),
      findsOneWidget,
    );
  });

  testWidgets('shows configurable hover focus ring for editable task bars', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-hover-focus-ring-design')),
      findsNothing,
    );

    final hover = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await hover.addPointer();
    await hover.moveTo(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-hover-focus-ring-design')),
      findsOneWidget,
    );

    await hover.removePointer();
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-hover-focus-ring-design')),
      findsNothing,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarHoverFocusRing: false,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final hiddenHover = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await hiddenHover.addPointer();
    await hiddenHover.moveTo(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-hover-focus-ring-design')),
      findsNothing,
    );

    await hiddenHover.removePointer();
  });

  testWidgets('shows a configurable task drag preview while dragging', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
              ),
              taskDragPreviewBuilder: (context, preview) {
                return Text(
                  'Preview ${preview.deltaLabel} ${preview.durationLabel} ${preview.snapLabel}',
                  key: ValueKey('custom-drag-preview-${preview.task.id}'),
                );
              },
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('custom-drag-preview-design')),
      findsOneWidget,
    );
    expect(find.textContaining('Preview'), findsOneWidget);
    expect(find.textContaining('3d'), findsOneWidget);
    expect(find.textContaining('Day snap'), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('custom-drag-preview-design')),
      findsNothing,
    );
  });

  testWidgets('default task drag preview shows duration and snap metadata', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 16),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                dragSnap: KyGanttTaskDragSnap.week,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(160, 0));
    await tester.pump();

    final dragPreview = find.byKey(
      const ValueKey('ky-gantt-task-drag-preview-design'),
    );
    expect(dragPreview, findsOneWidget);
    expect(
      find.descendant(of: dragPreview, matching: find.textContaining('3d')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dragPreview,
        matching: find.textContaining('Week snap'),
      ),
      findsOneWidget,
    );

    await gesture.up();
  });

  testWidgets('shows task interaction feedback when preview pill is disabled', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarDragPreview: false,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-overlay-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-lift-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-ghost-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-drop-target-lane-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-drop-target-band-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guides-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guide-start-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guide-end-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guide-range-label-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guide-validation-design')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-drag-preview-design')),
      findsNothing,
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-overlay-design')),
      findsNothing,
    );
  });

  testWidgets('scales task interaction feedback while dragging', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarDragPreview: false,
                taskBarInteractionFeedback:
                    KyGanttTaskBarInteractionFeedbackOptions(
                  opacityScale: 0.5,
                  blurScale: 2,
                  offsetScale: 1.5,
                ),
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    final liftDecoration = tester
        .widget<DecoratedBox>(
          find
              .descendant(
                of: find.byKey(
                  const ValueKey(
                    'ky-gantt-task-interaction-lift-design',
                  ),
                ),
                matching: find.byType(DecoratedBox),
              )
              .first,
        )
        .decoration as BoxDecoration;
    final liftShadow = liftDecoration.boxShadow!.first;
    expect(liftShadow.blurRadius, 48);
    expect(liftShadow.offset.dy, 15);

    final dropTargetDecoration = tester
        .widget<AnimatedContainer>(
          find.byKey(
            const ValueKey('ky-gantt-task-drop-target-band-design'),
          ),
        )
        .decoration as BoxDecoration;
    final dropTargetShadow = dropTargetDecoration.boxShadow!.first;
    expect(dropTargetShadow.blurRadius, 28);
    expect(dropTargetShadow.offset.dy, 9);

    await gesture.up();
  });

  testWidgets('can hide task interaction lift while dragging', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarInteractionLift: false,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-overlay-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-lift-design')),
      findsNothing,
    );

    await gesture.up();
  });

  testWidgets('can hide task interaction ghost while dragging', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarInteractionGhost: false,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-overlay-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-ghost-design')),
      findsNothing,
    );

    await gesture.up();
  });

  testWidgets('can hide task drop target while dragging', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarDropTarget: false,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-overlay-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-drop-target-lane-design')),
      findsNothing,
    );

    await gesture.up();
  });

  testWidgets('can hide task snap guides while dragging', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarDragGuides: false,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-overlay-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guides-design')),
      findsNothing,
    );

    await gesture.up();
  });

  testWidgets('shows validation badge when preview pill is disabled', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarDragPreview: false,
              ),
              taskDateRangeValidator: (_, __, ___) {
                return const KyGanttTaskDateRangeValidation.blocked(
                  'Dependency guard',
                );
              },
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guide-validation-design')),
      findsOneWidget,
    );
    expect(find.text('Dependency guard'), findsOneWidget);

    await gesture.up();
  });

  testWidgets('can hide validation badge while preview pill is disabled', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarDragPreview: false,
                showTaskBarDragValidationBadge: false,
              ),
              taskDateRangeValidator: (_, __, ___) {
                return const KyGanttTaskDateRangeValidation.blocked(
                  'Dependency guard',
                );
              },
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guides-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guide-validation-design')),
      findsNothing,
    );

    await gesture.up();
  });

  testWidgets('can hide task snap guide date labels while dragging', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 620,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                showTaskBarDragGuideLabels: false,
              ),
              onTaskDateRangeChanged: (_, __, ___) {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guides-design')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-snap-guide-range-label-design')),
      findsNothing,
    );

    await gesture.up();
  });

  testWidgets('snaps task bar dragging by week when configured', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];
    DateTime? movedStartDate;
    DateTime? movedEndDate;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 20),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
                dragSnap: KyGanttTaskDragSnap.week,
              ),
              onTaskDateRangeChanged: (task, startDate, endDate) {
                movedStartDate = startDate;
                movedEndDate = endDate;
              },
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey('ky-gantt-task-bar-design')),
      const Offset(160, 0),
    );
    await tester.pumpAndSettle();

    expect(movedStartDate, DateTime(2026, 1, 8));
    expect(movedEndDate, DateTime(2026, 1, 10));
  });

  testWidgets('resizes task bars from start and end handles', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];
    DateTime? resizedStartDate;
    DateTime? resizedEndDate;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarResize: true,
              ),
              onTaskDateRangeChanged: (task, startDate, endDate) {
                resizedStartDate = startDate;
                resizedEndDate = endDate;
              },
            ),
          ),
        ),
      ),
    );

    await tester.drag(
      find.byKey(const ValueKey('ky-gantt-task-resize-end-handle-design')),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();

    expect(resizedStartDate, DateTime(2026, 1, 1));
    expect(resizedEndDate, DateTime(2026, 1, 5));

    await tester.drag(
      find.byKey(const ValueKey('ky-gantt-task-resize-start-handle-design')),
      const Offset(40, 0),
    );
    await tester.pumpAndSettle();

    expect(resizedStartDate, DateTime(2026, 1, 2));
    expect(resizedEndDate, DateTime(2026, 1, 3));
  });

  testWidgets('blocks invalid task date range changes from validators', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];
    DateTime? movedStartDate;
    DateTime? movedEndDate;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 40,
              stickyWidth: 160,
              interactionOptions: const KyGanttChartInteractionOptions(
                enableTaskBarDrag: true,
              ),
              taskDateRangeValidator: (_, __, ___) {
                return const KyGanttTaskDateRangeValidation.blocked(
                  'Dependency guard',
                );
              },
              onTaskDateRangeChanged: (task, startDate, endDate) {
                movedStartDate = startDate;
                movedEndDate = endDate;
              },
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('ky-gantt-task-bar-design'))),
    );
    await gesture.moveBy(const Offset(80, 0));
    await tester.pump();

    expect(find.text('Dependency guard'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('ky-gantt-task-interaction-overlay-design')),
      findsOneWidget,
    );

    await gesture.up();
    await tester.pumpAndSettle();

    expect(movedStartDate, isNull);
    expect(movedEndDate, isNull);
  });

  testWidgets('renders taskbar avatars when enabled', (tester) async {
    final semantics = tester.ensureSemantics();

    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 6),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 52,
              stickyWidth: 180,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarAvatars: true,
                maxTaskBarAvatars: 2,
                taskBarAvatar: KyGanttTaskBarAvatarOptions(
                  size: 26,
                  overlap: 10,
                  minTaskBarWidth: 96,
                ),
              ),
              taskAvatarBuilder: (task) => const [
                KyGanttTaskAvatar(
                  id: 'maya',
                  label: 'Maya Santoso',
                  initials: 'MS',
                ),
                KyGanttTaskAvatar(
                  id: 'dian',
                  label: 'Dian Lestari',
                  initials: 'DL',
                  tooltip: 'Dian Lestari - QA Lead',
                ),
                KyGanttTaskAvatar(
                  id: 'iqbal',
                  label: 'Iqbal Karim',
                  initials: 'IK',
                  tooltip: 'Iqbal Karim - Backend Lead',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-stack')),
      findsOneWidget,
    );
    final avatarStack = tester
        .widget<KyGanttTaskAvatarStack>(find.byType(KyGanttTaskAvatarStack));
    expect(avatarStack.size, 26);
    expect(avatarStack.overlap, 10);
    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-maya')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-overflow')),
      findsOneWidget,
    );
    expect(
      find.byTooltip(
        '2 more team members\n'
        'Dian Lestari - QA Lead\n'
        'Iqbal Karim - Backend Lead',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Team member: Maya Santoso'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        '2 more team members: '
        'Dian Lestari - QA Lead, '
        'Iqbal Karim - Backend Lead',
      ),
      findsOneWidget,
    );
    semantics.dispose();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            height: 220,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 52,
              stickyWidth: 180,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarAvatars: false,
              ),
              taskAvatarBuilder: (task) => const [
                KyGanttTaskAvatar(id: 'maya', label: 'Maya Santoso'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-task-avatar-stack')),
      findsNothing,
    );
  });

  testWidgets('configures taskbar shadows', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 200,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 8),
              ),
              dayWidth: 48,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarShadows: true,
                taskBarShadow: KyGanttTaskBarShadowOptions(
                  opacityScale: 0.5,
                  blurScale: 2,
                  offsetScale: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    BoxDecoration taskBarDecoration() {
      final taskBar = find.byKey(const ValueKey('ky-gantt-task-bar-design'));
      final animatedContainer = find.descendant(
        of: taskBar,
        matching: find.byType(AnimatedContainer),
      );
      return tester.widget<AnimatedContainer>(animatedContainer).decoration!
          as BoxDecoration;
    }

    final shadows = taskBarDecoration().boxShadow!;
    expect(shadows, hasLength(1));
    expect(shadows.single.blurRadius, 20);
    expect(shadows.single.offset.dy, 4.5);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 200,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 8),
              ),
              dayWidth: 48,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarShadows: false,
              ),
            ),
          ),
        ),
      ),
    );

    expect(taskBarDecoration().boxShadow, isNull);
  });

  testWidgets('configures selected task focus glow', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 4),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 200,
            child: KyGanttChart(
              tasks: tasks,
              selectedTaskId: 'design',
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 8),
              ),
              dayWidth: 48,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarShadows: false,
              ),
            ),
          ),
        ),
      ),
    );

    BoxDecoration taskBarDecoration() {
      final taskBar = find.byKey(const ValueKey('ky-gantt-task-bar-design'));
      final animatedContainer = find.descendant(
        of: taskBar,
        matching: find.byType(AnimatedContainer),
      );
      return tester.widget<AnimatedContainer>(animatedContainer).decoration!
          as BoxDecoration;
    }

    expect(taskBarDecoration().boxShadow, hasLength(2));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            height: 200,
            child: KyGanttChart(
              tasks: tasks,
              selectedTaskId: 'design',
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 8),
              ),
              dayWidth: 48,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showTaskBarShadows: false,
                showSelectedTaskFocus: false,
              ),
            ),
          ),
        ),
      ),
    );

    expect(taskBarDecoration().boxShadow, isNull);
  });

  testWidgets('renders milestones as diamond markers instead of bars', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'launch',
        title: 'Launch readiness',
        startDate: DateTime(2026, 1, 3),
        endDate: DateTime(2026, 1, 8),
        kind: GanttTaskKind.milestone,
        color: Colors.deepPurple,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 180,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 5),
              ),
              dayWidth: 24,
              stickyWidth: 160,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-milestone-marker-launch')),
      findsOneWidget,
    );
    expect(
        find.byKey(const ValueKey('ky-gantt-task-bar-launch')), findsNothing);
    expect(
        find.widgetWithText(KyGanttTaskListRow, 'Milestone'), findsOneWidget);
  });

  testWidgets('renders milestone labels when enabled and spaced', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'launch',
        title: 'Launch readiness',
        startDate: DateTime(2026, 1, 3),
        endDate: DateTime(2026, 1, 3),
        kind: GanttTaskKind.milestone,
        color: Colors.deepPurple,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 720,
            height: 180,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 52,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showMilestoneLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-milestone-label-launch')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-milestone-date-label-launch')),
      findsNothing,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 180,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 5),
              ),
              dayWidth: 24,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showMilestoneLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-milestone-label-launch')),
      findsNothing,
    );
  });

  testWidgets('renders milestone date labels when enabled and spaced', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'launch',
        title: 'Launch readiness',
        startDate: DateTime(2026, 1, 3),
        endDate: DateTime(2026, 1, 3),
        kind: GanttTaskKind.milestone,
        color: Colors.deepPurple,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            height: 180,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 52,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showMilestoneLabels: true,
                showMilestoneDateLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-milestone-label-launch')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-milestone-date-label-launch')),
      findsOneWidget,
    );
    expect(find.text('Jan 3'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 760,
            height: 180,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 10),
              ),
              dayWidth: 52,
              stickyWidth: 160,
              displayOptions: const KyGanttChartDisplayOptions(
                showMilestoneDateLabels: true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('ky-gantt-milestone-label-launch')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ky-gantt-milestone-date-label-launch')),
      findsOneWidget,
    );
    expect(find.text('Jan 3'), findsOneWidget);
  });

  testWidgets('renders the today marker from an explicit date', (tester) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 180,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 5),
              ),
              today: DateTime(2026, 1, 3, 18),
              dayWidth: 24,
              stickyWidth: 160,
            ),
          ),
        ),
      ),
    );

    final marker = find.byKey(const ValueKey('ky-gantt-today-marker'));
    final headerIndicator = find.byKey(
      KyGanttTimelineHeader.defaultTodayIndicatorKey,
    );

    expect(marker, findsOneWidget);
    expect(headerIndicator, findsOneWidget);
    expect(tester.getTopLeft(marker).dx, 208);
    expect(tester.getTopLeft(headerIndicator).dx, 208);
  });

  testWidgets('hides the today marker outside the visible date range', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 180,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 5),
              ),
              today: DateTime(2026, 1, 6),
              dayWidth: 24,
              stickyWidth: 160,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('ky-gantt-today-marker')), findsNothing);
    expect(
      find.byKey(KyGanttTimelineHeader.defaultTodayIndicatorKey),
      findsNothing,
    );
  });

  testWidgets('hides the today marker when disabled by display options', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 180,
            child: KyGanttChart(
              tasks: tasks,
              dateRange: DateTimeRange(
                start: DateTime(2026, 1, 1),
                end: DateTime(2026, 1, 5),
              ),
              today: DateTime(2026, 1, 3),
              displayOptions: const KyGanttChartDisplayOptions(
                showTodayMarker: false,
              ),
              dayWidth: 24,
              stickyWidth: 160,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('ky-gantt-today-marker')), findsNothing);
    expect(
      find.byKey(KyGanttTimelineHeader.defaultTodayIndicatorKey),
      findsNothing,
    );
  });

  testWidgets('applies an initial focus date to synced timeline scrolls', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'launch',
        title: 'Launch',
        startDate: DateTime(2026, 1, 10),
        endDate: DateTime(2026, 1, 12),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              height: 180,
              child: KyGanttChart(
                tasks: tasks,
                dateRange: DateTimeRange(
                  start: DateTime(2026, 1, 1),
                  end: DateTime(2026, 1, 30),
                ),
                initialFocusDate: DateTime(2026, 1, 10),
                dayWidth: 50,
                stickyWidth: 160,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final headerScrollable = find.descendant(
      of: find.byKey(const ValueKey('ky-gantt-timeline-header-scroll')),
      matching: find.byType(Scrollable),
    );
    final bodyScrollable = find.descendant(
      of: find.byKey(const ValueKey('ky-gantt-timeline-scroll')),
      matching: find.byType(Scrollable),
    );

    expect(
      tester.state<ScrollableState>(headerScrollable).position.pixels,
      375,
    );
    expect(
      tester.state<ScrollableState>(bodyScrollable).position.pixels,
      375,
    );
  });

  testWidgets('keeps the task column fixed while the timeline scrolls', (
    tester,
  ) async {
    final tasks = [
      GanttTask(
        id: 'design',
        title: 'Design',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 3),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 360,
              height: 180,
              child: KyGanttChart(
                tasks: tasks,
                dateRange: DateTimeRange(
                  start: DateTime(2026, 1, 1),
                  end: DateTime(2026, 1, 20),
                ),
                dayWidth: 52,
                stickyWidth: 160,
              ),
            ),
          ),
        ),
      ),
    );

    final taskRow = find.widgetWithText(KyGanttTaskListRow, 'Design');
    final taskBar = find.byKey(const ValueKey('ky-gantt-task-bar-design'));
    final timelineScroll =
        find.byKey(const ValueKey('ky-gantt-timeline-scroll'));

    final taskRowLeftBefore = tester.getTopLeft(taskRow).dx;
    final taskBarLeftBefore = tester.getTopLeft(taskBar).dx;

    await tester.drag(timelineScroll, const Offset(-260, 0));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(taskRow).dx, taskRowLeftBefore);
    expect(tester.getTopLeft(taskBar).dx, lessThan(taskBarLeftBefore));
  });

  testWidgets('keeps chart headers fixed while rows scroll vertically', (
    tester,
  ) async {
    final tasks = [
      for (var index = 0; index < 14; index++)
        GanttTask(
          id: 'task-$index',
          title: 'Task ${index + 1}',
          startDate: DateTime(2026, 1, 1 + index),
          endDate: DateTime(2026, 1, 3 + index),
        ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 480,
              height: 220,
              child: KyGanttChart(
                tasks: tasks,
                dateRange: DateTimeRange(
                  start: DateTime(2026, 1, 1),
                  end: DateTime(2026, 1, 25),
                ),
                dayWidth: 36,
                rowHeight: 42,
                headerHeight: 48,
                stickyWidth: 180,
              ),
            ),
          ),
        ),
      ),
    );

    final header = find.byKey(const ValueKey('ky-gantt-task-header'));
    final verticalScroll =
        find.byKey(const ValueKey('ky-gantt-vertical-scroll'));
    final firstTaskRow = find.widgetWithText(KyGanttTaskListRow, 'Task 1');

    final headerTopBefore = tester.getTopLeft(header).dy;
    final firstTaskTopBefore = tester.getTopLeft(firstTaskRow).dy;

    await tester.drag(verticalScroll, const Offset(0, -150));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(header).dy, headerTopBefore);
    expect(tester.getTopLeft(firstTaskRow).dy, lessThan(firstTaskTopBefore));
  });
}
