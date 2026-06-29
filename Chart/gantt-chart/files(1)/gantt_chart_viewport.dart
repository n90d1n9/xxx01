import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';
import 'gantt_header.dart';
import 'gantt_grid_painter.dart';
import 'task_bar_widget.dart';
import 'dependency_arrow_painter.dart';

class GanttChartViewport extends ConsumerStatefulWidget {
  const GanttChartViewport({super.key});

  @override
  ConsumerState<GanttChartViewport> createState() => _GanttChartViewportState();
}

class _GanttChartViewportState extends ConsumerState<GanttChartViewport> {
  final _hScrollCtrl = ScrollController();
  final _vScrollCtrl = ScrollController();
  final _headerScrollCtrl = ScrollController();
  final _sidebarScrollCtrl = ScrollController();

  bool _syncingHScroll = false;
  bool _syncingVScroll = false;

  @override
  void initState() {
    super.initState();
    _hScrollCtrl.addListener(_syncHeaderFromBody);
    _headerScrollCtrl.addListener(_syncBodyFromHeader);
    _vScrollCtrl.addListener(_syncSidebarFromBody);
    _sidebarScrollCtrl.addListener(_syncBodyFromSidebar);
  }

  void _syncHeaderFromBody() {
    if (_syncingHScroll) return;
    _syncingHScroll = true;
    _headerScrollCtrl.jumpTo(_hScrollCtrl.offset);
    _syncingHScroll = false;
  }

  void _syncBodyFromHeader() {
    if (_syncingHScroll) return;
    _syncingHScroll = true;
    _hScrollCtrl.jumpTo(_headerScrollCtrl.offset);
    _syncingHScroll = false;
  }

  void _syncSidebarFromBody() {
    if (_syncingVScroll) return;
    _syncingVScroll = true;
    _sidebarScrollCtrl.jumpTo(_vScrollCtrl.offset);
    _syncingVScroll = false;
  }

  void _syncBodyFromSidebar() {
    if (_syncingVScroll) return;
    _syncingVScroll = true;
    _vScrollCtrl.jumpTo(_sidebarScrollCtrl.offset);
    _syncingVScroll = false;
  }

