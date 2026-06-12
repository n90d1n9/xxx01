import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/gantt_chart_display_options.dart';
import '../models/gantt_chart_interaction_options.dart';
import '../models/gantt_task.dart';
import '../utils/gantt_dependency_focus.dart';
import '../utils/gantt_dependency_health.dart';
import '../utils/gantt_task_layout.dart';
import '../utils/gantt_task_tree.dart';
import 'ky_gantt_dependency_layer.dart';
import 'ky_gantt_grid.dart';
import 'ky_gantt_milestone_marker.dart';
import 'ky_gantt_selected_task_row_highlight.dart';
import 'ky_gantt_task_bar.dart';
import 'ky_gantt_today_marker.dart';

class KyGanttTimeline extends StatelessWidget {
  const KyGanttTimeline({
    required this.nodes,
    required this.rangeStart,
    required this.rangeEnd,
    required this.totalDays,
    required this.dayWidth,
    required this.rowHeight,
    required this.selectedTaskId,
    this.displayOptions = const KyGanttChartDisplayOptions(),
    this.interactionOptions = const KyGanttChartInteractionOptions(),
    this.taskAvatarBuilder,
    this.taskDragPreviewBuilder,
    this.taskDateRangeValidator,
    this.onTaskDateRangeChanged,
    this.onTaskDateRangeChangeRejected,
    this.today,
    this.onTaskSelected,
    super.key,
  });

  final List<GanttTaskNode> nodes;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int totalDays;
  final double dayWidth;
  final double rowHeight;
  final String? selectedTaskId;
  final KyGanttChartDisplayOptions displayOptions;
  final KyGanttChartInteractionOptions interactionOptions;
  final KyGanttTaskAvatarsBuilder? taskAvatarBuilder;
  final KyGanttTaskDragPreviewBuilder? taskDragPreviewBuilder;
  final KyGanttTaskDateRangeValidator? taskDateRangeValidator;
  final KyGanttTaskDateRangeChanged? onTaskDateRangeChanged;
  final KyGanttTaskDateRangeChangeRejected? onTaskDateRangeChangeRejected;
  final DateTime? today;
  final ValueChanged<String>? onTaskSelected;

  @override
  Widget build(BuildContext context) {
    final height = nodes.length * rowHeight;
    final width = totalDays * dayWidth;
    final flatTasks = [for (final node in nodes) node.task];
    final selectedRowIndex = nodes.indexWhere(
      (node) => node.task.id == selectedTaskId,
    );
    final dependencyLines = displayOptions.dependencyLines;
    final conflictedTaskIds = displayOptions.showTaskBarDependencyConflictBadges
        ? conflictedGanttDependencyTaskIds(tasks: flatTasks)
        : const <String>{};
    final focusedTaskIds = focusedGanttDependencyTaskIds(
      tasks: flatTasks,
      selectedTaskId: selectedTaskId,
      enabled: dependencyLines.visible &&
          dependencyLines.highlightSelectedTask &&
          dependencyLines.highlightRelatedTaskBars,
      focusScope: dependencyLines.focusScope,
    );

    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          KyGanttGrid(
            rangeStart: rangeStart,
            totalDays: totalDays,
            dayWidth: dayWidth,
            rowHeight: rowHeight,
            rowCount: nodes.length,
            showWeekendBands: displayOptions.showWeekendBands,
            weekendBandColor: displayOptions.weekendBandColor,
            weekendBandOpacity: displayOptions.weekendBandOpacity,
          ),
          if (displayOptions.showSelectedTaskRowHighlight &&
              selectedRowIndex >= 0)
            KyGanttSelectedTaskRowHighlight(
              selectedRowIndex: selectedRowIndex,
              width: width,
              rowHeight: rowHeight,
              color: displayOptions.selectedTaskRowHighlightColor,
              opacity: displayOptions.selectedTaskRowHighlightOpacity,
            ),
          if (dependencyLines.visible)
            KyGanttDependencyLayer(
              tasks: flatTasks,
              rangeStart: rangeStart,
              rangeEnd: rangeEnd,
              totalDays: totalDays,
              dayWidth: dayWidth,
              rowHeight: rowHeight,
              selectedTaskId: selectedTaskId,
              highlightSelectedTask: dependencyLines.highlightSelectedTask,
              highlightConflictedDependencies:
                  dependencyLines.highlightConflictedDependencies,
              focusScope: dependencyLines.focusScope,
              color: dependencyLines.color,
              highlightColor: dependencyLines.highlightColor,
              conflictColor: dependencyLines.conflictColor,
              lineOpacity: dependencyLines.lineOpacity,
              inactiveLineOpacity: dependencyLines.inactiveLineOpacity,
              highlightLineOpacity: dependencyLines.highlightLineOpacity,
              conflictLineOpacity: dependencyLines.conflictLineOpacity,
              strokeWidth: dependencyLines.strokeWidth,
              highlightStrokeWidth: dependencyLines.highlightStrokeWidth,
              conflictStrokeWidth: dependencyLines.conflictStrokeWidth,
            ),
          for (var index = 0; index < nodes.length; index++)
            _KyGanttPositionedTaskItem(
              task: nodes[index].task,
              top: index * rowHeight,
              timelineWidth: width,
              rangeStart: rangeStart,
              rangeEnd: rangeEnd,
              dayWidth: dayWidth,
              rowHeight: rowHeight,
              selected: nodes[index].task.id == selectedTaskId,
              dependencyFocused: focusedTaskIds.contains(nodes[index].task.id),
              dependencyConflicted:
                  conflictedTaskIds.contains(nodes[index].task.id),
              displayOptions: displayOptions,
              interactionOptions: interactionOptions,
              avatars: taskAvatarBuilder?.call(nodes[index].task) ?? const [],
              today: today,
              taskDragPreviewBuilder: taskDragPreviewBuilder,
              taskDateRangeValidator: taskDateRangeValidator,
              onTaskDateRangeChanged: onTaskDateRangeChanged,
              onTaskDateRangeChangeRejected: onTaskDateRangeChangeRejected,
              onTap: onTaskSelected == null
                  ? null
                  : () => onTaskSelected!(nodes[index].task.id),
            ),
          if (displayOptions.showTodayMarker)
            KyGanttTodayMarker(
              rangeStart: rangeStart,
              totalDays: totalDays,
              dayWidth: dayWidth,
              height: height,
              today: today ?? DateTime.now(),
              opacity: displayOptions.todayMarkerOpacity,
            ),
        ],
      ),
    );
  }
}

