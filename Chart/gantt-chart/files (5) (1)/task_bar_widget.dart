import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

// ─── Public widget ────────────────────────────────────────────────────────────

class TaskBarWidget extends ConsumerStatefulWidget {
  final Task task;
  final DateTime ganttStart;
  final double dayWidth;
  final double rowHeight;
  final int rowIndex;
  final bool isCritical;
  final bool showBaseline;
  final VoidCallback? onTap;

  const TaskBarWidget({
    super.key,
    required this.task,
    required this.ganttStart,
    required this.dayWidth,
    required this.rowHeight,
    required this.rowIndex,
    this.isCritical = false,
    this.showBaseline = false,
    this.onTap,
  });

  @override
  ConsumerState<TaskBarWidget> createState() => _TaskBarWidgetState();
}

class _TaskBarWidgetState extends ConsumerState<TaskBarWidget>
    with TickerProviderStateMixin {
  // ── Animations ─────────────────────────────────────────────────────────────
  late final AnimationController _hoverCtrl;
  late final AnimationController _entranceCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _elevAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _entranceAnim;
  late final Animation<double> _pulseAnim;

  // ── Drag (move whole bar) ──────────────────────────────────────────────────
  bool _isDragging = false;
  double _dragDeltaX = 0;
  int _dragSnapDays = 0;

  // ── Right-edge resize ──────────────────────────────────────────────────────
  bool _isResizingRight = false;
  double _resizeRightDeltaX = 0;

  // ── Left-edge resize (move start date) ────────────────────────────────────
  bool _isResizingLeft = false;
  double _resizeLeftDeltaX = 0;

  // ── Inline title edit ──────────────────────────────────────────────────────
  bool _editingTitle = false;
  late final TextEditingController _titleCtrl;
  late final FocusNode _titleFocus;

  // ── Hover popover ──────────────────────────────────────────────────────────
  OverlayEntry? _popover;
  bool _hovered = false;

  // ── Helpers ────────────────────────────────────────────────────────────────
  bool get _anyResizing => _isResizingLeft || _isResizingRight;
  bool get _anyDragOrResize => _isDragging || _anyResizing;

  @override
  void initState() {
    super.initState();

    _hoverCtrl = AnimationController(vsync: this, duration: GanttAnimations.fast);
    _elevAnim  = Tween<double>(begin: 0, end: 6)
        .animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.015)
        .animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));

    // Staggered entrance: fade + slide up, capped at 400 ms total stagger
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _entranceAnim = CurvedAnimation(
        parent: _entranceCtrl, curve: Curves.easeOutCubic);
    final staggerMs = math.min(widget.rowIndex * 22, 400);
    Future.delayed(Duration(milliseconds: staggerMs),
        () { if (mounted) _entranceCtrl.forward(); });

    // Deadline pulse – only when task ends today and isn't done
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut);
    if (_isDueToday) _pulseCtrl.repeat(reverse: true);

    _titleCtrl  = TextEditingController(text: widget.task.title);
    _titleFocus = FocusNode()
      ..addListener(() { if (!_titleFocus.hasFocus && _editingTitle) _commitTitle(); });
  }

  @override
  void didUpdateWidget(TaskBarWidget old) {
    super.didUpdateWidget(old);
    if (old.task.endDate != widget.task.endDate ||
        old.task.status  != widget.task.status) {
      _isDueToday ? _pulseCtrl.repeat(reverse: true) : _pulseCtrl.stop();
    }
  }

  @override
  void dispose() {
    _removePopover();
    _hoverCtrl.dispose();
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _titleCtrl.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  bool get _isDueToday =>
      GanttDateUtils.isToday(widget.task.endDate) &&
      widget.task.status != TaskStatus.done;

  // ── Geometry ────────────────────────────────────────────────────────────────
  double get _baseLeft =>
      GanttDateUtils.dayOffset(widget.ganttStart, widget.task.startDate, widget.dayWidth);
  double get _baseWidth =>
      GanttDateUtils.taskBarWidth(widget.task, widget.dayWidth);

  double get _barLeft {
    double l = _baseLeft;
    if (_isDragging)     l += _dragSnapDays * widget.dayWidth;
    if (_isResizingLeft) l += _resizeLeftSnapDays * widget.dayWidth;
    return l;
  }

  double get _barWidth {
    double w = _baseWidth;
    if (_isResizingRight) w += _resizeRightSnapDays * widget.dayWidth;
    if (_isResizingLeft)  w -= _resizeLeftSnapDays  * widget.dayWidth;
    return w.clamp(widget.dayWidth, double.infinity);
  }

  int get _resizeRightSnapDays => (_resizeRightDeltaX / widget.dayWidth).round();
  int get _resizeLeftSnapDays  => (_resizeLeftDeltaX  / widget.dayWidth).round();

  // Effective dates shown in tooltip / committed on drop
  DateTime get _effectiveStart => widget.task.startDate.add(
      Duration(days: (_isDragging ? _dragSnapDays : 0) +
                     (_isResizingLeft ? _resizeLeftSnapDays : 0)));
  DateTime get _effectiveEnd => widget.task.endDate.add(
      Duration(days: (_isDragging     ? _dragSnapDays       : 0) +
                     (_isResizingRight ? _resizeRightSnapDays : 0)));

  // ── Hover / popover ─────────────────────────────────────────────────────────
  void _onEnter(Offset globalPos) {
    _hovered = true;
    ref.read(hoveredTaskIdProvider.notifier).state = widget.task.id;
    _hoverCtrl.forward();
    _schedulePopover(globalPos);
  }

  void _onExit() {
    _hovered = false;
    ref.read(hoveredTaskIdProvider.notifier).state = null;
    _hoverCtrl.reverse();
    _removePopover();
  }

  void _schedulePopover(Offset globalPos) {
    _removePopover();
    Future.delayed(const Duration(milliseconds: 480), () {
      if (!mounted || !_hovered || _anyDragOrResize || _editingTitle) return;
      _popover = _makePopoverEntry(globalPos);
      Overlay.of(context).insert(_popover!);
    });
  }

  void _removePopover() { _popover?.remove(); _popover = null; }

  OverlayEntry _makePopoverEntry(Offset pos) {
    final screen = MediaQuery.sizeOf(context);
    final flipX  = pos.dx > screen.width - 268;
    final left   = flipX ? pos.dx - 256 : pos.dx + 14;
    final top    = (pos.dy - 12).clamp(8.0, screen.height - 260);
    return OverlayEntry(
      builder: (_) => Positioned(
        left: left, top: top,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: GanttAnimations.fast,
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(offset: Offset(0, (1 - v) * 6), child: child),
            ),
            child: Container(
              width: 252,
              decoration: BoxDecoration(
                color: GanttTheme.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GanttTheme.surface4),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 18, offset: Offset(0, 4))],
              ),
              padding: const EdgeInsets.all(14),
              child: _PopoverCard(task: widget.task),
            ),
          ),
        ),
      ),
    );
  }

  // ── Drag ────────────────────────────────────────────────────────────────────
  void _startDrag(DragStartDetails _) {
    _removePopover();
    setState(() { _isDragging = true; _dragDeltaX = 0; _dragSnapDays = 0; });
    ref.read(draggingTaskIdProvider.notifier).state = widget.task.id;
  }

  void _updateDrag(DragUpdateDetails d) => setState(() {
    _dragDeltaX  += d.delta.dx;
    _dragSnapDays = (_dragDeltaX / widget.dayWidth).round();
  });

  void _endDrag(DragEndDetails _) {
    if (_dragSnapDays != 0) {
      ref.read(tasksProvider.notifier).rescheduleTask(
          widget.task.id,
          widget.task.startDate.add(Duration(days: _dragSnapDays)));
    }
    setState(() { _isDragging = false; _dragDeltaX = 0; _dragSnapDays = 0; });
    ref.read(draggingTaskIdProvider.notifier).state = null;
  }

  // ── Right-edge resize ────────────────────────────────────────────────────────
  void _startResizeRight(DragStartDetails _) =>
      setState(() { _isResizingRight = true; _resizeRightDeltaX = 0; });
  void _updateResizeRight(DragUpdateDetails d) =>
      setState(() => _resizeRightDeltaX += d.delta.dx);
  void _endResizeRight(DragEndDetails _) {
    final days   = _resizeRightSnapDays;
    final newEnd = widget.task.endDate.add(Duration(days: days));
    if (newEnd.isAfter(widget.task.startDate)) {
      ref.read(tasksProvider.notifier).resizeTaskEnd(widget.task.id, newEnd);
    }
    setState(() { _isResizingRight = false; _resizeRightDeltaX = 0; });
  }

  // ── Left-edge resize ─────────────────────────────────────────────────────────
  void _startResizeLeft(DragStartDetails _) =>
      setState(() { _isResizingLeft = true; _resizeLeftDeltaX = 0; });
  void _updateResizeLeft(DragUpdateDetails d) =>
      setState(() => _resizeLeftDeltaX += d.delta.dx);
  void _endResizeLeft(DragEndDetails _) {
    final days     = _resizeLeftSnapDays;
    final newStart = widget.task.startDate.add(Duration(days: days));
    if (newStart.isBefore(widget.task.endDate)) {
      ref.read(tasksProvider.notifier).updateTask(
          widget.task.copyWith(startDate: newStart, updatedAt: DateTime.now()));
    }
    setState(() { _isResizingLeft = false; _resizeLeftDeltaX = 0; });
  }

  // ── Inline title edit ────────────────────────────────────────────────────────
  void _startEditing() {
    _removePopover();
    _titleCtrl.text = widget.task.title;
    setState(() => _editingTitle = true);
    Future.delayed(const Duration(milliseconds: 30), () {
      if (!mounted) return;
      _titleFocus.requestFocus();
      _titleCtrl.selection =
          TextSelection(baseOffset: 0, extentOffset: _titleCtrl.text.length);
    });
  }

  void _commitTitle() {
    final t = _titleCtrl.text.trim();
    if (t.isNotEmpty && t != widget.task.title) {
      ref.read(tasksProvider.notifier)
          .updateTask(widget.task.copyWith(title: t, updatedAt: DateTime.now()));
    }
    if (mounted) setState(() => _editingTitle = false);
  }

  // ── Context menu ─────────────────────────────────────────────────────────────
  void _showContextMenu(BuildContext ctx, Offset pos) {
    _removePopover();
    final overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;
    showMenu<String>(
      context: ctx,
      position: RelativeRect.fromRect(
          Rect.fromLTWH(pos.dx, pos.dy, 1, 1), Offset.zero & overlay.size),
      color: const Color(0xFF252D40),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF2E3854))),
      items: [
        _menuItem('edit',      Icons.edit_outlined,     'Rename',          hint: '2× click'),
        _menuItem('detail',    Icons.open_in_new,        'Open Detail'),
        _menuItem('duplicate', Icons.copy_outlined,      'Duplicate'),
        _menuItem('split',     Icons.call_split,         'Split Task'),
        _menuItem('baseline',  Icons.bookmark_outlined,  'Capture Baseline'),
        const PopupMenuDivider(height: 4),
        _menuItem('delete',    Icons.delete_outlined,    'Delete', danger: true),
      ],
    ).then((v) {
      if (v == null) return;
      switch (v) {
        case 'edit':      _startEditing();
        case 'detail':    ref.read(selectedTaskIdProvider.notifier).state = widget.task.id;
        case 'duplicate': ref.read(tasksProvider.notifier).duplicateTask(widget.task.id);
        case 'split':     _showSplitDialog(ctx);
        case 'baseline':
          ref.read(tasksProvider.notifier)
              .setBaseline('Baseline ${DateTime.now().day}/${DateTime.now().month}');
        case 'delete':
          ref.read(tasksProvider.notifier).deleteTask(widget.task.id);
          ref.read(selectedTaskIdProvider.notifier).state = null;
      }
    });
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label,
      {bool danger = false, String? hint}) =>
      PopupMenuItem(value: value, height: 36,
        child: Row(children: [
          Icon(icon, size: 14,
              color: danger ? const Color(0xFFEF4444) : const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Expanded(child: Text(label,
              style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                  color: danger ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9)))),
          if (hint != null)
            Text(hint, style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                color: Color(0xFF475569))),
        ]),
      );

  void _showSplitDialog(BuildContext ctx) {
    final mid = widget.task.startDate.add(Duration(days: widget.task.durationDays ~/ 2));
    showDialog(context: ctx,
        builder: (_) => _SplitDialog(task: widget.task, initialDate: mid,
            onSplit: (d) => ref.read(tasksProvider.notifier).splitTask(widget.task.id, d)));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (widget.task.isMilestone) return _buildMilestone();
    return _buildBar();
  }

  Widget _buildBar() {
    final isSelected = ref.watch(selectedTaskIdProvider) == widget.task.id;
    final task  = widget.task;
    final color = task.displayColor;
    final top   = widget.rowIndex * widget.rowHeight;
    final barH  = widget.rowHeight - 10;

    return FadeTransition(
      opacity: _entranceAnim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(_entranceAnim),
        child: Stack(clipBehavior: Clip.none, children: [
          // Baseline ghost
          if (widget.showBaseline && task.baseline != null)
            _BaselineBar(task: task, ganttStart: widget.ganttStart,
                dayWidth: widget.dayWidth, rowIndex: widget.rowIndex,
                rowHeight: widget.rowHeight),

          // Deadline pulse ring
          if (_isDueToday)
            _DeadlinePulse(left: _barLeft, top: top, width: _barWidth,
                height: barH, color: GanttTheme.warning, anim: _pulseAnim),

          // ── Snap-destination ghost shown while dragging ──────────────────
          if (_isDragging && _dragSnapDays != 0)
            _SnapGhost(left: _baseLeft + _dragSnapDays * widget.dayWidth,
                top: top + 5, width: _baseWidth, height: barH, color: color),

          // ── Main bar ────────────────────────────────────────────────────
          Positioned(
            left: _barLeft, top: top + 5, width: _barWidth, height: barH,
            child: MouseRegion(
              onEnter: (e) => _onEnter(e.position),
              onExit:  (_) => _onExit(),
              cursor: _isDragging
                  ? SystemMouseCursors.grabbing
                  : SystemMouseCursors.grab,
              child: GestureDetector(
                onTap: () { if (!_editingTitle) widget.onTap?.call(); },
                onDoubleTap: _startEditing,
                onSecondaryTapUp:  (d) => _showContextMenu(context, d.globalPosition),
                onLongPressStart:  (d) => _showContextMenu(context, d.globalPosition),
                onHorizontalDragStart:  _startDrag,
                onHorizontalDragUpdate: _updateDrag,
                onHorizontalDragEnd:    _endDrag,
                child: AnimatedBuilder(
                  animation: _hoverCtrl,
                  builder: (_, child) => Transform.scale(
                    scale: _isDragging ? 1.04 : _scaleAnim.value,
                    alignment: Alignment.centerLeft,
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: GanttAnimations.fast,
                    decoration: BoxDecoration(
                      color: color.withOpacity(isSelected ? 1.0 : 0.85),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withOpacity(0.9)
                            : widget.isCritical
                                ? const Color(0xFFEF4444)
                                : color.withOpacity(0.4),
                        width: isSelected || widget.isCritical ? 1.5 : 1.0,
                      ),
                      boxShadow: [BoxShadow(
                        color: color.withOpacity(_isDragging ? 0.55 : 0.2),
                        blurRadius: _isDragging ? 16 : _elevAnim.value,
                        offset: Offset(0, _isDragging ? 6 : 2),
                      )],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(children: [
                        // Progress fill
                        if (task.progress > 0)
                          Positioned.fill(child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: task.progress.clamp(0.0, 1.0),
                            child: Container(color: Colors.white.withOpacity(0.13)),
                          )),

                        // Overdue shimmer
                        if (task.isOverdue) const _OverdueShimmer(),

                        // Label / inline editor
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          child: Row(children: [
                            Expanded(
                              child: _editingTitle
                                  ? TextField(
                                      controller: _titleCtrl,
                                      focusNode:  _titleFocus,
                                      style: const TextStyle(fontFamily: 'Inter',
                                          fontSize: 11, fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                      decoration: const InputDecoration.collapsed(
                                          hintText: 'Task name'),
                                      onSubmitted: (_) => _commitTitle(),
                                    )
                                  : Text(task.title,
                                      style: const TextStyle(fontFamily: 'Inter',
                                          fontSize: 11, fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                            if (task.checklist.isNotEmpty && _barWidth > 100)
                              _ChecklistBadge(progress: task.checklistProgress),
                            if (task.assignees.isNotEmpty && _barWidth > 80)
                              _AssigneeStack(assignees: task.assignees),
                          ]),
                        ),

                        // Critical path accent strip
                        if (widget.isCritical)
                          Positioned(left: 0, top: 0, bottom: 0, width: 3,
                            child: Container(decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    bottomLeft: Radius.circular(5))))),

                        // Risk dot
                        if (task.riskLevel != RiskLevel.none)
                          Positioned(top: 3, right: 12,
                            child: Container(width: 5, height: 5,
                                decoration: BoxDecoration(
                                    color: task.riskLevel.color,
                                    shape: BoxShape.circle))),

                        // ── LEFT resize handle ──────────────────────────────
                        Positioned(left: 0, top: 0, bottom: 0, width: 8,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.resizeColumn,
                            child: GestureDetector(
                              onHorizontalDragStart:  _startResizeLeft,
                              onHorizontalDragUpdate: _updateResizeLeft,
                              onHorizontalDragEnd:    _endResizeLeft,
                              child: Container(decoration: const BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomLeft: Radius.circular(5)))),
                            ),
                          )),

                        // ── RIGHT resize handle ─────────────────────────────
                        Positioned(right: 0, top: 0, bottom: 0, width: 8,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.resizeColumn,
                            child: GestureDetector(
                              onHorizontalDragStart:  _startResizeRight,
                              onHorizontalDragUpdate: _updateResizeRight,
                              onHorizontalDragEnd:    _endResizeRight,
                              child: Container(decoration: const BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(5),
                                      bottomRight: Radius.circular(5)))),
                            ),
                          )),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Floating date tooltip during any drag or resize ──────────────
          if (_anyDragOrResize)
            _DateTooltip(
              barLeft: _barLeft, barWidth: _barWidth, barTop: top + 5,
              newStart: _effectiveStart, newEnd: _effectiveEnd,
            ),
        ]),
      ),
    );
  }

  Widget _buildMilestone() {
    final isSelected = ref.watch(selectedTaskIdProvider) == widget.task.id;
    final color = widget.task.displayColor;
    final top   = widget.rowIndex * widget.rowHeight;
    final sz    = widget.rowHeight - 16;
    final cx    = _barLeft + widget.dayWidth / 2;
    final cy    = top + widget.rowHeight / 2;

    return FadeTransition(
      opacity: _entranceAnim,
      child: Positioned(
        left: cx - sz / 2, top: cy - sz / 2, width: sz, height: sz,
        child: MouseRegion(
          onEnter: (e) => _onEnter(e.position),
          onExit:  (_) => _onExit(),
          child: GestureDetector(
            onTap: widget.onTap,
            onDoubleTap: _startEditing,
            onSecondaryTapUp: (d) => _showContextMenu(context, d.globalPosition),
            child: AnimatedBuilder(
              animation: Listenable.merge([_hoverCtrl, _pulseCtrl]),
              builder: (_, child) => Transform.rotate(
                angle: 0.785398,
                child: Stack(children: [
                  if (_isDueToday)
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: GanttTheme.warning
                              .withOpacity((1 - _pulseAnim.value) * 0.8),
                          width: 2 + _pulseAnim.value * 5,
                        ),
                      ),
                    )),
                  AnimatedContainer(
                    duration: GanttAnimations.fast,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                          color: isSelected ? Colors.white : color.withOpacity(0.6),
                          width: isSelected ? 2 : 1.5),
                      boxShadow: [BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: _hoverCtrl.value * 12 + 4,
                          spreadRadius: _hoverCtrl.value * 2)],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Snap ghost ───────────────────────────────────────────────────────────────

class _SnapGhost extends StatelessWidget {
  final double left, top, width, height;
  final Color color;
  const _SnapGhost({required this.left, required this.top,
      required this.width, required this.height, required this.color});

  @override
  Widget build(BuildContext context) => Positioned(
    left: left, top: top, width: width, height: height,
    child: IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withOpacity(0.55), width: 1.5),
        ),
      ),
    ),
  );
}

