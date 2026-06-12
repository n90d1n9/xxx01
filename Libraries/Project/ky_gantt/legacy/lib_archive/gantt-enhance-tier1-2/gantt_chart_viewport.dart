import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';
import '../../features/resource/resource_histogram.dart';
import 'gantt_header.dart';
import 'gantt_grid_painter.dart';
import 'task_bar_widget.dart';
import 'dependency_arrow_painter.dart';
import 'hover_popover.dart';
import 'dependency_draw_layer.dart';

// ─── Main viewport ─────────────────────────────────────────────────────────────

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
  final _histogramScrollCtrl = ScrollController();

  // Drag-to-create state
  bool _isCreating = false;
  int _createRowIndex = 0;
  double _createStartX = 0;
  double _createCurrentX = 0;

  // Hover popover controller
  final _hoverCtrl = HoverPopoverController();

  // Pinch-to-zoom state
  double _pinchStartDayWidth = 32.0;

  // Zoom-anchor: remember which day was at viewport center before zoom
  double? _zoomAnchorDay;

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

    // Auto-scroll to today after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
  }

  // ── Scroll sync ────────────────────────────────────────────────────────────
  void _onBodyHScroll() {
    if (_syncH) return;
    _syncH = true;
    if (_headerScrollCtrl.hasClients)
      _headerScrollCtrl.jumpTo(_hScrollCtrl.offset);
    if (_histogramScrollCtrl.hasClients)
      _histogramScrollCtrl.jumpTo(_hScrollCtrl.offset);
    _syncH = false;
  }

  void _onHeaderHScroll() {
    if (_syncH) return;
    _syncH = true;
    if (_hScrollCtrl.hasClients) _hScrollCtrl.jumpTo(_headerScrollCtrl.offset);
    _syncH = false;
  }

  void _onHistogramHScroll() {
    if (_syncH) return;
    _syncH = true;
    if (_hScrollCtrl.hasClients)
      _hScrollCtrl.jumpTo(_histogramScrollCtrl.offset);
    _syncH = false;
  }

  void _onBodyVScroll() {
    if (_syncV) return;
    _syncV = true;
    if (_sidebarScrollCtrl.hasClients)
      _sidebarScrollCtrl.jumpTo(_vScrollCtrl.offset);
    _syncV = false;
  }

  void _onSidebarVScroll() {
    if (_syncV) return;
    _syncV = true;
    if (_vScrollCtrl.hasClients) _vScrollCtrl.jumpTo(_sidebarScrollCtrl.offset);
    _syncV = false;
  }

  @override
  void dispose() {
    _hScrollCtrl.dispose();
    _vScrollCtrl.dispose();
    _headerScrollCtrl.dispose();
    _sidebarScrollCtrl.dispose();
    _histogramScrollCtrl.dispose();
    super.dispose();
  }

  // ── Auto-scroll to today ───────────────────────────────────────────────────
  void _scrollToToday() {
    final (start, _) = ref.read(projectDateRangeProvider);
    final settings = ref.read(viewSettingsProvider);
    if (!_hScrollCtrl.hasClients) return;

    final todayOffset =
        GanttDateUtils.dayOffset(start, DateTime.now(), settings.dayWidth);
    // Show today ~25% from left edge
    final targetX =
        (todayOffset - _hScrollCtrl.position.viewportDimension * 0.25)
            .clamp(0.0, _hScrollCtrl.position.maxScrollExtent);
    _hScrollCtrl.animateTo(targetX,
        duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
  }

  // ── Scroll-to-selected task ────────────────────────────────────────────────
  void _scrollToTask(Task task) {
    final (start, _) = ref.read(projectDateRangeProvider);
    final settings = ref.read(viewSettingsProvider);
    final tasks = ref.read(visibleTasksProvider);
    final rowIndex = tasks.indexWhere((t) => t.id == task.id);
    if (rowIndex < 0) return;

    if (_hScrollCtrl.hasClients) {
      final x =
          GanttDateUtils.dayOffset(start, task.startDate, settings.dayWidth);
      final vw = _hScrollCtrl.position.viewportDimension;
      final targetX =
          (x - vw * 0.25).clamp(0.0, _hScrollCtrl.position.maxScrollExtent);
      _hScrollCtrl.animateTo(targetX,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
    if (_vScrollCtrl.hasClients) {
      final y = rowIndex * settings.rowHeight;
      final vh = _vScrollCtrl.position.viewportDimension;
      final targetY =
          (y - vh * 0.35).clamp(0.0, _vScrollCtrl.position.maxScrollExtent);
      _vScrollCtrl.animateTo(targetY,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  // ── Ctrl+scroll zoom with viewport anchor ──────────────────────────────────
  void _handleZoomScroll(PointerScrollEvent ev) {
    if (!_hScrollCtrl.hasClients) return;
    final settings = ref.read(viewSettingsProvider);
    final vw = _hScrollCtrl.position.viewportDimension;

    // Compute which day is currently at viewport center before zooming
    final centerPixel = _hScrollCtrl.offset + vw / 2;
    final centerDay = centerPixel / settings.dayWidth;

    final delta = -ev.scrollDelta.dy * 0.3;
    final newWidth = (settings.dayWidth + delta).clamp(8.0, 120.0);

    ref
        .read(viewSettingsProvider.notifier)
        .update((s) => s.copyWith(dayWidth: newWidth));

    // After layout, re-anchor to the same day
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hScrollCtrl.hasClients) return;
      final newCenterPixel = centerDay * newWidth;
      final newOffset = (newCenterPixel - vw / 2)
          .clamp(0.0, _hScrollCtrl.position.maxScrollExtent);
      _hScrollCtrl.jumpTo(newOffset);
    });
  }

  // ── Drag-to-create helpers ─────────────────────────────────────────────────
  void _onCreateDragStart(
      DragStartDetails d, int rowIndex, DateTime ganttStart, double dayWidth) {
    final localX = d.localPosition.dx + _hScrollCtrl.offset;
    setState(() {
      _isCreating = true;
      _createRowIndex = rowIndex;
      _createStartX = localX;
      _createCurrentX = localX;
    });
  }

  void _onCreateDragUpdate(DragUpdateDetails d) {
    if (!_isCreating) return;
    setState(() => _createCurrentX =
        (_createCurrentX + d.delta.dx).clamp(0.0, double.infinity));
  }

  void _onCreateDragEnd(DateTime ganttStart, double dayWidth) {
    if (!_isCreating) return;
    final startPx = math.min(_createStartX, _createCurrentX);
    final endPx = math.max(_createStartX, _createCurrentX);
    final startDay = (startPx / dayWidth).floor();
    final endDay = (endPx / dayWidth).ceil();

    if (endDay - startDay >= 1) {
      final newStart = ganttStart.add(Duration(days: startDay));
      final newEnd = ganttStart.add(Duration(days: endDay));
      _showQuickCreateDialog(newStart, newEnd);
    }
    setState(() {
      _isCreating = false;
    });
  }

  void _showQuickCreateDialog(DateTime start, DateTime end) {
    showDialog(
      context: context,
      builder: (_) => _QuickCreateDialog(
        start: start,
        end: end,
        onCreate: (title) {
          final now = DateTime.now();
          final task = Task(
            id: 'task_${now.millisecondsSinceEpoch}',
            title: title,
            startDate: start,
            endDate: end,
            createdAt: now,
            updatedAt: now,
          );
          ref.read(tasksProvider.notifier).addTask(task);
        },
      ),
    );
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

    // Listen for selection changes and scroll chart into view
    ref.listen<String?>(selectedTaskIdProvider, (_, id) {
      if (id == null) return;
      final task = visibleTasks
          .cast<Task?>()
          .firstWhere((t) => t?.id == id, orElse: () => null);
      if (task != null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _scrollToTask(task));
      }
    });

    // Listen for "jump to today" toolbar button
    ref.listen<int>(scrollToTodayProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToToday());
    });

    return Column(children: [
      // ── Header ─────────────────────────────────────────────────────────────
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Sidebar header corner
        AnimatedContainer(
          duration: GanttAnimations.normal,
          width: isSidebarCollapsed ? 24 : sidebarWidth,
          height: headerH,
          decoration: const BoxDecoration(
              color: GanttTheme.surface1,
              border: Border(
                  right: BorderSide(color: GanttTheme.surface4),
                  bottom: BorderSide(color: GanttTheme.surface4))),
          child: isSidebarCollapsed
              ? null
              : Center(
                  child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 16),
                      color: GanttTheme.textMuted,
                      tooltip: 'Collapse sidebar',
                      onPressed: () => ref
                          .read(sidebarCollapsedProvider.notifier)
                          .state = true)),
        ),
        Expanded(
            child: GanttHeader(
          startDate: projectStart,
          endDate: projectEnd,
          dayWidth: settings.dayWidth,
          settings: settings,
          scrollController: _headerScrollCtrl,
        )),
      ]),

      // ── Body ───────────────────────────────────────────────────────────────
      Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Sidebar (resizable) ─────────────────────────────────────────────
        if (isSidebarCollapsed)
          _CollapsedHandle(
              onExpand: () =>
                  ref.read(sidebarCollapsedProvider.notifier).state = false)
        else
          _ResizableSidebar(
            width: sidebarWidth,
            child: _SidebarPanel(
              tasks: visibleTasks,
              rowHeight: settings.rowHeight,
              scrollController: _sidebarScrollCtrl,
            ),
            onResize: (delta) {
              final newW = (sidebarWidth + delta).clamp(160.0, 560.0);
              ref
                  .read(viewSettingsProvider.notifier)
                  .update((s) => s.copyWith(sidebarWidth: newW));
            },
          ),

        // ── Chart + histogram ────────────────────────────────────────────────
        Expanded(
            child: Column(children: [
          Expanded(
              child: Listener(
            onPointerSignal: (ev) {
              if (ev is! PointerScrollEvent) return;
              // Ctrl+scroll → zoom with anchor
              if (HardwareKeyboard.instance.isControlPressed) {
                _handleZoomScroll(ev);
                return;
              }
              // Normal horizontal scroll
              if (ev.scrollDelta.dx != 0 && _hScrollCtrl.hasClients) {
                _hScrollCtrl.jumpTo((_hScrollCtrl.offset + ev.scrollDelta.dx)
                    .clamp(0.0, _hScrollCtrl.position.maxScrollExtent));
              } else if (_vScrollCtrl.hasClients) {
                _vScrollCtrl.jumpTo((_vScrollCtrl.offset + ev.scrollDelta.dy)
                    .clamp(0.0, _vScrollCtrl.position.maxScrollExtent));
              }
            },
            child: GestureDetector(
                onScaleStart: (d) {
                  _pinchStartDayWidth = ref.read(viewSettingsProvider).dayWidth;
                },
                onScaleUpdate: (d) {
                  if (d.pointerCount < 2) return;
                  final newW =
                      (_pinchStartDayWidth * d.scale).clamp(8.0, 120.0);
                  ref
                      .read(viewSettingsProvider.notifier)
                      .update((s) => s.copyWith(dayWidth: newW));
                },
                child: SingleChildScrollView(
                  controller: _vScrollCtrl,
                  physics: const ClampingScrollPhysics(),
                  child: SingleChildScrollView(
                    controller: _hScrollCtrl,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: totalW,
                      height: totalH,
                      child: Stack(children: [
                        // Grid background
                        CustomPaint(
                            size: Size(totalW, totalH),
                            painter: GanttGridPainter(
                              startDate: projectStart,
                              endDate: projectEnd,
                              dayWidth: settings.dayWidth,
                              rowHeight: settings.rowHeight,
                              rowCount: totalRows,
                              showWeekends: settings.showWeekends,
                              showToday: settings.showToday,
                              today: DateTime.now(),
                            )),

                        // Row hover highlights
                        ...visibleTasks
                            .asMap()
                            .entries
                            .map((e) => _RowHighlight(
                                  task: e.value,
                                  rowIndex: e.key,
                                  rowHeight: settings.rowHeight,
                                  totalWidth: totalW,
                                )),

                        // ── Drag-to-create: invisible gesture layer per row ───────
                        ...visibleTasks.asMap().entries.map((e) => Positioned(
                              left: 0,
                              top: e.key * settings.rowHeight,
                              width: totalW,
                              height: settings.rowHeight,
                              child: GestureDetector(
                                onHorizontalDragStart: (d) =>
                                    _onCreateDragStart(d, e.key, projectStart,
                                        settings.dayWidth),
                                onHorizontalDragUpdate: _onCreateDragUpdate,
                                onHorizontalDragEnd: (_) => _onCreateDragEnd(
                                    projectStart, settings.dayWidth),
                                behavior: HitTestBehavior.translucent,
                                child: const SizedBox.expand(),
                              ),
                            )),

                        // ── Drag-to-create preview rubber-band ────────────────────
                        if (_isCreating)
                          _CreatePreview(
                            startX: math.min(_createStartX, _createCurrentX) -
                                (_hScrollCtrl.hasClients
                                    ? _hScrollCtrl.offset
                                    : 0),
                            endX: math.max(_createStartX, _createCurrentX) -
                                (_hScrollCtrl.hasClients
                                    ? _hScrollCtrl.offset
                                    : 0),
                            rowIndex: _createRowIndex,
                            rowHeight: settings.rowHeight,
                            dayWidth: settings.dayWidth,
                            ganttStart: projectStart,
                          ),

                        // Dependency arrows
                        if (settings.showDependencies)
                          _DependencyLayer(
                            tasks: visibleTasks,
                            ganttStart: projectStart,
                            dayWidth: settings.dayWidth,
                            rowHeight: settings.rowHeight,
                            criticalIds: criticalIds,
                          ),

                        // Task bars (on top of gesture layer)
                        ...visibleTasks.asMap().entries.map((e) =>
                            TaskBarWidget(
                              key: ValueKey(e.value.id),
                              task: e.value,
                              ganttStart: projectStart,
                              dayWidth: settings.dayWidth,
                              rowHeight: settings.rowHeight,
                              rowIndex: e.key,
                              isCritical: criticalIds.contains(e.value.id),
                              showBaseline: settings.showBaseline,
                              isMultiSelected: ref
                                  .watch(multiSelectProvider)
                                  .contains(e.value.id),
                              onTap: () {
                                final multiKeys =
                                    HardwareKeyboard.instance.isShiftPressed ||
                                        HardwareKeyboard
                                            .instance.isControlPressed ||
                                        HardwareKeyboard.instance.isMetaPressed;
                                if (multiKeys) {
                                  final current = Set<String>.from(
                                      ref.read(multiSelectProvider));
                                  if (current.contains(e.value.id)) {
                                    current.remove(e.value.id);
                                  } else {
                                    current.add(e.value.id);
                                  }
                                  ref.read(multiSelectProvider.notifier).state =
                                      current;
                                } else {
                                  ref.read(multiSelectProvider.notifier).state =
                                      {};
                                  ref
                                      .read(selectedTaskIdProvider.notifier)
                                      .state = e.value.id;
                                }
                              },
                              onHover: (globalPos) =>
                                  _hoverCtrl.show(context, e.value, globalPos),
                              onHoverEnd: () => _hoverCtrl.hide(),
                            )),

                        // Today marker
                        if (settings.showToday)
                          _TodayMarker(
                              ganttStart: projectStart,
                              dayWidth: settings.dayWidth,
                              totalHeight: totalH),

                        // Mini-map scrubber
                        _MiniMapScrubber(
                            ganttStart: projectStart,
                            ganttEnd: projectEnd,
                            dayWidth: settings.dayWidth,
                            hScrollController: _hScrollCtrl),
                      ]),
                    ),
                  ),
                )), // GestureDetector (pinch)
          )),

          // Resource histogram
          if (settings.showResourceHistogram)
            ResourceHistogram(
              ganttStart: projectStart,
              ganttEnd: projectEnd,
              dayWidth: settings.dayWidth,
              hScrollController: _histogramScrollCtrl,
            ),
        ])),
      ])),
    ]);
  }
}