class _KyGanttPositionedTaskItem extends StatelessWidget {
  const _KyGanttPositionedTaskItem({
    required this.task,
    required this.top,
    required this.timelineWidth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.dayWidth,
    required this.rowHeight,
    required this.selected,
    required this.dependencyFocused,
    required this.dependencyConflicted,
    required this.displayOptions,
    required this.interactionOptions,
    required this.avatars,
    required this.today,
    required this.taskDragPreviewBuilder,
    required this.taskDateRangeValidator,
    required this.onTaskDateRangeChanged,
    required this.onTaskDateRangeChangeRejected,
    this.onTap,
  });

  final GanttTask task;
  final double top;
  final double timelineWidth;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final double dayWidth;
  final double rowHeight;
  final bool selected;
  final bool dependencyFocused;
  final bool dependencyConflicted;
  final KyGanttChartDisplayOptions displayOptions;
  final KyGanttChartInteractionOptions interactionOptions;
  final List<KyGanttTaskAvatar> avatars;
  final DateTime? today;
  final KyGanttTaskDragPreviewBuilder? taskDragPreviewBuilder;
  final KyGanttTaskDateRangeValidator? taskDateRangeValidator;
  final KyGanttTaskDateRangeChanged? onTaskDateRangeChanged;
  final KyGanttTaskDateRangeChangeRejected? onTaskDateRangeChangeRejected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (task.isMilestone) {
      return _buildMilestoneMarker();
    }

    final visibleSegment = visibleSegmentForTask(
      task: task,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
    if (visibleSegment == null) return const SizedBox.shrink();

    final width = visibleSegment.width(dayWidth);

    return _KyGanttDraggablePositionedTaskBar(
      task: task,
      selected: selected,
      dependencyFocused: dependencyFocused,
      dependencyConflicted: dependencyConflicted,
      left: visibleSegment.left(dayWidth),
      top: top + 10,
      width: width,
      height: rowHeight - 20,
      dayWidth: dayWidth,
      timelineWidth: timelineWidth,
      displayOptions: displayOptions,
      interactionOptions: interactionOptions,
      avatars: avatars,
      today: today,
      taskDragPreviewBuilder: taskDragPreviewBuilder,
      taskDateRangeValidator: taskDateRangeValidator,
      onTaskDateRangeChangeRejected: onTaskDateRangeChangeRejected,
      startsBeforeRange: visibleSegment.startsBeforeRange,
      endsAfterRange: visibleSegment.endsAfterRange,
      semanticLabel: _semanticsLabel(visibleSegment),
      onTap: onTap,
      onTaskDateRangeChanged: onTaskDateRangeChanged,
    );
  }

  Widget _buildMilestoneMarker() {
    final offsetDays = milestoneOffsetDaysForTask(
      task: task,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
    if (offsetDays == null) return const SizedBox.shrink();

    final markerSize = (rowHeight - 20).clamp(14, 22).toDouble();
    final markerLeft =
        (offsetDays * dayWidth) + (dayWidth / 2) - (markerSize / 2);
    final markerTop = top + (rowHeight - markerSize) / 2;
    final showMilestoneLabel = displayOptions.showMilestoneLabels;
    final showMilestoneDateLabel = displayOptions.showMilestoneDateLabels;
    final labelWidth = _milestoneLabelWidth(
      showTitle: showMilestoneLabel,
      showDate: showMilestoneDateLabel,
    );
    final labelPlacement = labelWidth != null && rowHeight >= 40
        ? _milestoneLabelPlacement(
            markerLeft: markerLeft,
            markerSize: markerSize,
            timelineWidth: _timelineWidth,
            labelWidth: labelWidth,
          )
        : null;

    return Positioned(
      left: markerLeft,
      top: markerTop,
      width: markerSize,
      height: markerSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: KyGanttMilestoneMarker(
              key: ValueKey('ky-gantt-milestone-marker-${task.id}'),
              task: task,
              selected: selected,
              size: markerSize,
              displayOptions: displayOptions,
              semanticLabel: '${task.title}, milestone',
              onTap: onTap,
            ),
          ),
          if (labelPlacement != null)
            Positioned(
              left: labelPlacement.left,
              top: (markerSize - _milestoneLabelHeight) / 2,
              width: labelPlacement.width,
              height: _milestoneLabelHeight,
              child: _KyGanttMilestoneLabel(
                key: ValueKey('ky-gantt-milestone-label-${task.id}'),
                task: task,
                selected: selected,
                showTitle: showMilestoneLabel,
                showDate: showMilestoneDateLabel,
              ),
            ),
        ],
      ),
    );
  }

  double? _milestoneLabelWidth({
    required bool showTitle,
    required bool showDate,
  }) {
    if (showTitle && showDate) return 184;
    if (showTitle) return 132;
    if (showDate) return 74;
    return null;
  }

  _KyGanttMilestoneLabelPlacement? _milestoneLabelPlacement({
    required double markerLeft,
    required double markerSize,
    required double timelineWidth,
    required double labelWidth,
  }) {
    const gap = 8.0;

    final rightLabelEnd = markerLeft + markerSize + gap + labelWidth;
    if (rightLabelEnd <= timelineWidth) {
      return _KyGanttMilestoneLabelPlacement(
        left: markerSize + gap,
        width: labelWidth,
      );
    }

    final leftLabelStart = markerLeft - gap - labelWidth;
    if (leftLabelStart >= 0) {
      return _KyGanttMilestoneLabelPlacement(
        left: -(labelWidth + gap),
        width: labelWidth,
      );
    }

    return null;
  }

  double get _timelineWidth {
    final normalizedRangeStart = DateUtils.dateOnly(rangeStart);
    final normalizedRangeEnd = DateUtils.dateOnly(rangeEnd);
    final totalDays =
        normalizedRangeEnd.difference(normalizedRangeStart).inDays.abs() + 1;
    return totalDays * dayWidth;
  }

  String _semanticsLabel(GanttTaskVisibleSegment visibleSegment) {
    final progressText = '${(task.progress.clamp(0, 1) * 100).round()}%';
    final rangeHint =
        visibleSegment.startsBeforeRange && visibleSegment.endsAfterRange
            ? ', clipped on both sides'
            : visibleSegment.startsBeforeRange
                ? ', starts before visible range'
                : visibleSegment.endsAfterRange
                    ? ', continues after visible range'
                    : '';
    return '${task.title}, $progressText$rangeHint';
  }
}

const _milestoneLabelHeight = 24.0;

class _KyGanttMilestoneLabelPlacement {
  const _KyGanttMilestoneLabelPlacement({
    required this.left,
    required this.width,
  });

  final double left;
  final double width;
}