// ─── Floating date tooltip ─────────────────────────────────────────────────────

class _DateTooltip extends StatelessWidget {
  final double barLeft, barWidth, barTop;
  final DateTime newStart, newEnd;
  const _DateTooltip({required this.barLeft, required this.barWidth,
      required this.barTop, required this.newStart, required this.newEnd});

  @override
  Widget build(BuildContext context) {
    const w = 186.0;
    final label =
        '${GanttDateUtils.formatShortDate(newStart)}  →  ${GanttDateUtils.formatShortDate(newEnd)}';
    return Positioned(
      left: barLeft + barWidth / 2 - w / 2,
      top:  barTop - 34,
      child: IgnorePointer(
        child: Container(
          width: w,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: GanttTheme.surface3,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: GanttTheme.accent.withOpacity(0.5)),
            boxShadow: const [BoxShadow(
                color: Colors.black38, blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                  fontWeight: FontWeight.w600, color: GanttTheme.textPrimary)),
        ),
      ),
    );
  }
}

// ─── Deadline pulse ring ───────────────────────────────────────────────────────

class _DeadlinePulse extends StatelessWidget {
  final double left, top, width, height;
  final Color color;
  final Animation<double> anim;
  const _DeadlinePulse({required this.left, required this.top,
      required this.width, required this.height,
      required this.color, required this.anim});

