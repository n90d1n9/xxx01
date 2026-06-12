import 'package:flutter/material.dart';

import '../models/gantt_chart_display_options.dart';
import '../models/gantt_chart_interaction_options.dart';
import '../models/gantt_task.dart';
import '../models/gantt_view_mode.dart';
import '../utils/gantt_focus_offset.dart';
import '../utils/gantt_timeline_range.dart';
import '../utils/gantt_task_tree.dart';
import 'ky_gantt_task_list.dart';
import 'ky_gantt_timeline.dart';
import 'ky_gantt_timeline_header.dart';

class KyGanttChart extends StatefulWidget {
  const KyGanttChart({
    required this.tasks,
    required this.dateRange,
    this.viewMode = KyGanttViewMode.week,
    this.selectedTaskId,
    this.collapsedTaskIds = const <String>{},
    this.onTaskSelected,
    this.onTaskCollapseToggled,
    this.projectNameBuilder,
    this.displayOptions = const KyGanttChartDisplayOptions(),
    this.interactionOptions = const KyGanttChartInteractionOptions(),
    this.taskAvatarBuilder,
    this.taskDragPreviewBuilder,
    this.taskDateRangeValidator,
    this.onTaskDateRangeChanged,
    this.onTaskDateRangeChangeRejected,
    this.today,
    this.initialFocusDate,
    this.dayWidth,
    this.stickyWidth = 280,
    this.rowHeight = 58,
    this.headerHeight = 62,
    super.key,
  });

  final List<GanttTask> tasks;
  final DateTimeRange dateRange;
  final KyGanttViewMode viewMode;
  final String? selectedTaskId;
  final Set<String> collapsedTaskIds;
  final ValueChanged<String>? onTaskSelected;
  final ValueChanged<String>? onTaskCollapseToggled;
  final KyGanttProjectNameBuilder? projectNameBuilder;
  final KyGanttChartDisplayOptions displayOptions;
  final KyGanttChartInteractionOptions interactionOptions;
  final KyGanttTaskAvatarsBuilder? taskAvatarBuilder;
  final KyGanttTaskDragPreviewBuilder? taskDragPreviewBuilder;
  final KyGanttTaskDateRangeValidator? taskDateRangeValidator;
  final KyGanttTaskDateRangeChanged? onTaskDateRangeChanged;
  final KyGanttTaskDateRangeChangeRejected? onTaskDateRangeChangeRejected;
  final DateTime? today;
  final DateTime? initialFocusDate;
  final double? dayWidth;
  final double stickyWidth;
  final double rowHeight;
  final double headerHeight;

  @override
  State<KyGanttChart> createState() => _KyGanttChartState();
}

class _KyGanttChartState extends State<KyGanttChart> {
  late final ScrollController _timelineHeaderScrollController;
  late final ScrollController _timelineBodyScrollController;
  bool _syncingHorizontalScroll = false;
  bool _initialFocusScheduled = false;
  String? _appliedInitialFocusSignature;

  @override
  void initState() {
    super.initState();
    _timelineHeaderScrollController = ScrollController();
    _timelineBodyScrollController = ScrollController();
    _timelineHeaderScrollController.addListener(_syncHeaderScrollToBody);
    _timelineBodyScrollController.addListener(_syncBodyScrollToHeader);
  }