class _KyGanttMilestoneLabel extends StatelessWidget {
  const _KyGanttMilestoneLabel({
    required super.key,
    required this.task,
    required this.selected,
    required this.showTitle,
    required this.showDate,
  });

  final GanttTask task;
  final bool selected;
  final bool showTitle;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = selected
        ? colorScheme.primaryContainer.withValues(alpha: 0.94)
        : colorScheme.surface.withValues(alpha: 0.92);
    final foregroundColor = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final borderColor = selected
        ? colorScheme.primary.withValues(alpha: 0.36)
        : colorScheme.outlineVariant.withValues(alpha: 0.54);
    final title = Text(
      task.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
    );
    final dateToken = _KyGanttMilestoneDateToken(
      key: ValueKey('ky-gantt-milestone-date-label-${task.id}'),
      task: task,
      selected: selected,
    );

    return IgnorePointer(
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: showTitle && showDate
                ? Row(
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: 6),
                      dateToken,
                    ],
                  )
                : showDate
                    ? Center(child: dateToken)
                    : title,
          ),
        ),
      ),
    );
  }
}

class _KyGanttMilestoneDateToken extends StatelessWidget {
  const _KyGanttMilestoneDateToken({
    required super.key,
    required this.task,
    required this.selected,
  });

  final GanttTask task;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = selected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final backgroundColor = selected
        ? colorScheme.primary.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.82);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        child: Text(
          DateFormat.MMMd().format(DateUtils.dateOnly(task.startDate)),
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w900,
                fontSize: 9,
              ),
        ),
      ),
    );
  }
}

class _KyGanttDraggablePositionedTaskBar extends StatefulWidget {
  const _KyGanttDraggablePositionedTaskBar({
    required this.task,
    required this.selected,
    required this.dependencyFocused,
    required this.dependencyConflicted,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.dayWidth,
    required this.timelineWidth,
    required this.displayOptions,
    required this.interactionOptions,
    required this.avatars,
    required this.today,
    required this.taskDragPreviewBuilder,
    required this.taskDateRangeValidator,
    required this.onTaskDateRangeChangeRejected,
    required this.startsBeforeRange,
    required this.endsAfterRange,
    required this.semanticLabel,
    required this.onTap,
    required this.onTaskDateRangeChanged,
  });

  final GanttTask task;
  final bool selected;
  final bool dependencyFocused;
  final bool dependencyConflicted;
  final double left;
  final double top;
  final double width;
  final double height;
  final double dayWidth;
  final double timelineWidth;
  final KyGanttChartDisplayOptions displayOptions;
  final KyGanttChartInteractionOptions interactionOptions;
  final List<KyGanttTaskAvatar> avatars;
  final DateTime? today;
  final KyGanttTaskDragPreviewBuilder? taskDragPreviewBuilder;
  final KyGanttTaskDateRangeValidator? taskDateRangeValidator;
  final KyGanttTaskDateRangeChangeRejected? onTaskDateRangeChangeRejected;
  final bool startsBeforeRange;
  final bool endsAfterRange;
  final String semanticLabel;
  final VoidCallback? onTap;
  final KyGanttTaskDateRangeChanged? onTaskDateRangeChanged;

  @override
  State<_KyGanttDraggablePositionedTaskBar> createState() =>
      _KyGanttDraggablePositionedTaskBarState();
}