// ─── Resizable sidebar wrapper ─────────────────────────────────────────────────

class _ResizableSidebar extends StatelessWidget {
  final double width;
  final Widget child;
  final void Function(double) onResize;

  const _ResizableSidebar({
    required this.width,
    required this.child,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: width, child: child),
          // Drag handle
          GestureDetector(
            onHorizontalDragUpdate: (d) => onResize(d.delta.dx),
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: Container(
                width: 5,
                color: Colors.transparent,
                child: Center(
                    child: Container(
                  width: 1,
                  color: GanttTheme.surface4,
                )),
              ),
            ),
          ),
        ],
      );
}

// ─── Drag-to-create preview ────────────────────────────────────────────────────

class _CreatePreview extends StatelessWidget {
  final double startX, endX, rowHeight, dayWidth;
  final int rowIndex;
  final DateTime ganttStart;

  const _CreatePreview({
    required this.startX,
    required this.endX,
    required this.rowHeight,
    required this.rowIndex,
    required this.dayWidth,
    required this.ganttStart,
  });

  @override
  Widget build(BuildContext context) {
    final w = (endX - startX).abs().clamp(4.0, double.infinity);

    // Snap label
    final startDays = (startX / dayWidth).floor();
    final endDays = (endX / dayWidth).ceil();
    final s = ganttStart.add(Duration(days: startDays));
    final e = ganttStart.add(Duration(days: endDays));

    return Positioned(
      left: startX,
      top: rowIndex * rowHeight + 6,
      width: w,
      height: rowHeight - 12,
      child: IgnorePointer(
        child: Column(children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: GanttTheme.accent.withOpacity(0.18),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    color: GanttTheme.accent.withOpacity(0.7), width: 1.5),
              ),
              child: Center(
                  child: w > 48
                      ? const Icon(Icons.add,
                          size: 14, color: GanttTheme.accent)
                      : null),
            ),
          ),
          if (w > 60)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: GanttTheme.surface3,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: GanttTheme.accent.withOpacity(0.4)),
              ),
              child: Text(
                '${GanttDateUtils.formatShortDate(s)} – ${GanttDateUtils.formatShortDate(e)}',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    color: GanttTheme.textSecondary),
              ),
            ),
        ]),
      ),
    );
  }
}