  @override
  void dispose() {
    _timelineHeaderScrollController.removeListener(_syncHeaderScrollToBody);
    _timelineBodyScrollController.removeListener(_syncBodyScrollToHeader);
    _timelineHeaderScrollController.dispose();
    _timelineBodyScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = flattenGanttTaskNodes(
      widget.tasks,
      collapsedTaskIds: widget.collapsedTaskIds,
    );
    final timelineRange = resolveGanttTimelineRange(
      start: widget.dateRange.start,
      end: widget.dateRange.end,
    );
    final resolvedDayWidth = widget.dayWidth ?? widget.viewMode.defaultDayWidth;
    final timelineWidth = timelineRange.totalDays * resolvedDayWidth;
    final colorScheme = Theme.of(context).colorScheme;

    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    _scheduleInitialFocus(
      timelineRange: timelineRange,
      dayWidth: resolvedDayWidth,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final resolvedStickyWidth = _resolveStickyWidth(constraints);
            _KyGanttHeaderRow buildHeaderRow(double headerHeight) =>
                _KyGanttHeaderRow(
                  stickyWidth: resolvedStickyWidth,
                  timelineWidth: timelineWidth,
                  rangeStart: timelineRange.start,
                  totalDays: timelineRange.totalDays,
                  dayWidth: resolvedDayWidth,
                  headerHeight: headerHeight,
                  viewMode: widget.viewMode,
                  displayOptions: widget.displayOptions,
                  today: widget.today,
                  horizontalScrollController: _timelineHeaderScrollController,
                  expandTimeline: constraints.hasBoundedWidth,
                );
            final bodyRow = _KyGanttBodyRow(
              stickyWidth: resolvedStickyWidth,
              timelineWidth: timelineWidth,
              rangeStart: timelineRange.start,
              rangeEnd: timelineRange.end,
              totalDays: timelineRange.totalDays,
              dayWidth: resolvedDayWidth,
              rowHeight: widget.rowHeight,
              nodes: nodes,
              selectedTaskId: widget.selectedTaskId,
              onTaskSelected: widget.onTaskSelected,
              onTaskCollapseToggled: widget.onTaskCollapseToggled,
              projectNameBuilder: widget.projectNameBuilder,
              displayOptions: widget.displayOptions,
              interactionOptions: widget.interactionOptions,
              taskAvatarBuilder: widget.taskAvatarBuilder,
              taskDragPreviewBuilder: widget.taskDragPreviewBuilder,
              taskDateRangeValidator: widget.taskDateRangeValidator,
              onTaskDateRangeChanged: widget.onTaskDateRangeChanged,
              onTaskDateRangeChangeRejected:
                  widget.onTaskDateRangeChangeRejected,
              today: widget.today,
              horizontalScrollController: _timelineBodyScrollController,
              expandTimeline: constraints.hasBoundedWidth,
            );

            if (constraints.hasBoundedHeight) {
              final resolvedHeaderHeight = constraints.maxHeight
                  .clamp(0.0, widget.headerHeight)
                  .toDouble();
              final headerRow = buildHeaderRow(resolvedHeaderHeight);

              return SizedBox(
                height: constraints.maxHeight,
                child: Column(
                  children: [
                    SizedBox(height: resolvedHeaderHeight, child: headerRow),
                    Expanded(
                      child: SingleChildScrollView(
                        key: const ValueKey('ky-gantt-vertical-scroll'),
                        child: bodyRow,
                      ),
                    ),
                  ],
                ),
              );
            }

            final headerRow = buildHeaderRow(widget.headerHeight);

            return Column(
              children: [
                SizedBox(height: widget.headerHeight, child: headerRow),
                bodyRow,
              ],
            );
          },
        ),
      ),
    );
  }

  double _resolveStickyWidth(BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
      return widget.stickyWidth;
    }

    final maxStickyWidth = constraints.maxWidth * 0.62;
    return widget.stickyWidth.clamp(160, maxStickyWidth).toDouble();
  }

  void _syncHeaderScrollToBody() {
    _syncHorizontalScroll(
      source: _timelineHeaderScrollController,
      target: _timelineBodyScrollController,
    );
  }

  void _syncBodyScrollToHeader() {
    _syncHorizontalScroll(
      source: _timelineBodyScrollController,
      target: _timelineHeaderScrollController,
    );
  }

  void _syncHorizontalScroll({
    required ScrollController source,
    required ScrollController target,
  }) {
    if (_syncingHorizontalScroll || !source.hasClients || !target.hasClients) {
      return;
    }

    final targetPosition = target.position;
    final offset = source.offset
        .clamp(targetPosition.minScrollExtent, targetPosition.maxScrollExtent)
        .toDouble();
    if ((targetPosition.pixels - offset).abs() < 0.5) return;

    _syncingHorizontalScroll = true;
    target.jumpTo(offset);
    _syncingHorizontalScroll = false;
  }

  void _scheduleInitialFocus({
    required GanttTimelineRange timelineRange,
    required double dayWidth,
  }) {
    final focusDate = widget.initialFocusDate;
    if (focusDate == null) return;

    final signature = _initialFocusSignature(
      focusDate: focusDate,
      timelineRange: timelineRange,
      dayWidth: dayWidth,
    );
    if (_initialFocusScheduled || _appliedInitialFocusSignature == signature) {
      return;
    }

    _initialFocusScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialFocusScheduled = false;
      if (!mounted || !_timelineBodyScrollController.hasClients) return;

      final position = _timelineBodyScrollController.position;
      final offset = initialGanttFocusScrollOffset(
        focusDate: focusDate,
        rangeStart: timelineRange.start,
        totalDays: timelineRange.totalDays,
        dayWidth: dayWidth,
        viewportWidth: position.viewportDimension,
      );

      _jumpHorizontalScroll(offset);
      _appliedInitialFocusSignature = signature;
    });
  }

  String _initialFocusSignature({
    required DateTime focusDate,
    required GanttTimelineRange timelineRange,
    required double dayWidth,
  }) {
    final normalizedFocusDate = DateUtils.dateOnly(focusDate);

    return [
      normalizedFocusDate.microsecondsSinceEpoch,
      timelineRange.start.microsecondsSinceEpoch,
      timelineRange.end.microsecondsSinceEpoch,
      dayWidth,
    ].join(':');
  }

  void _jumpHorizontalScroll(double offset) {
    _syncingHorizontalScroll = true;
    try {
      _jumpScrollController(_timelineHeaderScrollController, offset);
      _jumpScrollController(_timelineBodyScrollController, offset);
    } finally {
      _syncingHorizontalScroll = false;
    }
  }

  void _jumpScrollController(ScrollController controller, double offset) {
    if (!controller.hasClients) return;

    final position = controller.position;
    final clampedOffset = offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if ((position.pixels - clampedOffset).abs() < 0.5) return;

    controller.jumpTo(clampedOffset);
  }
}