class _KyGanttDraggablePositionedTaskBarState
    extends State<_KyGanttDraggablePositionedTaskBar> {
  var _interactionOffsetX = 0.0;
  var _interactionMode = _KyGanttTaskBarInteractionMode.none;
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final interactionPreview = _interactionPreview;
    final dragPreview = _dragPreview;
    final feedbackOptions =
        widget.interactionOptions.taskBarInteractionFeedback;
    final placeGuideChromeBelow =
        dragPreview != null ? widget.top >= 44 : widget.top < 44;
    final visualLeftOffset = _visualLeftOffset;
    final visualWidth = _visualWidth;
    final selected = widget.selected || interactionPreview != null;
    final interactionSeverity = interactionPreview?.validation.severity;
    final interactionColor = interactionPreview == null
        ? widget.task.color
        : _interactionFeedbackColor(
            colorScheme,
            interactionSeverity,
            widget.task.color,
          );
    final liftActive = interactionPreview != null &&
        widget.interactionOptions.showTaskBarInteractionLift;
    final ghostActive = interactionPreview != null &&
        widget.interactionOptions.showTaskBarInteractionGhost;
    final hoverFocusRingActive = _showHoverFocusRing;

    return Positioned(
      left: widget.left,
      top: widget.top,
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (interactionPreview != null &&
              widget.interactionOptions.showTaskBarDropTarget)
            Positioned(
              key: ValueKey(
                'ky-gantt-task-drop-target-slot-${widget.task.id}',
              ),
              left: -widget.left,
              top: -8,
              width: widget.timelineWidth,
              height: widget.height + 16,
              child: _KyGanttTaskDropTargetLane(
                taskId: widget.task.id,
                targetLeft: widget.left + visualLeftOffset,
                targetWidth: visualWidth,
                color: interactionColor,
                severity: interactionPreview.validation.severity,
                showBlockedPattern:
                    widget.interactionOptions.showTaskBarBlockedDropPattern,
                feedbackOptions: feedbackOptions,
              ),
            ),
          Positioned.fill(
            key: ValueKey(
                'ky-gantt-task-interaction-ghost-slot-${widget.task.id}'),
            child: ghostActive
                ? _KyGanttTaskInteractionGhost(
                    key: ValueKey(
                      'ky-gantt-task-interaction-ghost-${widget.task.id}',
                    ),
                    color: widget.task.color,
                    feedbackOptions: feedbackOptions,
                  )
                : const SizedBox.shrink(),
          ),
          Positioned(
            key: ValueKey('ky-gantt-task-visual-slot-${widget.task.id}'),
            left: 0,
            top: 0,
            width: visualWidth,
            height: widget.height,
            child: Transform.translate(
              offset: Offset(visualLeftOffset, 0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: liftActive
                        ? _KyGanttTaskInteractionLiftShadow(
                            key: ValueKey(
                              'ky-gantt-task-interaction-lift-${widget.task.id}',
                            ),
                            color: interactionColor,
                            feedbackOptions: feedbackOptions,
                          )
                        : const SizedBox.shrink(),
                  ),
                  Positioned.fill(
                    child: _buildGestureWrapper(
                      KyGanttTaskBar(
                        key: ValueKey('ky-gantt-task-bar-${widget.task.id}'),
                        task: widget.task,
                        selected: selected,
                        dependencyFocused: widget.dependencyFocused,
                        dependencyConflicted: widget.dependencyConflicted,
                        displayOptions: widget.displayOptions,
                        avatars: widget.avatars,
                        today: widget.today,
                        startsBeforeRange: widget.startsBeforeRange,
                        endsAfterRange: widget.endsAfterRange,
                        semanticLabel: widget.semanticLabel,
                        onTap: widget.onTap,
                      ),
                    ),
                  ),
                  if (hoverFocusRingActive)
                    Positioned.fill(
                      child: _KyGanttTaskHoverFocusRing(
                        key: ValueKey(
                          'ky-gantt-task-hover-focus-ring-${widget.task.id}',
                        ),
                        color: colorScheme.primary,
                        feedbackOptions: feedbackOptions,
                      ),
                    ),
                  if (interactionPreview != null)
                    Positioned.fill(
                      child: _KyGanttTaskInteractionOverlay(
                        preview: interactionPreview,
                        mode: _interactionMode,
                        showBlockedPattern: widget
                            .interactionOptions.showTaskBarBlockedDropPattern,
                        feedbackOptions: feedbackOptions,
                      ),
                    ),
                  if (interactionPreview != null &&
                      widget.interactionOptions.showTaskBarDragGuides)
                    Positioned.fill(
                      child: _KyGanttTaskSnapGuideLayer(
                        preview: interactionPreview,
                        mode: _interactionMode,
                        showLabels: widget
                            .interactionOptions.showTaskBarDragGuideLabels,
                        showValidationBadge: widget.interactionOptions
                                .showTaskBarDragValidationBadge &&
                            dragPreview == null,
                        placeLabelsBelow: placeGuideChromeBelow,
                      ),
                    ),
                  if (_showResizeStartHandle)
                    _KyGanttTaskResizeHandle(
                      key: ValueKey(
                        'ky-gantt-task-resize-start-handle-${widget.task.id}',
                      ),
                      alignment: Alignment.centerLeft,
                      width: _resizeHandleWidth,
                      active: _interactionMode ==
                          _KyGanttTaskBarInteractionMode.resizeStart,
                      severity: interactionSeverity,
                      onDragStart: () => _startInteraction(
                        _KyGanttTaskBarInteractionMode.resizeStart,
                      ),
                      onDragUpdate: _updateInteraction,
                      onDragEnd: _commitInteraction,
                      onDragCancel: _resetInteraction,
                    ),
                  if (_showResizeEndHandle)
                    _KyGanttTaskResizeHandle(
                      key: ValueKey(
                        'ky-gantt-task-resize-end-handle-${widget.task.id}',
                      ),
                      alignment: Alignment.centerRight,
                      width: _resizeHandleWidth,
                      active: _interactionMode ==
                          _KyGanttTaskBarInteractionMode.resizeEnd,
                      severity: interactionSeverity,
                      onDragStart: () => _startInteraction(
                        _KyGanttTaskBarInteractionMode.resizeEnd,
                      ),
                      onDragUpdate: _updateInteraction,
                      onDragEnd: _commitInteraction,
                      onDragCancel: _resetInteraction,
                    ),
                  if (_showDragHandle(visualWidth))
                    Positioned(
                      right: _dragHandleRightInset,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _KyGanttTaskDragHandle(
                          key: ValueKey(
                            'ky-gantt-task-drag-handle-${widget.task.id}',
                          ),
                          active: _interactionMode ==
                              _KyGanttTaskBarInteractionMode.move,
                        ),
                      ),
                    ),
                  if (dragPreview != null)
                    Positioned(
                      left: 0,
                      top: widget.top < 44 ? widget.height + 6 : -36,
                      child: widget.taskDragPreviewBuilder
                              ?.call(context, dragPreview) ??
                          _KyGanttTaskDragPreviewPill(preview: dragPreview),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureWrapper(Widget child) {
    final canDrag = _canDragTaskBar;
    final canResize = _canResizeStart || _canResizeEnd;
    final needsFocusedResizeHover = canResize &&
        widget.interactionOptions.resizeHandleVisibility ==
            KyGanttTaskResizeHandleVisibility.focused;
    final needsHover = canDrag ||
        needsFocusedResizeHover ||
        (widget.interactionOptions.showTaskBarHoverFocusRing &&
            (canDrag || canResize));

    if (!needsHover) {
      return child;
    }

    final dragWrappedChild = !canDrag
        ? child
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) =>
                _startInteraction(_KyGanttTaskBarInteractionMode.move),
            onHorizontalDragUpdate: (details) =>
                _updateInteraction(details.delta.dx),
            onHorizontalDragEnd: (_) => _commitInteraction(),
            onHorizontalDragCancel: _resetInteraction,
            child: child,
          );

    return MouseRegion(
      cursor: canDrag
          ? _interactionMode == _KyGanttTaskBarInteractionMode.move
              ? SystemMouseCursors.grabbing
              : SystemMouseCursors.grab
          : MouseCursor.defer,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: dragWrappedChild,
    );
  }

  bool get _canDragTaskBar {
    return widget.interactionOptions.enableTaskBarDrag &&
        widget.onTaskDateRangeChanged != null;
  }

  void _setHovered(bool hovered) {
    if (_hovered == hovered || !mounted) return;

    setState(() => _hovered = hovered);
  }

  void _startInteraction(_KyGanttTaskBarInteractionMode mode) {
    setState(() {
      _interactionMode = mode;
      _interactionOffsetX = 0;
    });
  }

  void _updateInteraction(double deltaX) {
    setState(() {
      _interactionOffsetX += deltaX;
    });
  }

  void _commitInteraction() {
    final preview = _interactionPreview;
    final callback = widget.onTaskDateRangeChanged;
    if (preview != null &&
        (_dateChanged(preview.startDate, widget.task.startDate) ||
            _dateChanged(preview.endDate, widget.task.endDate))) {
      if (preview.validation.canCommit) {
        callback?.call(widget.task, preview.startDate, preview.endDate);
      } else {
        widget.onTaskDateRangeChangeRejected?.call(
          widget.task,
          preview.startDate,
          preview.endDate,
          preview.validation,
        );
      }
    }

    _resetInteraction();
  }

  void _resetInteraction() {
    if (!mounted) return;

    setState(() {
      _interactionMode = _KyGanttTaskBarInteractionMode.none;
      _interactionOffsetX = 0;
    });
  }

  int _snappedDeltaDays(double offsetX) {
    final rawDays = offsetX / widget.dayWidth;
    switch (widget.interactionOptions.dragSnap) {
      case KyGanttTaskDragSnap.day:
        return rawDays.round();
      case KyGanttTaskDragSnap.week:
        return (rawDays / 7).round() * 7;
    }
  }

  KyGanttTaskDragPreview? get _dragPreview {
    if (!widget.interactionOptions.showTaskBarDragPreview) {
      return null;
    }

    return _interactionPreview;
  }

  KyGanttTaskDragPreview? get _interactionPreview {
    if (_interactionMode == _KyGanttTaskBarInteractionMode.none) {
      return null;
    }

    final deltaDays = _snappedDeltaDays(_interactionOffsetX);
    final startDate = DateUtils.dateOnly(widget.task.startDate);
    final endDate = DateUtils.dateOnly(widget.task.endDate);

    switch (_interactionMode) {
      case _KyGanttTaskBarInteractionMode.none:
        return null;
      case _KyGanttTaskBarInteractionMode.move:
        return _validatedPreview(
          KyGanttTaskDragPreview(
            task: widget.task,
            startDate: startDate.add(Duration(days: deltaDays)),
            endDate: endDate.add(Duration(days: deltaDays)),
            deltaDays: deltaDays,
            snap: widget.interactionOptions.dragSnap,
          ),
        );
      case _KyGanttTaskBarInteractionMode.resizeStart:
        final resizedStart = startDate.add(Duration(days: deltaDays));
        return _validatedPreview(
          KyGanttTaskDragPreview(
            task: widget.task,
            startDate: resizedStart.isAfter(endDate) ? endDate : resizedStart,
            endDate: endDate,
            deltaDays: deltaDays,
            action: KyGanttTaskRangePreviewAction.resizeStart,
            snap: widget.interactionOptions.dragSnap,
          ),
        );
      case _KyGanttTaskBarInteractionMode.resizeEnd:
        final resizedEnd = endDate.add(Duration(days: deltaDays));
        return _validatedPreview(
          KyGanttTaskDragPreview(
            task: widget.task,
            startDate: startDate,
            endDate: resizedEnd.isBefore(startDate) ? startDate : resizedEnd,
            deltaDays: deltaDays,
            action: KyGanttTaskRangePreviewAction.resizeEnd,
            snap: widget.interactionOptions.dragSnap,
          ),
        );
    }
  }

  KyGanttTaskDragPreview _validatedPreview(KyGanttTaskDragPreview preview) {
    final validator = widget.taskDateRangeValidator;
    if (validator == null) return preview;

    return preview.copyWith(
      validation: validator(widget.task, preview.startDate, preview.endDate),
    );
  }

  double get _visualLeftOffset {
    switch (_interactionMode) {
      case _KyGanttTaskBarInteractionMode.none:
      case _KyGanttTaskBarInteractionMode.resizeEnd:
        return 0;
      case _KyGanttTaskBarInteractionMode.move:
        return _snappedDeltaDays(_interactionOffsetX) * widget.dayWidth;
      case _KyGanttTaskBarInteractionMode.resizeStart:
        final preview = _interactionPreview;
        if (preview == null) return 0;
        final originalStart = DateUtils.dateOnly(widget.task.startDate);
        return preview.startDate.difference(originalStart).inDays *
            widget.dayWidth;
    }
  }

  double get _visualWidth {
    final preview = _interactionPreview;
    if (preview == null ||
        _interactionMode == _KyGanttTaskBarInteractionMode.move) {
      return widget.width;
    }

    return ((preview.endDate.difference(preview.startDate).inDays + 1) *
            widget.dayWidth)
        .clamp(widget.dayWidth, double.infinity)
        .toDouble();
  }

  bool get _canResizeStart {
    return widget.interactionOptions.enableTaskBarResize &&
        widget.onTaskDateRangeChanged != null &&
        !widget.startsBeforeRange;
  }

  bool get _canResizeEnd {
    return widget.interactionOptions.enableTaskBarResize &&
        widget.onTaskDateRangeChanged != null &&
        !widget.endsAfterRange;
  }

  bool get _showResizeStartHandle {
    return _canResizeStart && _showResizeHandles;
  }

  bool get _showResizeEndHandle {
    return _canResizeEnd && _showResizeHandles;
  }

  bool get _showResizeHandles {
    switch (widget.interactionOptions.resizeHandleVisibility) {
      case KyGanttTaskResizeHandleVisibility.always:
        return true;
      case KyGanttTaskResizeHandleVisibility.focused:
        return widget.selected ||
            _hovered ||
            _interactionMode != _KyGanttTaskBarInteractionMode.none;
    }
  }

  double get _resizeHandleWidth {
    return widget.interactionOptions.taskBarResizeHandleWidth
        .clamp(8, 24)
        .toDouble();
  }

  bool _showDragHandle(double visualWidth) {
    return widget.interactionOptions.showTaskBarDragHandle &&
        _canDragTaskBar &&
        visualWidth >= 96 &&
        (widget.selected ||
            _hovered ||
            _interactionMode == _KyGanttTaskBarInteractionMode.move);
  }

  bool get _showHoverFocusRing {
    return widget.interactionOptions.showTaskBarHoverFocusRing &&
        _hovered &&
        (_canDragTaskBar || _canResizeStart || _canResizeEnd) &&
        _interactionMode == _KyGanttTaskBarInteractionMode.none;
  }

  double get _dragHandleRightInset {
    return _showResizeEndHandle ? _resizeHandleWidth + 3 : 8;
  }

  bool _dateChanged(DateTime left, DateTime right) {
    return DateUtils.dateOnly(left) != DateUtils.dateOnly(right);
  }

  Color _interactionFeedbackColor(
    ColorScheme colorScheme,
    KyGanttTaskDateRangeValidationSeverity? severity,
    Color fallback,
  ) {
    switch (severity) {
      case KyGanttTaskDateRangeValidationSeverity.valid:
        return colorScheme.primary;
      case KyGanttTaskDateRangeValidationSeverity.warning:
        return colorScheme.tertiary;
      case KyGanttTaskDateRangeValidationSeverity.error:
        return colorScheme.error;
      case null:
        return fallback;
    }
  }
}

enum _KyGanttTaskBarInteractionMode { none, move, resizeStart, resizeEnd }

double _scaledFeedbackAlpha(
  double alpha,
  KyGanttTaskBarInteractionFeedbackOptions options,
) {
  return (alpha * options.opacityScale.clamp(0, 3)).clamp(0, 1).toDouble();
}

double _scaledFeedbackBlur(
  double blur,
  KyGanttTaskBarInteractionFeedbackOptions options,
) {
  return blur * options.blurScale.clamp(0, 3).toDouble();
}

double _scaledFeedbackOffset(
  double offset,
  KyGanttTaskBarInteractionFeedbackOptions options,
) {
  return offset * options.offsetScale.clamp(0, 3).toDouble();
}

class _KyGanttTaskInteractionLiftShadow extends StatelessWidget {
  const _KyGanttTaskInteractionLiftShadow({
    required super.key,
    required this.color,
    required this.feedbackOptions,
  });

  final Color color;
  final KyGanttTaskBarInteractionFeedbackOptions feedbackOptions;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(
                alpha: _scaledFeedbackAlpha(0.24, feedbackOptions),
              ),
              blurRadius: _scaledFeedbackBlur(24, feedbackOptions),
              spreadRadius: 2,
              offset: Offset(
                0,
                _scaledFeedbackOffset(10, feedbackOptions),
              ),
            ),
            BoxShadow(
              color: color.withValues(
                alpha: _scaledFeedbackAlpha(0.12, feedbackOptions),
              ),
              blurRadius: _scaledFeedbackBlur(10, feedbackOptions),
              offset: Offset(
                0,
                _scaledFeedbackOffset(3, feedbackOptions),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KyGanttTaskInteractionGhost extends StatelessWidget {
  const _KyGanttTaskInteractionGhost({
    required super.key,
    required this.color,
    required this.feedbackOptions,
  });

  final Color color;
  final KyGanttTaskBarInteractionFeedbackOptions feedbackOptions;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: _scaledFeedbackAlpha(0.08, feedbackOptions),
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(
                alpha: _scaledFeedbackAlpha(0.30, feedbackOptions),
              ),
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _KyGanttTaskDropTargetLane extends StatelessWidget {
  const _KyGanttTaskDropTargetLane({
    required this.taskId,
    required this.targetLeft,
    required this.targetWidth,
    required this.color,
    required this.severity,
    required this.showBlockedPattern,
    required this.feedbackOptions,
  });

  final String taskId;
  final double targetLeft;
  final double targetWidth;
  final Color color;
  final KyGanttTaskDateRangeValidationSeverity severity;
  final bool showBlockedPattern;
  final KyGanttTaskBarInteractionFeedbackOptions feedbackOptions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final blocking = severity == KyGanttTaskDateRangeValidationSeverity.error;
    final warning = severity == KyGanttTaskDateRangeValidationSeverity.warning;

    return IgnorePointer(
      key: ValueKey('ky-gantt-task-drop-target-lane-$taskId'),
      child: ExcludeSemantics(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: targetLeft,
              top: 0,
              bottom: 0,
              width: targetWidth,
              child: AnimatedContainer(
                key: ValueKey('ky-gantt-task-drop-target-band-$taskId'),
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: color.withValues(
                      alpha: _scaledFeedbackAlpha(
                        blocking ? 0.52 : 0.36,
                        feedbackOptions,
                      ),
                    ),
                    width: blocking ? 1.8 : 1.2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(
                        alpha: _scaledFeedbackAlpha(
                          blocking ? 0.18 : 0.12,
                          feedbackOptions,
                        ),
                      ),
                      color.withValues(
                        alpha: _scaledFeedbackAlpha(
                          warning ? 0.12 : 0.06,
                          feedbackOptions,
                        ),
                      ),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(
                        alpha: _scaledFeedbackAlpha(
                          blocking ? 0.18 : 0.12,
                          feedbackOptions,
                        ),
                      ),
                      blurRadius: _scaledFeedbackBlur(
                        blocking ? 18 : 14,
                        feedbackOptions,
                      ),
                      offset: Offset(
                        0,
                        _scaledFeedbackOffset(6, feedbackOptions),
                      ),
                    ),
                    BoxShadow(
                      color: colorScheme.shadow.withValues(
                        alpha: _scaledFeedbackAlpha(0.08, feedbackOptions),
                      ),
                      blurRadius: _scaledFeedbackBlur(10, feedbackOptions),
                      offset: Offset(
                        0,
                        _scaledFeedbackOffset(4, feedbackOptions),
                      ),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (blocking && showBlockedPattern)
                        _KyGanttTaskBlockedDropPattern(
                          key: ValueKey(
                            'ky-gantt-task-drop-target-blocked-pattern-$taskId',
                          ),
                          color: color,
                          feedbackOptions: feedbackOptions,
                        ),
                      _KyGanttTaskDropTargetEdge(
                        alignment: Alignment.centerLeft,
                        color: color,
                        active: true,
                      ),
                      _KyGanttTaskDropTargetEdge(
                        alignment: Alignment.centerRight,
                        color: color,
                        active: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KyGanttTaskDropTargetEdge extends StatelessWidget {
  const _KyGanttTaskDropTargetEdge({
    required this.alignment,
    required this.color,
    required this.active,
  });

  final Alignment alignment;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: active ? 0.76 : 0.40),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: active ? 0.24 : 0.12),
              blurRadius: active ? 10 : 6,
            ),
          ],
        ),
        child: SizedBox(width: active ? 3 : 2, height: double.infinity),
      ),
    );
  }
}

class _KyGanttTaskHoverFocusRing extends StatelessWidget {
  const _KyGanttTaskHoverFocusRing({
    required super.key,
    required this.color,
    required this.feedbackOptions,
  });

  final Color color;
  final KyGanttTaskBarInteractionFeedbackOptions feedbackOptions;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(
              alpha: _scaledFeedbackAlpha(0.54, feedbackOptions),
            ),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(
                alpha: _scaledFeedbackAlpha(0.14, feedbackOptions),
              ),
              blurRadius: _scaledFeedbackBlur(16, feedbackOptions),
              spreadRadius: 1,
              offset: Offset(0, _scaledFeedbackOffset(2, feedbackOptions)),
            ),
          ],
        ),
      ),
    );
  }
}