// ─── Quick-create dialog ───────────────────────────────────────────────────────

class _QuickCreateDialog extends StatefulWidget {
  final DateTime start, end;
  final void Function(String title) onCreate;
  const _QuickCreateDialog(
      {required this.start, required this.end, required this.onCreate});
  @override
  State<_QuickCreateDialog> createState() => _QuickCreateDialogState();
}

class _QuickCreateDialogState extends State<_QuickCreateDialog> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final t = _ctrl.text.trim();
    if (t.isNotEmpty) {
      widget.onCreate(t);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: const Color(0xFF1C2333),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF2E3854))),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
              width: 360,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(children: [
                      Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                              color: GanttTheme.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.add,
                              size: 16, color: GanttTheme.accent)),
                      const SizedBox(width: 10),
                      const Text('New Task',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: GanttTheme.textPrimary)),
                    ]),
                    const SizedBox(height: 16),

                    // Date range display
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: GanttTheme.surface3,
                          borderRadius: BorderRadius.circular(7)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 13, color: GanttTheme.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          '${GanttDateUtils.formatShortDate(widget.start)}  →  '
                          '${GanttDateUtils.formatShortDate(widget.end)}',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: GanttTheme.textSecondary),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 14),

                    // Title input
                    TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: GanttTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Task name…',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 20),

                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Create'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GanttTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          textStyle: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7)),
                        ),
                      ),
                    ]),
                  ])),
        ),
      );
}