  @override
  void dispose() {
    _hScrollCtrl.dispose();
    _vScrollCtrl.dispose();
    _headerScrollCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(viewSettingsProvider);
    final visibleTasks = ref.watch(visibleTasksProvider);
    final (projectStart, projectEnd) = ref.watch(projectDateRangeProvider);
    final criticalIds = ref.watch(criticalPathIdsProvider);
    final isSidebarCollapsed = ref.watch(sidebarCollapsedProvider);

    final sidebarWidth = isSidebarCollapsed ? 0.0 : settings.sidebarWidth;
    final headerHeight = settings.headerHeight + settings.subHeaderHeight;
    final totalRows = visibleTasks.length;
    final totalHeight = totalRows * settings.rowHeight;
    final totalDays = GanttDateUtils.daysBetween(projectStart, projectEnd) + 1;
    final totalWidth = totalDays * settings.dayWidth;

    return Column(
      children: [
        // ── Header Row ──────────────────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Corner cell
            AnimatedContainer(
              duration: GanttAnimations.normal,
              width: sidebarWidth,
              height: headerHeight,
              decoration: const BoxDecoration(
                color: GanttTheme.surface1,
                border: Border(
                  right: BorderSide(color: GanttTheme.surface4),
                  bottom: BorderSide(color: GanttTheme.surface4),
                ),
              ),
              child: isSidebarCollapsed
                  ? null
                  : Center(
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left, size: 16),
                        onPressed: () => ref
                            .read(sidebarCollapsedProvider.notifier)
                            .state = true,
                        color: GanttTheme.textMuted,
                        tooltip: 'Collapse sidebar',
                      ),
                    ),
            ),
            // Gantt header
            Expanded(
              child: GanttHeader(
                startDate: projectStart,
                endDate: projectEnd,
                dayWidth: settings.dayWidth,
                settings: settings,
                scrollController: _headerScrollCtrl,
              ),
            ),
          ],
        ),

        // ── Body Row ────────────────────────────────────────────────────────
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar
              AnimatedContainer(
                duration: GanttAnimations.normal,
                width: sidebarWidth,
                child: isSidebarCollapsed
                    ? _CollapsedSidebarHandle(
                        onExpand: () => ref
                            .read(sidebarCollapsedProvider.notifier)
                            .state = false,
                      )
                    : _SidebarScrollSync(
                        tasks: visibleTasks,
                        rowHeight: settings.rowHeight,
                        scrollController: _sidebarScrollCtrl,
                        bodyScrollController: _vScrollCtrl,
                      ),
              ),

              // Chart area
              Expanded(
                child: Listener(
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      // Horizontal scroll with shift or horizontal scroll
                      if (event.scrollDelta.dx != 0) {
                        final newOffset = (_hScrollCtrl.offset +
                                event.scrollDelta.dx)
                            .clamp(0.0, _hScrollCtrl.position.maxScrollExtent);
                        _hScrollCtrl.jumpTo(newOffset);
                      } else {
                        final newOffset = (_vScrollCtrl.offset +
                                event.scrollDelta.dy)
                            .clamp(0.0, _vScrollCtrl.position.maxScrollExtent);
                        _vScrollCtrl.jumpTo(newOffset);
                      }
                    }
                  },
                  child: SingleChildScrollView(
                    controller: _vScrollCtrl,
                    physics: const ClampingScrollPhysics(),
                    child: SingleChildScrollView(
                      controller: _hScrollCtrl,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: totalWidth,
                        height: totalHeight,
                        child: Stack(
                          children: [
                            // Grid background
                            CustomPaint(
                              size: Size(totalWidth, totalHeight),
                              painter: GanttGridPainter(
                                startDate: projectStart,
                                endDate: projectEnd,
                                dayWidth: settings.dayWidth,
                                rowHeight: settings.rowHeight,
                                rowCount: totalRows,
                                showWeekends: settings.showWeekends,
                                showToday: settings.showToday,
                                today: DateTime.now(),
                              ),
                            ),

                            // Row hover highlights
                            ...visibleTasks.asMap().entries.map((e) {
                              return _RowHighlight(
                                task: e.value,
                                rowIndex: e.key,
                                rowHeight: settings.rowHeight,
                                totalWidth: totalWidth,
                              );
                            }),

                            // Dependency arrows (behind bars)
                            if (settings.showDependencies)
                              _DependencyLayer(
                                tasks: visibleTasks,
                                ganttStart: projectStart,
                                dayWidth: settings.dayWidth,
                                rowHeight: settings.rowHeight,
                                criticalIds: criticalIds,
                              ),

                            // Task bars
                            ...visibleTasks.asMap().entries.map((e) {
                              return TaskBarWidget(
                                key: ValueKey(e.value.id),
                                task: e.value,
                                ganttStart: projectStart,
                                dayWidth: settings.dayWidth,
                                rowHeight: settings.rowHeight,
                                rowIndex: e.key,
                                isCritical: criticalIds.contains(e.value.id),
                                onTap: () {
                                  ref
                                      .read(selectedTaskIdProvider.notifier)
                                      .state = e.value.id;
                                },
                              );
                            }),

                            // Today marker on top
                            if (settings.showToday)
                              _TodayMarker(
                                ganttStart: projectStart,
                                dayWidth: settings.dayWidth,
                                totalHeight: totalHeight,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sidebar scroll sync wrapper ───────────────────────────────────────────────

class _SidebarScrollSync extends ConsumerWidget {
  final List<Task> tasks;
  final double rowHeight;
  final ScrollController scrollController;
  final ScrollController bodyScrollController;

  const _SidebarScrollSync({
    required this.tasks,
    required this.rowHeight,
    required this.scrollController,
    required this.bodyScrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(viewSettingsProvider);
    final selectedId = ref.watch(selectedTaskIdProvider);
    final allTasks = ref.watch(tasksProvider);

    return Container(
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(right: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: settings.headerHeight + settings.subHeaderHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              color: GanttTheme.surface1,
              border: Border(
                  bottom: BorderSide(color: GanttTheme.surface4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.list, size: 14, color: GanttTheme.textMuted),
                const SizedBox(width: 8),
                Text(
                  'TASK  (${tasks.length})',
                  style: GanttTheme.headerLabel,
                ),
              ],
            ),
          ),
          // Rows
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: tasks.length,
              itemExtent: rowHeight,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isSelected = selectedId == task.id;
                final depth = _calcDepth(task.id, allTasks, 0);
                final hasChildren =
                    allTasks.any((t) => t.parentId == task.id);

                return _SidebarRowItem(
                  task: task,
                  index: index,
                  rowHeight: rowHeight,
                  isSelected: isSelected,
                  depth: depth,
                  hasChildren: hasChildren,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _calcDepth(String id, List<Task> tasks, int d) {
    final task = tasks.firstWhere((t) => t.id == id, orElse: () => tasks.first);
    if (task.parentId == null || d > 8) return d;
    return _calcDepth(task.parentId!, tasks, d + 1);
  }
}

class _SidebarRowItem extends ConsumerStatefulWidget {
  final Task task;
  final int index;
  final double rowHeight;
  final bool isSelected;
  final int depth;
  final bool hasChildren;

  const _SidebarRowItem({
    required this.task,
    required this.index,
    required this.rowHeight,
    required this.isSelected,
    required this.depth,
    required this.hasChildren,
  });

  @override
  ConsumerState<_SidebarRowItem> createState() => _SidebarRowItemState();
}

class _SidebarRowItemState extends ConsumerState<_SidebarRowItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () =>
            ref.read(selectedTaskIdProvider.notifier).state = widget.task.id,
        child: AnimatedContainer(
          duration: GanttAnimations.fast,
          height: widget.rowHeight,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? GanttTheme.rowSelected
                : _hovered
                    ? GanttTheme.rowHover
                    : (widget.index.isEven
                        ? GanttTheme.rowEven
                        : GanttTheme.rowOdd),
            border: const Border(
              bottom: BorderSide(color: GanttTheme.gridLine, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: (widget.depth * 14.0) + 8),
              if (widget.hasChildren)
                GestureDetector(
                  onTap: () => ref
                      .read(tasksProvider.notifier)
                      .toggleExpanded(widget.task.id),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: AnimatedRotation(
                      turns: widget.task.isExpanded ? 0.25 : 0,
                      duration: GanttAnimations.fast,
                      child: const Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: GanttTheme.textMuted,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 16),
              const SizedBox(width: 4),
              // Status/milestone dot
              Container(
                width: widget.task.isMilestone ? 7 : 6,
                height: widget.task.isMilestone ? 7 : 6,
                decoration: BoxDecoration(
                  color: widget.task.isMilestone
                      ? widget.task.displayColor
                      : widget.task.status.color,
                  shape: widget.task.isMilestone
                      ? BoxShape.rectangle
                      : BoxShape.circle,
                  borderRadius: widget.task.isMilestone
                      ? BorderRadius.circular(1)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.task.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: widget.hasChildren
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: widget.task.isOverdue
                        ? GanttTheme.danger
                        : GanttTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_hovered || widget.isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    widget.task.priority.icon,
                    size: 10,
                    color: widget.task.priority.color,
                  ),
                ),
              if (widget.task.assignees.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.task.assignees
                        .take(2)
                        .map((a) => Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(left: 2),
                              decoration: BoxDecoration(
                                color: a.avatarColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: GanttTheme.surface1, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  a.initials[0],
                                  style: const TextStyle(
                                    fontSize: 7,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Row hover highlight ───────────────────────────────────────────────────────

class _RowHighlight extends ConsumerWidget {
  final Task task;
  final int rowIndex;
  final double rowHeight;
  final double totalWidth;

  const _RowHighlight({
    required this.task,
    required this.rowIndex,
    required this.rowHeight,
    required this.totalWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoveredId = ref.watch(hoveredTaskIdProvider);
    final selectedId = ref.watch(selectedTaskIdProvider);
    final isHovered = hoveredId == task.id;
    final isSelected = selectedId == task.id;

    if (!isHovered && !isSelected) return const SizedBox.shrink();

    return Positioned(
      top: rowIndex * rowHeight,
      left: 0,
      width: totalWidth,
      height: rowHeight,
      child: AnimatedContainer(
        duration: GanttAnimations.fast,
        color: isSelected
            ? GanttTheme.rowSelected.withOpacity(0.5)
            : GanttTheme.rowHover.withOpacity(0.4),
      ),
    );
  }
}

// ── Dependency arrows layer ───────────────────────────────────────────────────

class _DependencyLayer extends StatelessWidget {
  final List<Task> tasks;
  final DateTime ganttStart;
  final double dayWidth;
  final double rowHeight;
  final Set<String> criticalIds;

  const _DependencyLayer({
    required this.tasks,
    required this.ganttStart,
    required this.dayWidth,
    required this.rowHeight,
    required this.criticalIds,
  });

  @override
  Widget build(BuildContext context) {
    final arrows = <DependencyArrow>[];
    final taskIndexMap = {
      for (int i = 0; i < tasks.length; i++) tasks[i].id: i
    };

    for (final task in tasks) {
      for (final depId in task.dependencyIds) {
        final depIndex = taskIndexMap[depId];
        final taskIndex = taskIndexMap[task.id];
        if (depIndex == null || taskIndex == null) continue;

        final depTask = tasks[depIndex];
        final fromX = GanttDateUtils.dayOffset(ganttStart, depTask.endDate, dayWidth) +
            dayWidth;
        final fromY = (depIndex + 0.5) * rowHeight;
        final toX = GanttDateUtils.dayOffset(ganttStart, task.startDate, dayWidth);
        final toY = (taskIndex + 0.5) * rowHeight;

        arrows.add(DependencyArrow(
          from: Offset(fromX, fromY),
          to: Offset(toX, toY),
          isCritical: criticalIds.contains(task.id) && criticalIds.contains(depId),
        ));
      }
    }

    if (arrows.isEmpty) return const SizedBox.shrink();

    return CustomPaint(
      painter: DependencyArrowPainter(arrows: arrows),
    );
  }
}

// ── Today marker ──────────────────────────────────────────────────────────────

class _TodayMarker extends StatelessWidget {
  final DateTime ganttStart;
  final double dayWidth;
  final double totalHeight;

  const _TodayMarker({
    required this.ganttStart,
    required this.dayWidth,
    required this.totalHeight,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final x = GanttDateUtils.dayOffset(ganttStart, today, dayWidth) +
        dayWidth / 2;

    return Positioned(
      left: x - 1,
      top: 0,
      width: 2,
      height: totalHeight,
      child: Container(
        decoration: BoxDecoration(
          color: GanttTheme.accent.withOpacity(0.6),
          boxShadow: [
            BoxShadow(
              color: GanttTheme.accent.withOpacity(0.3),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Collapsed sidebar handle ──────────────────────────────────────────────────

class _CollapsedSidebarHandle extends StatelessWidget {
  final VoidCallback onExpand;
  const _CollapsedSidebarHandle({required this.onExpand});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      decoration: const BoxDecoration(
        color: GanttTheme.surface1,
        border: Border(right: BorderSide(color: GanttTheme.surface4)),
      ),
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.chevron_right, size: 14),
          onPressed: onExpand,
          color: GanttTheme.textMuted,
          tooltip: 'Expand sidebar',
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