class _KyGanttTaskSnapGuideLayer extends StatelessWidget {
  const _KyGanttTaskSnapGuideLayer({
    required this.preview,
    required this.mode,
    required this.showLabels,
    required this.showValidationBadge,
    required this.placeLabelsBelow,
  });

  final KyGanttTaskDragPreview preview;
  final _KyGanttTaskBarInteractionMode mode;
  final bool showLabels;
  final bool showValidationBadge;
  final bool placeLabelsBelow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _feedbackColor(colorScheme);
    final formatter = DateFormat.MMMd();
    final startLabel = formatter.format(preview.startDate);
    final endLabel = formatter.format(preview.endDate);
    final validationMessage = _validationMessage;
    final showValidationMessage =
        showValidationBadge && validationMessage != null;
    final validationOffset = showLabels
        ? _snapGuideValidationOffsetWithDateLabels
        : _snapGuideLabelOffset;

    return IgnorePointer(
      key: ValueKey('ky-gantt-task-snap-guides-${preview.task.id}'),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: -10,
            bottom: -10,
            child: _KyGanttTaskSnapGuideLine(
              key:
                  ValueKey('ky-gantt-task-snap-guide-start-${preview.task.id}'),
              color: color,
              active: mode != _KyGanttTaskBarInteractionMode.resizeEnd,
            ),
          ),
          Positioned(
            right: 0,
            top: -10,
            bottom: -10,
            child: _KyGanttTaskSnapGuideLine(
              key: ValueKey('ky-gantt-task-snap-guide-end-${preview.task.id}'),
              color: color,
              active: mode != _KyGanttTaskBarInteractionMode.resizeStart,
            ),
          ),
          if (showLabels)
            Positioned(
              left: 0,
              right: 0,
              top: placeLabelsBelow ? null : -_snapGuideLabelOffset,
              bottom: placeLabelsBelow ? -_snapGuideLabelOffset : null,
              height: _snapGuideLabelHeight,
              child: _KyGanttTaskSnapGuideDateLabels(
                taskId: preview.task.id,
                startLabel: startLabel,
                endLabel: endLabel,
                color: color,
                startActive: mode != _KyGanttTaskBarInteractionMode.resizeEnd,
                endActive: mode != _KyGanttTaskBarInteractionMode.resizeStart,
              ),
            ),
          if (showValidationMessage)
            Positioned(
              left: 0,
              right: 0,
              top: placeLabelsBelow ? null : -validationOffset,
              bottom: placeLabelsBelow ? -validationOffset : null,
              height: _snapGuideValidationBadgeHeight,
              child: _KyGanttTaskSnapGuideValidationBadge(
                key: ValueKey(
                  'ky-gantt-task-snap-guide-validation-${preview.task.id}',
                ),
                message: validationMessage,
                color: color,
              ),
            ),
        ],
      ),
    );
  }

  String? get _validationMessage {
    if (preview.validation.isValid) return null;

    final message = preview.validation.message?.trim();
    if (message == null || message.isEmpty) return null;

    return message;
  }

  Color _feedbackColor(ColorScheme colorScheme) {
    switch (preview.validation.severity) {
      case KyGanttTaskDateRangeValidationSeverity.valid:
        return colorScheme.primary;
      case KyGanttTaskDateRangeValidationSeverity.warning:
        return colorScheme.tertiary;
      case KyGanttTaskDateRangeValidationSeverity.error:
        return colorScheme.error;
    }
  }
}