// ─── Sidebar panel ─────────────────────────────────────────────────────────────

class _SidebarPanel extends ConsumerWidget {
  final List<Task> tasks;
  final double rowHeight;
  final ScrollController scrollController;

  const _SidebarPanel({
    required this.tasks,
    required this.rowHeight,
    required this.scrollController,
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
      child: Column(children: [
        // Header
        Container(
          height: settings.headerHeight + settings.subHeaderHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
              color: GanttTheme.surface1,
              border: Border(bottom: BorderSide(color: GanttTheme.surface4))),
          child: Row(children: [
            const Icon(Icons.list, size: 13, color: GanttTheme.textMuted),
            const SizedBox(width: 6),
            Text('TASKS (${tasks.length})', style: GanttTheme.headerLabel),
            const Spacer(),
            Tooltip(
              message: 'Drag rows to reorder',
              child: const Icon(Icons.swap_vert,
                  size: 13, color: GanttTheme.textDisabled),
            ),
          ]),
        ),

        // Reorderable task list
        Expanded(
            child: ReorderableListView.builder(
          scrollController: scrollController,
          itemCount: tasks.length,
          itemExtent: rowHeight,
          buildDefaultDragHandles: false,
          onReorder: (oldIdx, newIdx) {
            if (newIdx > oldIdx) newIdx--;
            ref
                .read(tasksProvider.notifier)
                .moveTaskToIndex(tasks[oldIdx].id, tasks[newIdx].id);
          },
          proxyDecorator: (child, index, animation) => Material(
            elevation: 0,
            color: Colors.transparent,
            child: ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.02).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            ),
          ),
          itemBuilder: (_, i) {
            final task = tasks[i];
            final depth = _depth(task.id, allTasks);
            final hasChild = allTasks.any((t) => t.parentId == task.id);
            return _SidebarRow(
              key: ValueKey(task.id),
              task: task,
              index: i,
              rowHeight: rowHeight,
              isSelected: selectedId == task.id,
              depth: depth,
              hasChildren: hasChild,
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

// ─── Sidebar row ──────────────────────────────────────────────────────────────

class _SidebarRow extends ConsumerStatefulWidget {
  final Task task;
  final int index;
  final double rowHeight;
  final bool isSelected, hasChildren, showWbs;
  final int depth;

  const _SidebarRow({
    required Key key,
    required this.task,
    required this.index,
    required this.rowHeight,
    required this.isSelected,
    required this.depth,
    required this.hasChildren,
    required this.showWbs,
  }) : super(key: key);

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
                  bottom: BorderSide(color: GanttTheme.gridLine, width: 0.5)),
            ),
            child: Row(children: [
              SizedBox(width: widget.depth * 14.0 + 4),

              // Expand / collapse arrow
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
                        child: const Icon(Icons.chevron_right,
                            size: 14, color: GanttTheme.textMuted)),
                  ),
                )
              else
                const SizedBox(width: 16),

              const SizedBox(width: 3),

              // WBS code
              if (widget.showWbs && widget.task.wbsCode != null)
                SizedBox(
                    width: 32,
                    child: Text(widget.task.wbsCode!,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            color: GanttTheme.textDisabled),
                        overflow: TextOverflow.ellipsis)),

              // Status dot
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
                  borderRadius:
                      widget.task.isMilestone ? BorderRadius.circular(1) : null,
                ),
              ),
              const SizedBox(width: 7),

