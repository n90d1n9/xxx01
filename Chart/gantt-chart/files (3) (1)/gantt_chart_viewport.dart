import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';
import '../../features/resource/resource_histogram.dart';
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
  // Histogram shares horizontal scroll
  final _histogramScrollCtrl = ScrollController();

  bool _syncH = false;
  bool _syncV = false;

  @override
  void initState() {
    super.initState();
    _hScrollCtrl.addListener(_onBodyHScroll);
    _headerScrollCtrl.addListener(_onHeaderHScroll);
    _histogramScrollCtrl.addListener(_onHistogramHScroll);
    _vScrollCtrl.addListener(_onBodyVScroll);
    _sidebarScrollCtrl.addListener(_onSidebarVScroll);
  }

  void _onBodyHScroll() {
    if (_syncH) return; _syncH = true;
    if (_headerScrollCtrl.hasClients) _headerScrollCtrl.jumpTo(_hScrollCtrl.offset);
    if (_histogramScrollCtrl.hasClients) _histogramScrollCtrl.jumpTo(_hScrollCtrl.offset);
    _syncH = false;
  }
  void _onHeaderHScroll() {
    if (_syncH) return; _syncH = true;
    if (_hScrollCtrl.hasClients) _hScrollCtrl.jumpTo(_headerScrollCtrl.offset);
    _syncH = false;
  }
  void _onHistogramHScroll() {
    if (_syncH) return; _syncH = true;
    if (_hScrollCtrl.hasClients) _hScrollCtrl.jumpTo(_histogramScrollCtrl.offset);
    _syncH = false;
  }
  void _onBodyVScroll() {
    if (_syncV) return; _syncV = true;
    if (_sidebarScrollCtrl.hasClients) _sidebarScrollCtrl.jumpTo(_vScrollCtrl.offset);
    _syncV = false;
  }
  void _onSidebarVScroll() {
    if (_syncV) return; _syncV = true;
    if (_vScrollCtrl.hasClients) _vScrollCtrl.jumpTo(_sidebarScrollCtrl.offset);
    _syncV = false;
  }

  @override
  void dispose() {
    _hScrollCtrl.dispose(); _vScrollCtrl.dispose();
    _headerScrollCtrl.dispose(); _sidebarScrollCtrl.dispose();
    _histogramScrollCtrl.dispose();
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
    final headerH = settings.headerHeight + settings.subHeaderHeight;
    final totalRows = visibleTasks.length;
    final totalH = totalRows * settings.rowHeight;
    final totalDays = GanttDateUtils.daysBetween(projectStart, projectEnd) + 1;
    final totalW = totalDays * settings.dayWidth;

    return Column(children: [
      // ── Header row ────────────────────────────────────────────────────────
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AnimatedContainer(
          duration: GanttAnimations.normal,
          width: sidebarWidth, height: headerH,
          decoration: const BoxDecoration(color: GanttTheme.surface1, border: Border(right: BorderSide(color: GanttTheme.surface4), bottom: BorderSide(color: GanttTheme.surface4))),
          child: isSidebarCollapsed ? null : Center(child: IconButton(
            icon: const Icon(Icons.chevron_left, size: 16), color: GanttTheme.textMuted,
            tooltip: 'Collapse sidebar',
            onPressed: () => ref.read(sidebarCollapsedProvider.notifier).state = true,
          )),
        ),
        Expanded(child: GanttHeader(
          startDate: projectStart, endDate: projectEnd,
          dayWidth: settings.dayWidth, settings: settings,
          scrollController: _headerScrollCtrl,
        )),
      ]),

      // ── Body row ──────────────────────────────────────────────────────────
      Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Sidebar
        AnimatedContainer(
          duration: GanttAnimations.normal,
          width: isSidebarCollapsed ? 24 : sidebarWidth,
          child: isSidebarCollapsed
              ? _CollapsedHandle(onExpand: () => ref.read(sidebarCollapsedProvider.notifier).state = false)
              : _SidebarPanel(tasks: visibleTasks, rowHeight: settings.rowHeight, scrollController: _sidebarScrollCtrl),
        ),
        // Chart + histogram stack
        Expanded(child: Column(children: [
          // Main chart area
          Expanded(child: Listener(
            onPointerSignal: (ev) {
              if (ev is PointerScrollEvent) {
                if (ev.scrollDelta.dx != 0 && _hScrollCtrl.hasClients) {
                  _hScrollCtrl.jumpTo((_hScrollCtrl.offset + ev.scrollDelta.dx).clamp(0.0, _hScrollCtrl.position.maxScrollExtent));
                } else if (_vScrollCtrl.hasClients) {
                  _vScrollCtrl.jumpTo((_vScrollCtrl.offset + ev.scrollDelta.dy).clamp(0.0, _vScrollCtrl.position.maxScrollExtent));
                }
              }
            },
            child: SingleChildScrollView(
              controller: _vScrollCtrl, physics: const ClampingScrollPhysics(),
              child: SingleChildScrollView(
                controller: _hScrollCtrl, scrollDirection: Axis.horizontal, physics: const ClampingScrollPhysics(),
                child: SizedBox(width: totalW, height: totalH,
                  child: Stack(children: [
                    // Grid
                    CustomPaint(size: Size(totalW, totalH), painter: GanttGridPainter(
                      startDate: projectStart, endDate: projectEnd,
                      dayWidth: settings.dayWidth, rowHeight: settings.rowHeight,
                      rowCount: totalRows, showWeekends: settings.showWeekends,
                      showToday: settings.showToday, today: DateTime.now(),
                    )),
                    // Row hover highlights
                    ...visibleTasks.asMap().entries.map((e) => _RowHighlight(
                      task: e.value, rowIndex: e.key,
                      rowHeight: settings.rowHeight, totalWidth: totalW,
                    )),
                    // Dependency arrows
                    if (settings.showDependencies)
                      _DependencyLayer(tasks: visibleTasks, ganttStart: projectStart, dayWidth: settings.dayWidth, rowHeight: settings.rowHeight, criticalIds: criticalIds),
                    // Task bars
                    ...visibleTasks.asMap().entries.map((e) => TaskBarWidget(
                      key: ValueKey(e.value.id),
                      task: e.value, ganttStart: projectStart,
                      dayWidth: settings.dayWidth, rowHeight: settings.rowHeight,
                      rowIndex: e.key, isCritical: criticalIds.contains(e.value.id),
                      showBaseline: settings.showBaseline,
                      onTap: () => ref.read(selectedTaskIdProvider.notifier).state = e.value.id,
                    )),
                    // Today marker
                    if (settings.showToday)
                      _TodayMarker(ganttStart: projectStart, dayWidth: settings.dayWidth, totalHeight: totalH),
                    // Mini-map scrubber overlay (bottom)
                    _MiniMapScrubber(ganttStart: projectStart, ganttEnd: projectEnd, dayWidth: settings.dayWidth, hScrollController: _hScrollCtrl),
                  ]),
                ),
              ),
            ),
          )),
          // Resource histogram (conditional)
          if (settings.showResourceHistogram)
            ResourceHistogram(
              ganttStart: projectStart, ganttEnd: projectEnd,
              dayWidth: settings.dayWidth, hScrollController: _histogramScrollCtrl,
            ),
        ])),
      ])),
    ]);
  }
}