const _snapGuideLabelHeight = 24.0;
const _snapGuideLabelOffset = 32.0;
const _snapGuideLabelGap = 6.0;
const _snapGuideValidationBadgeHeight = 26.0;
const _snapGuideValidationOffsetWithDateLabels =
    _snapGuideLabelOffset + _snapGuideLabelHeight + _snapGuideLabelGap;

class _KyGanttTaskSnapGuideDateLabels extends StatelessWidget {
  const _KyGanttTaskSnapGuideDateLabels({
    required this.taskId,
    required this.startLabel,
    required this.endLabel,
    required this.color,
    required this.startActive,
    required this.endActive,
  });

  final String taskId;
  final String startLabel;
  final String endLabel;
  final Color color;
  final bool startActive;
  final bool endActive;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 168) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _KyGanttTaskSnapGuideDateChip(
                key: ValueKey('ky-gantt-task-snap-guide-start-label-$taskId'),
                label: startLabel,
                color: color,
                active: startActive,
              ),
              _KyGanttTaskSnapGuideDateChip(
                key: ValueKey('ky-gantt-task-snap-guide-end-label-$taskId'),
                label: endLabel,
                color: color,
                active: endActive,
              ),
            ],
          );
        }

        if (constraints.maxWidth < 96) return const SizedBox.shrink();

        return OverflowBox(
          maxWidth: 176,
          child: _KyGanttTaskSnapGuideDateChip(
            key: ValueKey('ky-gantt-task-snap-guide-range-label-$taskId'),
            label: '$startLabel - $endLabel',
            color: color,
            active: startActive || endActive,
          ),
        );
      },
    );
  }
}