              // Title
              Expanded(
                  child: Text(widget.task.title,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: widget.hasChildren
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: widget.task.isOverdue
                              ? GanttTheme.danger
                              : GanttTheme.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),

              // Priority icon (on hover)
              if (_hovered || widget.isSelected) ...[
                Icon(widget.task.priority.icon,
                    size: 10, color: widget.task.priority.color),
                const SizedBox(width: 4),
              ],

              // Risk dot
              if (widget.task.riskLevel != RiskLevel.none)
                Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                            color: widget.task.riskLevel.color,
                            shape: BoxShape.circle))),

              // Assignee avatars
              if (widget.task.assignees.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(right: 4),
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
                                          color: GanttTheme.surface1,
                                          width: 1)),
                                  child: Center(
                                      child: Text(a.initials[0],
                                          style: const TextStyle(
                                              fontSize: 7,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white))),
                                ))
                            .toList())),

              // Drag handle for reorder
              ReorderableDragStartListener(
                index: widget.index,
                child: const Padding(
                  padding: EdgeInsets.only(right: 8, left: 2),
                  child: Icon(Icons.drag_indicator,
                      size: 14, color: GanttTheme.textDisabled),
                ),
              ),
            ]),
          ),
        ),
      );
}

// ─── Mini-map scrubber ─────────────────────────────────────────────────────────