  @override
  Widget build(BuildContext context) => Positioned(
    left: left - 3, top: top + 2, width: width + 6, height: height - 4,
    child: IgnorePointer(
      child: AnimatedBuilder(
        animation: anim,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: color.withOpacity(0.75 * (1 - anim.value)),
              width: 1.5 + anim.value * 3.5,
            ),
          ),
        ),
      ),
    ),
  );
}

// ─── Rich popover card ─────────────────────────────────────────────────────────

class _PopoverCard extends StatelessWidget {
  final Task task;
  const _PopoverCard({required this.task});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Title + status dot
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(width: 8, height: 8,
              decoration: BoxDecoration(
                  color: task.isMilestone ? task.displayColor : task.status.color,
                  shape: BoxShape.circle)),
        ),
        const SizedBox(width: 7),
        Expanded(child: Text(task.title,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                fontWeight: FontWeight.w600, color: GanttTheme.textPrimary),
            maxLines: 2)),
      ]),
      const SizedBox(height: 10),
      const Divider(color: GanttTheme.surface4, height: 1),
      const SizedBox(height: 10),

      // Dates
      _PopRow(Icons.calendar_today_outlined,
          '${GanttDateUtils.formatShortDate(task.startDate)} – ${GanttDateUtils.formatShortDate(task.endDate)}',
          sub: GanttDateUtils.durationLabel(task)),

      // Progress bar
      const SizedBox(height: 8),
      Row(children: [
        const Icon(Icons.trending_up, size: 12, color: GanttTheme.textMuted),
        const SizedBox(width: 6),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${(task.progress * 100).toInt()}% complete',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: GanttTheme.textSecondary)),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: task.progress, backgroundColor: GanttTheme.surface4,
              color: task.status.color, minHeight: 4,
            ),
          ),
        ])),
      ]),

      // Estimated hours
      if (task.estimatedHours > 0) ...[
        const SizedBox(height: 6),
        _PopRow(Icons.schedule_outlined,
            '${task.estimatedHours.toStringAsFixed(0)}h estimated',
            sub: task.actualHours > 0
                ? '${task.actualHours.toStringAsFixed(0)}h logged' : null),
      ],

      // Assignees
      if (task.assignees.isNotEmpty) ...[
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.person_outline, size: 12, color: GanttTheme.textMuted),
          const SizedBox(width: 6),
          Wrap(spacing: 4, children: task.assignees.take(4).map((a) =>
            Container(width: 20, height: 20,
              decoration: BoxDecoration(color: a.avatarColor, shape: BoxShape.circle,
                  border: Border.all(color: GanttTheme.surface2, width: 1.5)),
              child: Center(child: Text(a.initials.substring(0, 1),
                  style: const TextStyle(fontSize: 8,
                      fontWeight: FontWeight.w700, color: Colors.white))),
            )).toList()),
        ]),
      ],

      // Badges row
      const SizedBox(height: 10),
      Wrap(spacing: 6, runSpacing: 4, children: [
        _PBadge(label: task.priority.label, color: task.priority.color,
            icon: task.priority.icon),
        if (task.riskLevel != RiskLevel.none)
          _PBadge(label: task.riskLevel.label, color: task.riskLevel.color,
              icon: Icons.warning_amber_rounded),
        if (task.labels.isNotEmpty)
          _PBadge(label: task.labels.first, color: GanttTheme.accent,
              icon: Icons.label_outline),
      ]),

      // Overdue alert
      if (task.isOverdue) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: GanttTheme.danger.withOpacity(0.12),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: GanttTheme.danger.withOpacity(0.35)),
          ),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded, size: 11, color: GanttTheme.danger),
            const SizedBox(width: 5),
            Text(
              'Overdue by ${DateTime.now().difference(task.endDate).inDays}d',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
                  color: GanttTheme.danger, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
      ],

      // Hint
      const SizedBox(height: 9),
      const Text('2× click to rename  ·  right-click for options',
          style: TextStyle(fontFamily: 'Inter', fontSize: 9,
              color: GanttTheme.textDisabled)),
    ],
  );
}