class _KyGanttTaskSnapGuideDateChip extends StatelessWidget {
  const _KyGanttTaskSnapGuideDateChip({
    required super.key,
    required this.label,
    required this.color,
    required this.active,
  });

  final String label;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = colorScheme.surface.withValues(alpha: 0.94);
    final foregroundColor = active ? color : colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: color.withValues(alpha: active ? 0.38 : 0.20)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _KyGanttTaskSnapGuideValidationBadge extends StatelessWidget {
  const _KyGanttTaskSnapGuideValidationBadge({
    required super.key,
    required this.message,
    required this.color,
  });

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.42)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KyGanttTaskSnapGuideLine extends StatelessWidget {
  const _KyGanttTaskSnapGuideLine({
    required super.key,
    required this.color,
    required this.active,
  });

  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 0.86 : 0.46),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: active ? 0.28 : 0.16),
            blurRadius: active ? 12 : 8,
            spreadRadius: active ? 1 : 0,
          ),
        ],
      ),
      child: SizedBox(width: active ? 3 : 2),
    );
  }
}

class _KyGanttTaskInteractionOverlay extends StatelessWidget {
  const _KyGanttTaskInteractionOverlay({
    required this.preview,
    required this.mode,
    required this.showBlockedPattern,
    required this.feedbackOptions,
  });

  final KyGanttTaskDragPreview preview;
  final _KyGanttTaskBarInteractionMode mode;
  final bool showBlockedPattern;
  final KyGanttTaskBarInteractionFeedbackOptions feedbackOptions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _feedbackColor(colorScheme);
    final blocking = preview.validation.isBlocking;