class _MiniMapScrubber extends StatefulWidget {
  final DateTime ganttStart, ganttEnd;
  final double dayWidth;
  final ScrollController hScrollController;
  const _MiniMapScrubber({
    required this.ganttStart,
    required this.ganttEnd,
    required this.dayWidth,
    required this.hScrollController,
  });
  @override
  State<_MiniMapScrubber> createState() => _MiniMapScrubberState();
}

class _MiniMapScrubberState extends State<_MiniMapScrubber> {
  bool _visible = false;

  void _onDrag(DragUpdateDetails d) {
    if (!widget.hScrollController.hasClients) return;
    final totalDays =
        GanttDateUtils.daysBetween(widget.ganttStart, widget.ganttEnd) + 1;
    final totalW = totalDays * widget.dayWidth;
    const scrubberW = 120.0;
    final ratio = totalW / scrubberW;
    final newOffset = (widget.hScrollController.offset + d.delta.dx * ratio)
        .clamp(0.0, widget.hScrollController.position.maxScrollExtent);
    widget.hScrollController.jumpTo(newOffset);
  }

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 6,
        right: 12,
        child: MouseRegion(
          onEnter: (_) => setState(() => _visible = true),
          onExit: (_) => setState(() => _visible = false),
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.28,
            duration: GanttAnimations.fast,
            child: GestureDetector(
              onHorizontalDragUpdate: _onDrag,
              child: Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: GanttTheme.surface3.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GanttTheme.surface4),
                ),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.drag_indicator,
                          size: 10, color: GanttTheme.textMuted),
                      SizedBox(width: 4),
                      Text('Drag to scroll',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              color: GanttTheme.textMuted)),
                    ]),
              ),
            ),
          ),
        ),
      );
}