class _KyGanttHeaderRow extends StatelessWidget {
  const _KyGanttHeaderRow({
    required this.stickyWidth,
    required this.timelineWidth,
    required this.rangeStart,
    required this.totalDays,
    required this.dayWidth,
    required this.headerHeight,
    required this.viewMode,
    required this.displayOptions,
    required this.today,
    required this.horizontalScrollController,
    required this.expandTimeline,
  });

  final double stickyWidth;
  final double timelineWidth;
  final DateTime rangeStart;
  final int totalDays;
  final double dayWidth;
  final double headerHeight;
  final KyGanttViewMode viewMode;
  final KyGanttChartDisplayOptions displayOptions;
  final DateTime? today;
  final ScrollController horizontalScrollController;
  final bool expandTimeline;

  @override
  Widget build(BuildContext context) {
    final timelineHeader = SizedBox(
      height: headerHeight,
      child: SingleChildScrollView(
        key: const ValueKey('ky-gantt-timeline-header-scroll'),
        controller: horizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: timelineWidth,
          child: KyGanttTimelineHeader(
            rangeStart: rangeStart,
            totalDays: totalDays,
            dayWidth: dayWidth,
            height: headerHeight,
            viewMode: viewMode,
            today: today,
            showTodayMarker: displayOptions.showTodayMarker,
            showWeekendBands: displayOptions.showWeekendBands,
            weekendBandColor: displayOptions.weekendBandColor,
            weekendBandOpacity: displayOptions.weekendBandOpacity,
            todayIndicatorOpacity: displayOptions.todayIndicatorOpacity,
          ),
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: stickyWidth,
          child: _KyGanttTaskHeader(height: headerHeight),
        ),
        if (expandTimeline) Expanded(child: timelineHeader) else timelineHeader,
      ],
    );
  }
}

class _KyGanttBodyRow extends StatelessWidget {
  const _KyGanttBodyRow({
    required this.stickyWidth,
    required this.timelineWidth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.totalDays,
    required this.dayWidth,
    required this.rowHeight,
    required this.nodes,
    required this.selectedTaskId,
    required this.onTaskSelected,
    required this.onTaskCollapseToggled,
    required this.projectNameBuilder,
    required this.displayOptions,
    required this.interactionOptions,
    required this.taskAvatarBuilder,
    required this.taskDragPreviewBuilder,
    required this.taskDateRangeValidator,
    required this.onTaskDateRangeChanged,
    required this.onTaskDateRangeChangeRejected,
    required this.today,
    required this.horizontalScrollController,
    required this.expandTimeline,
  });

  final double stickyWidth;
  final double timelineWidth;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int totalDays;
  final double dayWidth;
  final double rowHeight;
  final List<GanttTaskNode> nodes;
  final String? selectedTaskId;
  final ValueChanged<String>? onTaskSelected;
  final ValueChanged<String>? onTaskCollapseToggled;
  final KyGanttProjectNameBuilder? projectNameBuilder;
  final KyGanttChartDisplayOptions displayOptions;
  final KyGanttChartInteractionOptions interactionOptions;
  final KyGanttTaskAvatarsBuilder? taskAvatarBuilder;
  final KyGanttTaskDragPreviewBuilder? taskDragPreviewBuilder;
  final KyGanttTaskDateRangeValidator? taskDateRangeValidator;
  final KyGanttTaskDateRangeChanged? onTaskDateRangeChanged;
  final KyGanttTaskDateRangeChangeRejected? onTaskDateRangeChangeRejected;
  final DateTime? today;
  final ScrollController horizontalScrollController;
  final bool expandTimeline;

  @override
  Widget build(BuildContext context) {
    final timeline = SingleChildScrollView(
      key: const ValueKey('ky-gantt-timeline-scroll'),
      controller: horizontalScrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: timelineWidth,
        child: KyGanttTimeline(
          nodes: nodes,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
          totalDays: totalDays,
          dayWidth: dayWidth,
          rowHeight: rowHeight,
          selectedTaskId: selectedTaskId,
          displayOptions: displayOptions,
          interactionOptions: interactionOptions,
          taskAvatarBuilder: taskAvatarBuilder,
          taskDragPreviewBuilder: taskDragPreviewBuilder,
          taskDateRangeValidator: taskDateRangeValidator,
          onTaskDateRangeChanged: onTaskDateRangeChanged,
          onTaskDateRangeChangeRejected: onTaskDateRangeChangeRejected,
          today: today,
          onTaskSelected: onTaskSelected,
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: stickyWidth,
          child: KyGanttTaskList(
            nodes: nodes,
            rowHeight: rowHeight,
            selectedTaskId: selectedTaskId,
            displayOptions: displayOptions,
            onTaskSelected: onTaskSelected,
            onTaskCollapseToggled: onTaskCollapseToggled,
            projectNameBuilder: projectNameBuilder,
          ),
        ),
        if (expandTimeline) Expanded(child: timeline) else timeline,
      ],
    );
  }
}

class _KyGanttTaskHeader extends StatelessWidget {
  const _KyGanttTaskHeader({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: const ValueKey('ky-gantt-task-header'),
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant),
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Task',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Done',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