class _PopRow extends StatelessWidget {
  final IconData icon; final String text; final String? sub;
  const _PopRow(this.icon, this.text, {this.sub});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 12, color: GanttTheme.textMuted),
      const SizedBox(width: 6),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 10,
              color: GanttTheme.textSecondary)),
          if (sub != null)
            Text(sub!, style: const TextStyle(fontFamily: 'Inter', fontSize: 9,
                color: GanttTheme.textMuted)),
        ])),
    ],
  );
}

class _PBadge extends StatelessWidget {
  final String label; final Color color; final IconData icon;
  const _PBadge({required this.label, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
        color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 9, color: color), const SizedBox(width: 3),
      Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 9,
          fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}

// ─── Baseline ghost bar ────────────────────────────────────────────────────────

class _BaselineBar extends StatelessWidget {
  final Task task;
  final DateTime ganttStart;
  final double dayWidth;
  final int rowIndex;
  final double rowHeight;
  const _BaselineBar({required this.task, required this.ganttStart,
      required this.dayWidth, required this.rowIndex, required this.rowHeight});

  @override
  Widget build(BuildContext context) {
    final b     = task.baseline!;
    final left  = GanttDateUtils.dayOffset(ganttStart, b.startDate, dayWidth);
    final width = ((b.endDate.difference(b.startDate).inDays + 1) * dayWidth)
        .clamp(dayWidth, double.infinity);
    final top   = rowIndex * rowHeight + rowHeight - 9;
    return Positioned(
      left: left, top: top, width: width, height: 5,
      child: Tooltip(
        message: 'Baseline: ${GanttDateUtils.formatShortDate(b.startDate)} – '
            '${GanttDateUtils.formatShortDate(b.endDate)}\n${b.label}',
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF94A3B8).withOpacity(0.35),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
                color: const Color(0xFF94A3B8).withOpacity(0.6), width: 0.5),
          ),
        ),
      ),
    );
  }
}