// ─── Row highlight ─────────────────────────────────────────────────────────────

class _RowHighlight extends ConsumerWidget {
  final Task task;
  final int rowIndex;
  final double rowHeight, totalWidth;
  const _RowHighlight(
      {required this.task,
      required this.rowIndex,
      required this.rowHeight,
      required this.totalWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hovered = ref.watch(hoveredTaskIdProvider) == task.id;
    final selected = ref.watch(selectedTaskIdProvider) == task.id;
    if (!hovered && !selected) return const SizedBox.shrink();
    return Positioned(
      top: rowIndex * rowHeight,
      left: 0,
      width: totalWidth,
      height: rowHeight,
      child: AnimatedContainer(
          duration: GanttAnimations.fast,
          color: selected
              ? GanttTheme.rowSelected.withOpacity(0.5)
              : GanttTheme.rowHover.withOpacity(0.4)),
    );
  }
}

// ─── Dependency layer ──────────────────────────────────────────────────────────

class _DependencyLayer extends StatelessWidget {
  final List<Task> tasks;
  final DateTime ganttStart;
  final double dayWidth, rowHeight;
  final Set<String> criticalIds;
  const _DependencyLayer(
      {required this.tasks,
      required this.ganttStart,
      required this.dayWidth,
      required this.rowHeight,
      required this.criticalIds});

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
        final (fromX, toX) = switch (dep.type) {
          DependencyType.fs => (
              GanttDateUtils.dayOffset(ganttStart, depTask.endDate, dayWidth) +
                  dayWidth,
              GanttDateUtils.dayOffset(ganttStart, task.startDate, dayWidth) +
                  dep.lagDays * dayWidth
            ),
          DependencyType.ss => (
              GanttDateUtils.dayOffset(ganttStart, depTask.startDate, dayWidth),
              GanttDateUtils.dayOffset(ganttStart, task.startDate, dayWidth) +
                  dep.lagDays * dayWidth
            ),
          DependencyType.ff => (
              GanttDateUtils.dayOffset(ganttStart, depTask.endDate, dayWidth) +
                  dayWidth,
              GanttDateUtils.dayOffset(ganttStart, task.endDate, dayWidth) +
                  dayWidth +
                  dep.lagDays * dayWidth
            ),
          DependencyType.sf => (
              GanttDateUtils.dayOffset(ganttStart, depTask.startDate, dayWidth),
              GanttDateUtils.dayOffset(ganttStart, task.endDate, dayWidth) +
                  dayWidth +
                  dep.lagDays * dayWidth
            ),
        };
        arrows.add(DependencyArrow(
          from: Offset(fromX, (depIdx + 0.5) * rowHeight),
          to: Offset(toX, (taskIdx + 0.5) * rowHeight),
          isCritical: criticalIds.contains(task.id) &&
              criticalIds.contains(dep.predecessorId),
          type: dep.type,
        ));
      }
    }
    if (arrows.isEmpty) return const SizedBox.shrink();
    return CustomPaint(painter: DependencyArrowPainter(arrows: arrows));
  }
}

// ─── Today marker ──────────────────────────────────────────────────────────────

class _TodayMarker extends StatelessWidget {
  final DateTime ganttStart;
  final double dayWidth, totalHeight;
  const _TodayMarker(
      {required this.ganttStart,
      required this.dayWidth,
      required this.totalHeight});

  @override
  Widget build(BuildContext context) {
    final x = GanttDateUtils.dayOffset(ganttStart, DateTime.now(), dayWidth) +
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
            BoxShadow(color: GanttTheme.accent.withOpacity(0.3), blurRadius: 6)
          ],
        )));
  }
}

// ─── Collapsed sidebar handle ──────────────────────────────────────────────────

class _CollapsedHandle extends StatelessWidget {
  final VoidCallback onExpand;
  const _CollapsedHandle({required this.onExpand});
  @override
  Widget build(BuildContext context) => Container(
        width: 24,
        decoration: const BoxDecoration(
            color: GanttTheme.surface1,
            border: Border(right: BorderSide(color: GanttTheme.surface4))),
        child: Center(
            child: IconButton(
          icon: const Icon(Icons.chevron_right, size: 14),
          onPressed: onExpand,
          color: GanttTheme.textMuted,
          tooltip: 'Expand sidebar',
          padding: EdgeInsets.zero,
        )),
      );
}