// ─── Sidebar panel ────────────────────────────────────────────────────────────

class _SidebarPanel extends ConsumerWidget {
  final List<Task> tasks;
  final double rowHeight;
  final ScrollController scrollController;

  const _SidebarPanel({required this.tasks, required this.rowHeight, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(viewSettingsProvider);
    final selectedId = ref.watch(selectedTaskIdProvider);
    final allTasks = ref.watch(tasksProvider);

    return Container(
      decoration: const BoxDecoration(color: GanttTheme.surface1, border: Border(right: BorderSide(color: GanttTheme.surface4))),
      child: Column(children: [
        Container(
          height: settings.headerHeight + settings.subHeaderHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(color: GanttTheme.surface1, border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
          child: Row(children: [
            const Icon(Icons.list, size: 13, color: GanttTheme.textMuted),
            const SizedBox(width: 6),
            Text('TASKS (${tasks.length})', style: GanttTheme.headerLabel),
          ]),
        ),
        Expanded(child: ListView.builder(
          controller: scrollController,
          itemCount: tasks.length,
          itemExtent: rowHeight,
          itemBuilder: (_, i) {
            final task = tasks[i];
            final depth = _depth(task.id, allTasks);
            final hasChildren = allTasks.any((t) => t.parentId == task.id);
            return _SidebarRow(
              task: task, index: i, rowHeight: rowHeight,
              isSelected: selectedId == task.id,
              depth: depth, hasChildren: hasChildren,
              showWbs: settings.showWbsCodes,
            );
          },
        )),
      ]),
    );
  }

  int _depth(String id, List<Task> all, [int d = 0]) {
    final t = all.firstWhere((x) => x.id == id, orElse: () => all.first);
    if (t.parentId == null || d > 8) return d;
    return _depth(t.parentId!, all, d + 1);
  }
}

class _SidebarRow extends ConsumerStatefulWidget {
  final Task task;
  final int index;
  final double rowHeight;
  final bool isSelected;
  final int depth;
  final bool hasChildren;
  final bool showWbs;

  const _SidebarRow({required this.task, required this.index, required this.rowHeight, required this.isSelected, required this.depth, required this.hasChildren, required this.showWbs});

  @override
  ConsumerState<_SidebarRow> createState() => _SidebarRowState();
}

class _SidebarRowState extends ConsumerState<_SidebarRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: GestureDetector(
      onTap: () => ref.read(selectedTaskIdProvider.notifier).state = widget.task.id,
      child: AnimatedContainer(
        duration: GanttAnimations.fast, height: widget.rowHeight,
        decoration: BoxDecoration(
          color: widget.isSelected ? GanttTheme.rowSelected : _hovered ? GanttTheme.rowHover : (widget.index.isEven ? GanttTheme.rowEven : GanttTheme.rowOdd),
          border: const Border(bottom: BorderSide(color: GanttTheme.gridLine, width: 0.5)),
        ),
        child: Row(children: [
          SizedBox(width: widget.depth * 14.0 + 6),
          if (widget.hasChildren)
            GestureDetector(
              onTap: () => ref.read(tasksProvider.notifier).toggleExpanded(widget.task.id),
              child: Padding(padding: const EdgeInsets.only(right: 2),
                child: AnimatedRotation(turns: widget.task.isExpanded ? 0.25 : 0, duration: GanttAnimations.fast,
                  child: const Icon(Icons.chevron_right, size: 14, color: GanttTheme.textMuted))))
          else
            const SizedBox(width: 16),
          const SizedBox(width: 3),
          // WBS code
          if (widget.showWbs && widget.task.wbsCode != null)
            SizedBox(width: 32, child: Text(widget.task.wbsCode!, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, color: GanttTheme.textDisabled), overflow: TextOverflow.ellipsis)),
          // Status dot
          Container(width: widget.task.isMilestone ? 7 : 6, height: widget.task.isMilestone ? 7 : 6,
            decoration: BoxDecoration(
              color: widget.task.isMilestone ? widget.task.displayColor : widget.task.status.color,
              shape: widget.task.isMilestone ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: widget.task.isMilestone ? BorderRadius.circular(1) : null,
            )),
          const SizedBox(width: 7),
          // Title
          Expanded(child: Text(widget.task.title,
            style: TextStyle(fontFamily: 'Inter', fontSize: 12,
              fontWeight: widget.hasChildren ? FontWeight.w600 : FontWeight.w400,
              color: widget.task.isOverdue ? GanttTheme.danger : GanttTheme.textPrimary),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
          // Priority + assignees
          if (_hovered || widget.isSelected) ...[
            Icon(widget.task.priority.icon, size: 10, color: widget.task.priority.color),
            const SizedBox(width: 4),
          ],
          if (widget.task.riskLevel != RiskLevel.none)
            Padding(padding: const EdgeInsets.only(right: 4),
              child: Container(width: 5, height: 5, decoration: BoxDecoration(color: widget.task.riskLevel.color, shape: BoxShape.circle))),
          if (widget.task.assignees.isNotEmpty)
            Padding(padding: const EdgeInsets.only(right: 8),
              child: Row(mainAxisSize: MainAxisSize.min,
                children: widget.task.assignees.take(2).map((a) => Container(
                  width: 16, height: 16, margin: const EdgeInsets.only(left: 2),
                  decoration: BoxDecoration(color: a.avatarColor, shape: BoxShape.circle, border: Border.all(color: GanttTheme.surface1, width: 1)),
                  child: Center(child: Text(a.initials[0], style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.white))),
                )).toList())),
        ]),
      ),
    ),
  );
}