// ─── Micro helpers ─────────────────────────────────────────────────────────────

class _AssigneeStack extends StatelessWidget {
  final List<Assignee> assignees;
  const _AssigneeStack({required this.assignees});
  @override
  Widget build(BuildContext context) {
    final shown = assignees.take(2).toList();
    return SizedBox(
      width: shown.length * 10.0 + 10, height: 18,
      child: Stack(children: shown.asMap().entries.map((e) => Positioned(
        left: e.key * 10.0,
        child: Container(width: 16, height: 16,
          decoration: BoxDecoration(color: e.value.avatarColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)),
          child: Center(child: Text(e.value.initials[0],
              style: const TextStyle(fontSize: 8,
                  fontWeight: FontWeight.w700, color: Colors.white)))),
      )).toList()),
    );
  }
}

class _ChecklistBadge extends StatelessWidget {
  final double progress;
  const _ChecklistBadge({required this.progress});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 4),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3)),
    child: Text('${(progress * 100).toInt()}%',
        style: const TextStyle(fontFamily: 'Inter', fontSize: 8,
            fontWeight: FontWeight.w600, color: Colors.white)),
  );
}

class _OverdueShimmer extends StatelessWidget {
  const _OverdueShimmer();
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Container(decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
        Colors.transparent,
        const Color(0xFFEF4444).withOpacity(0.15),
        Colors.transparent,
      ], stops: const [0, 0.5, 1]),
    )),
  );
}