    return IgnorePointer(
      key: ValueKey('ky-gantt-task-interaction-overlay-${preview.task.id}'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(
              alpha: _scaledFeedbackAlpha(
                blocking ? 0.88 : 0.72,
                feedbackOptions,
              ),
            ),
            width: blocking ? 2.2 : 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(
                alpha: _scaledFeedbackAlpha(
                  blocking ? 0.20 : 0.16,
                  feedbackOptions,
                ),
              ),
              blurRadius: _scaledFeedbackBlur(
                blocking ? 18 : 14,
                feedbackOptions,
              ),
              spreadRadius: 1,
              offset: Offset(0, _scaledFeedbackOffset(6, feedbackOptions)),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      color.withValues(
                        alpha: _scaledFeedbackAlpha(
                          blocking ? 0.20 : 0.12,
                          feedbackOptions,
                        ),
                      ),
                      color.withValues(
                        alpha: _scaledFeedbackAlpha(
                          blocking ? 0.08 : 0.04,
                          feedbackOptions,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (blocking && showBlockedPattern)
                _KyGanttTaskBlockedDropPattern(
                  key: ValueKey(
                    'ky-gantt-task-interaction-blocked-pattern-${preview.task.id}',
                  ),
                  color: color,
                  feedbackOptions: feedbackOptions,
                ),
              if (mode == _KyGanttTaskBarInteractionMode.resizeStart)
                _KyGanttResizeEdgeGlow(
                  alignment: Alignment.centerLeft,
                  color: color,
                ),
              if (mode == _KyGanttTaskBarInteractionMode.resizeEnd)
                _KyGanttResizeEdgeGlow(
                  alignment: Alignment.centerRight,
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _feedbackColor(ColorScheme colorScheme) {
    switch (preview.validation.severity) {
      case KyGanttTaskDateRangeValidationSeverity.valid:
        return colorScheme.primary;
      case KyGanttTaskDateRangeValidationSeverity.warning:
        return colorScheme.tertiary;
      case KyGanttTaskDateRangeValidationSeverity.error:
        return colorScheme.error;
    }
  }
}

class _KyGanttTaskBlockedDropPattern extends StatelessWidget {
  const _KyGanttTaskBlockedDropPattern({
    required super.key,
    required this.color,
    required this.feedbackOptions,
  });

  final Color color;
  final KyGanttTaskBarInteractionFeedbackOptions feedbackOptions;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: _KyGanttTaskBlockedDropPatternPainter(
            color: color.withValues(
              alpha: _scaledFeedbackAlpha(0.24, feedbackOptions),
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _KyGanttTaskBlockedDropPatternPainter extends CustomPainter {
  const _KyGanttTaskBlockedDropPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const spacing = 9.0;

    for (var x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_KyGanttTaskBlockedDropPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _KyGanttResizeEdgeGlow extends StatelessWidget {
  const _KyGanttResizeEdgeGlow({
    required this.alignment,
    required this.color,
  });

  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const SizedBox(width: 4, height: double.infinity),
      ),
    );
  }
}

class _KyGanttTaskResizeHandle extends StatelessWidget {
  const _KyGanttTaskResizeHandle({
    required super.key,
    required this.alignment,
    required this.width,
    required this.active,
    required this.severity,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final Alignment alignment;
  final double width;
  final bool active;
  final KyGanttTaskDateRangeValidationSeverity? severity;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onDragCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isStartHandle = alignment.x < 0;
    final feedbackColor = _feedbackColor(colorScheme);

    return Positioned(
      left: isStartHandle ? 0 : null,
      right: isStartHandle ? null : 0,
      top: 0,
      bottom: 0,
      width: width,
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) => onDragStart(),
          onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
          onHorizontalDragEnd: (_) => onDragEnd(),
          onHorizontalDragCancel: onDragCancel,
          child: SizedBox(
            width: width,
            height: double.infinity,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: active
                      ? feedbackColor.withValues(alpha: 0.20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: active ? 3 : 0,
                  vertical: 3,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: active
                        ? feedbackColor
                        : colorScheme.onSurface.withValues(alpha: 0.46),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: SizedBox(width: active ? 3 : 2, height: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _feedbackColor(ColorScheme colorScheme) {
    switch (severity) {
      case KyGanttTaskDateRangeValidationSeverity.valid:
        return colorScheme.primary;
      case KyGanttTaskDateRangeValidationSeverity.warning:
        return colorScheme.tertiary;
      case KyGanttTaskDateRangeValidationSeverity.error:
        return colorScheme.error;
      case null:
        return colorScheme.primary;
    }
  }
}

class _KyGanttTaskDragHandle extends StatelessWidget {
  const _KyGanttTaskDragHandle({
    required super.key,
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = active
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.68);

    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: active ? 0.92 : 0.78),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? colorScheme.primary.withValues(alpha: 0.36)
                : colorScheme.outlineVariant.withValues(alpha: 0.42),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: active ? 0.16 : 0.10),
              blurRadius: active ? 10 : 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.drag_indicator_rounded,
          size: 15,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class _KyGanttTaskDragPreviewPill extends StatelessWidget {
  const _KyGanttTaskDragPreviewPill({required this.preview});

  final KyGanttTaskDragPreview preview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = DateFormat.MMMd();
    final dateRange =
        '${formatter.format(preview.startDate)} - ${formatter.format(preview.endDate)}';
    final metadata =
        '$dateRange - ${preview.durationLabel} - ${preview.snapLabel}';
    final validationMessage = preview.validation.message;
    final pillColor = _backgroundColor(colorScheme);
    final foregroundColor = _foregroundColor(colorScheme);

    return Material(
      key: ValueKey('ky-gantt-task-drag-preview-${preview.task.id}'),
      color: Colors.transparent,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        scale: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icon,
                  size: 15,
                  color: foregroundColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${preview.actionLabel} ${preview.deltaLabel}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Container(
                  width: 1,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  color: foregroundColor.withValues(alpha: 0.26),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Text(
                    metadata,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (validationMessage != null &&
                    validationMessage.isNotEmpty) ...[
                  Container(
                    width: 1,
                    height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 7),
                    color: foregroundColor.withValues(alpha: 0.26),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      validationMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: foregroundColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    switch (preview.validation.severity) {
      case KyGanttTaskDateRangeValidationSeverity.valid:
        return Icons.swap_horiz_rounded;
      case KyGanttTaskDateRangeValidationSeverity.warning:
        return Icons.warning_amber_rounded;
      case KyGanttTaskDateRangeValidationSeverity.error:
        return Icons.block_rounded;
    }
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    switch (preview.validation.severity) {
      case KyGanttTaskDateRangeValidationSeverity.valid:
        return colorScheme.inverseSurface.withValues(alpha: 0.94);
      case KyGanttTaskDateRangeValidationSeverity.warning:
        return colorScheme.tertiaryContainer.withValues(alpha: 0.96);
      case KyGanttTaskDateRangeValidationSeverity.error:
        return colorScheme.errorContainer.withValues(alpha: 0.98);
    }
  }

  Color _foregroundColor(ColorScheme colorScheme) {
    switch (preview.validation.severity) {
      case KyGanttTaskDateRangeValidationSeverity.valid:
        return colorScheme.onInverseSurface;
      case KyGanttTaskDateRangeValidationSeverity.warning:
        return colorScheme.onTertiaryContainer;
      case KyGanttTaskDateRangeValidationSeverity.error:
        return colorScheme.onErrorContainer;
    }
  }
}