// ─── Mini-map scrubber ────────────────────────────────────────────────────────

class _MiniMapScrubber extends StatefulWidget {
  final DateTime ganttStart, ganttEnd;
  final double dayWidth;
  final ScrollController hScrollController;
  const _MiniMapScrubber({required this.ganttStart, required this.ganttEnd, required this.dayWidth, required this.hScrollController});
  @override
  State<_MiniMapScrubber> createState() => _MiniMapScrubberState();
}

class _MiniMapScrubberState extends State<_MiniMapScrubber> {
  bool _visible = false;

  void _onDrag(DragUpdateDetails d) {
    if (!widget.hScrollController.hasClients) return;
    final totalDays = GanttDateUtils.daysBetween(widget.ganttStart, widget.ganttEnd) + 1;
    final totalW = totalDays * widget.dayWidth;
    final scrubberW = 120.0;
    final ratio = totalW / scrubberW;
    final newOffset = (widget.hScrollController.offset + d.delta.dx * ratio)
        .clamp(0.0, widget.hScrollController.position.maxScrollExtent);
    widget.hScrollController.jumpTo(newOffset);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 6, right: 12,
      child: MouseRegion(
        onEnter: (_) => setState(() => _visible = true),
        onExit: (_) => setState(() => _visible = false),
        child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.3, duration: GanttAnimations.fast,
          child: GestureDetector(
            onHorizontalDragUpdate: _onDrag,
            child: Container(
              width: 120, height: 16,
              decoration: BoxDecoration(color: GanttTheme.surface3.withOpacity(0.9), borderRadius: BorderRadius.circular(8), border: Border.all(color: GanttTheme.surface4)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.drag_indicator, size: 10, color: GanttTheme.textMuted),
                const SizedBox(width: 4),
                const Text('Drag to scroll', style: TextStyle(fontFamily: 'Inter', fontSize: 8, color: GanttTheme.textMuted)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Row Highlight ────────────────────────────────────────────────────────────

class _RowHighlight extends ConsumerWidget {
  final Task task;
  final int rowIndex;
  final double rowHeight, totalWidth;
  const _RowHighlight({required this.task, required this.rowIndex, required this.rowHeight, required this.totalWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hovered = ref.watch(hoveredTaskIdProvider) == task.id;
    final selected = ref.watch(selectedTaskIdProvider) == task.id;
    if (!hovered && !selected) return const SizedBox.shrink();
    return Positioned(top: rowIndex * rowHeight, left: 0, width: totalWidth, height: rowHeight,
      child: AnimatedContainer(duration: GanttAnimations.fast,
        color: selected ? GanttTheme.rowSelected.withOpacity(0.5) : GanttTheme.rowHover.withOpacity(0.4)));
  }
}

// ─── Dependency Layer ─────────────────────────────────────────────────────────

class _DependencyLayer extends StatelessWidget {
  final List<Task> tasks;
  final DateTime ganttStart;
  final double dayWidth, rowHeight;
  final Set<String> criticalIds;
  const _DependencyLayer({required this.tasks, required this.ganttStart, required this.dayWidth, required this.rowHeight, required this.criticalIds});

  @override
  Widget build(BuildContext context) {
    final arrows = <DependencyArrow>[];
    final idxMap = {for (int i = 0; i < tasks.length; i++) tasks[i].id: i};
    for (final task in tasks) {
      for (final dep in task.dependencies) {
        final depIdx = idxMap[dep.predecessorId];
        final taskIdx = idxMap[task.id];
        if (depIdx == null || taskIdx == null) continue;
        final depTask = tasks[depIdx];
        // Adjust from/to based on dependency type
        final (fromX, toX) = switch (dep.type) {
          DependencyType.fs => (GanttDateUtils.dayOffset(ganttStart, depTask.endDate, dayWidth) + dayWidth, GanttDateUtils.dayOffset(ganttStart, task.startDate, dayWidth) + dep.lagDays * dayWidth),
          DependencyType.ss => (GanttDateUtils.dayOffset(ganttStart, depTask.startDate, dayWidth), GanttDateUtils.dayOffset(ganttStart, task.startDate, dayWidth) + dep.lagDays * dayWidth),
          DependencyType.ff => (GanttDateUtils.dayOffset(ganttStart, depTask.endDate, dayWidth) + dayWidth, GanttDateUtils.dayOffset(ganttStart, task.endDate, dayWidth) + dayWidth + dep.lagDays * dayWidth),
          DependencyType.sf => (GanttDateUtils.dayOffset(ganttStart, depTask.startDate, dayWidth), GanttDateUtils.dayOffset(ganttStart, task.endDate, dayWidth) + dayWidth + dep.lagDays * dayWidth),
        };
        arrows.add(DependencyArrow(
          from: Offset(fromX, (depIdx + 0.5) * rowHeight),
          to: Offset(toX, (taskIdx + 0.5) * rowHeight),
          isCritical: criticalIds.contains(task.id) && criticalIds.contains(dep.predecessorId),
          type: dep.type,
        ));
      }
    }
    if (arrows.isEmpty) return const SizedBox.shrink();
    return CustomPaint(painter: DependencyArrowPainter(arrows: arrows));
  }
}

// ─── Today marker ─────────────────────────────────────────────────────────────

class _TodayMarker extends StatelessWidget {
  final DateTime ganttStart;
  final double dayWidth, totalHeight;
  const _TodayMarker({required this.ganttStart, required this.dayWidth, required this.totalHeight});

  @override
  Widget build(BuildContext context) {
    final x = GanttDateUtils.dayOffset(ganttStart, DateTime.now(), dayWidth) + dayWidth / 2;
    return Positioned(left: x - 1, top: 0, width: 2, height: totalHeight,
      child: Container(decoration: BoxDecoration(
        color: GanttTheme.accent.withOpacity(0.6),
        boxShadow: [BoxShadow(color: GanttTheme.accent.withOpacity(0.3), blurRadius: 6)],
      )));
  }
}

// ─── Collapsed sidebar handle ─────────────────────────────────────────────────

class _CollapsedHandle extends StatelessWidget {
  final VoidCallback onExpand;
  const _CollapsedHandle({required this.onExpand});
  @override
  Widget build(BuildContext context) => Container(
    width: 24,
    decoration: const BoxDecoration(color: GanttTheme.surface1, border: Border(right: BorderSide(color: GanttTheme.surface4))),
    child: Center(child: IconButton(icon: const Icon(Icons.chevron_right, size: 14), onPressed: onExpand, color: GanttTheme.textMuted, tooltip: 'Expand sidebar', padding: EdgeInsets.zero)),
  );
}