// ─── Split dialog ──────────────────────────────────────────────────────────────

class _SplitDialog extends StatefulWidget {
  final Task task; final DateTime initialDate; final void Function(DateTime) onSplit;
  const _SplitDialog({required this.task, required this.initialDate, required this.onSplit});
  @override State<_SplitDialog> createState() => _SplitDialogState();
}

class _SplitDialogState extends State<_SplitDialog> {
  late DateTime _splitDate;
  @override void initState() { super.initState(); _splitDate = widget.initialDate; }

  Future<void> _pick() async {
    final p = await showDatePicker(
      context: context, initialDate: _splitDate,
      firstDate: widget.task.startDate.add(const Duration(days: 1)),
      lastDate:  widget.task.endDate.subtract(const Duration(days: 1)),
      builder: (ctx, child) => Theme(data: GanttTheme.dark, child: child!),
    );
    if (p != null) setState(() => _splitDate = p);
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: const Color(0xFF1C2333),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2E3854))),
    child: Padding(padding: const EdgeInsets.all(24), child: SizedBox(width: 340,
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Split Task', style: TextStyle(fontFamily: 'Inter',
            fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFF1F5F9))),
        const SizedBox(height: 8),
        Text('Splitting "${widget.task.title}" at:',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                color: Color(0xFF94A3B8))),
        const SizedBox(height: 16),
        InkWell(onTap: _pick,
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Split Date',
                suffixIcon: Icon(Icons.calendar_today, size: 14)),
            child: Text(GanttDateUtils.formatShortDate(_splitDate),
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
                    color: Color(0xFFF1F5F9))),
          )),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: () { widget.onSplit(_splitDate); Navigator.pop(context); },
              child: const Text('Split')),
        ]),
      ]))),
  );
}
