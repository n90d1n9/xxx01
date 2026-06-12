import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

bool _isGroupHeader(Task t) => t.customFields['__isGroupHeader'] == true;

class TaskBarWidget extends ConsumerStatefulWidget {
  final Task task;
  final DateTime ganttStart;
  final double dayWidth;
  final double rowHeight;
  final int rowIndex;
  final bool isCritical;
  final bool showBaseline;
  final bool isMultiSelected;
  final VoidCallback? onTap;
  final void Function(Offset globalPos)? onHover;
  final VoidCallback? onHoverEnd;

  const TaskBarWidget({
    super.key,
    required this.task,
    required this.ganttStart,
    required this.dayWidth,
    required this.rowHeight,
    required this.rowIndex,
    this.isCritical = false,
    this.showBaseline = false,
    this.isMultiSelected = false,
    this.onTap,
    this.onHover,
    this.onHoverEnd,
  });

  @override
  ConsumerState<TaskBarWidget> createState() => _TaskBarWidgetState();
}

class _TaskBarWidgetState extends ConsumerState<TaskBarWidget>
    with TickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late AnimationController _entranceCtrl;
  late Animation<double> _elevAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _entranceFade;
  late Animation<Offset> _entranceSlide;

  bool _isDragging = false;
  bool _isResizingRight = false;
  bool _isResizingLeft = false;
  double _dragDeltaX = 0;
  double _resizeRightDeltaX = 0;
  double _resizeLeftDeltaX = 0;
  bool _editingTitle = false;
  late TextEditingController _titleEditCtrl;

  @override
  void initState() {
    super.initState();
    _hoverCtrl =
        AnimationController(vsync: this, duration: GanttAnimations.fast);
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));

    _elevAnim = Tween<double>(begin: 0, end: 6)
        .animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02)
        .animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));
    _entranceFade =
        CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    _titleEditCtrl = TextEditingController(text: widget.task.title);

    // Staggered entrance
    Future.delayed(Duration(milliseconds: widget.rowIndex * 18), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void didUpdateWidget(TaskBarWidget old) {
    super.didUpdateWidget(old);
    if (old.task.title != widget.task.title) {
      _titleEditCtrl.text = widget.task.title;
    }
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    _entranceCtrl.dispose();
    _titleEditCtrl.dispose();
    super.dispose();
  }

  // ── Computed geometry ───────────────────────────────────────────────────────

  double get _baseLeft => GanttDateUtils.dayOffset(
      widget.ganttStart, widget.task.startDate, widget.dayWidth);
  double get _baseWidth =>
      GanttDateUtils.taskBarWidth(widget.task, widget.dayWidth);

  double get _barLeft {
    if (_isDragging) {
      // Snap to nearest day
      final snappedDays = (_dragDeltaX / widget.dayWidth).round();
      return _baseLeft + snappedDays * widget.dayWidth;
    }
    if (_isResizingLeft) {
      final snappedDays = (_resizeLeftDeltaX / widget.dayWidth).round();
      return (_baseLeft + snappedDays * widget.dayWidth)
          .clamp(0, _baseLeft + _baseWidth - widget.dayWidth);
    }
    return _baseLeft;
  }

  double get _barWidth {
    if (_isResizingRight) {
      final snappedDays = (_resizeRightDeltaX / widget.dayWidth).round();
      return (_baseWidth + snappedDays * widget.dayWidth)
          .clamp(widget.dayWidth, double.infinity);
    }
    if (_isResizingLeft) {
      final snappedDays = (_resizeLeftDeltaX / widget.dayWidth).round();
      return (_baseWidth - snappedDays * widget.dayWidth)
          .clamp(widget.dayWidth, double.infinity);
    }
    return _baseWidth;
  }

  // Snapped dates for tooltip during drag
  DateTime get _draggedStart {
    final days = (_dragDeltaX / widget.dayWidth).round();
    return widget.task.startDate.add(Duration(days: days));
  }

  DateTime get _draggedEnd {
    final days = (_dragDeltaX / widget.dayWidth).round();
    return widget.task.endDate.add(Duration(days: days));
  }

  DateTime get _resizeEnd {
    final days = (_resizeRightDeltaX / widget.dayWidth).round();
    return widget.task.endDate.add(Duration(days: days));
  }

  DateTime get _resizeStart {
    final days = (_resizeLeftDeltaX / widget.dayWidth).round();
    return widget.task.startDate.add(Duration(days: days));
  }

  // ── Hover ───────────────────────────────────────────────────────────────────
  void _onEnter(PointerEnterEvent ev) {
    ref.read(hoveredTaskIdProvider.notifier).state = widget.task.id;
    _hoverCtrl.forward();
    widget.onHover?.call(ev.position);
  }

  void _onExit(PointerExitEvent ev) {
    ref.read(hoveredTaskIdProvider.notifier).state = null;
    _hoverCtrl.reverse();
    widget.onHoverEnd?.call();
  }

  // ── Drag (move) ─────────────────────────────────────────────────────────────
  void _startDrag(DragStartDetails _) {
    if (widget.task.isLocked) return;
    setState(() {
      _isDragging = true;
      _dragDeltaX = 0;
    });
    ref.read(draggingTaskIdProvider.notifier).state = widget.task.id;
  }

  void _updateDrag(DragUpdateDetails d) {
    if (!_isDragging) return;
    setState(() => _dragDeltaX += d.delta.dx);
  }

  void _endDrag(DragEndDetails _) {
    if (!_isDragging) return;
    final days = (_dragDeltaX / widget.dayWidth).round();
    ref.read(tasksProvider.notifier).rescheduleTask(
        widget.task.id, widget.task.startDate.add(Duration(days: days)));
    setState(() {
      _isDragging = false;
      _dragDeltaX = 0;
    });
    ref.read(draggingTaskIdProvider.notifier).state = null;
  }

  // ── Resize right (end date) ─────────────────────────────────────────────────
  void _startResizeRight(DragStartDetails _) {
    setState(() {
      _isResizingRight = true;
      _resizeRightDeltaX = 0;
    });
  }

  void _updateResizeRight(DragUpdateDetails d) {
    setState(() => _resizeRightDeltaX += d.delta.dx);
  }

  void _endResizeRight(DragEndDetails _) {
    final days = (_resizeRightDeltaX / widget.dayWidth).round();
    ref.read(tasksProvider.notifier).resizeTaskEnd(
        widget.task.id, widget.task.endDate.add(Duration(days: days)));
    setState(() {
      _isResizingRight = false;
      _resizeRightDeltaX = 0;
    });
  }

  // ── Resize left (start date) ────────────────────────────────────────────────
  void _startResizeLeft(DragStartDetails _) {
    setState(() {
      _isResizingLeft = true;
      _resizeLeftDeltaX = 0;
    });
  }

  void _updateResizeLeft(DragUpdateDetails d) {
    setState(() => _resizeLeftDeltaX += d.delta.dx);
  }

  void _endResizeLeft(DragEndDetails _) {
    final days = (_resizeLeftDeltaX / widget.dayWidth).round();
    ref.read(tasksProvider.notifier).resizeTaskStart(
        widget.task.id, widget.task.startDate.add(Duration(days: days)));
    setState(() {
      _isResizingLeft = false;
      _resizeLeftDeltaX = 0;
    });
  }

  // ── Context menu ────────────────────────────────────────────────────────────
  void _showContextMenu(BuildContext ctx, Offset globalPos) {
    final overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;
    final task = widget.task;
    showMenu<String>(
      context: ctx,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPos.dx, globalPos.dy, 1, 1),
        Offset.zero & overlay.size,
      ),
      color: const Color(0xFF252D40),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF2E3854))),
      items: [
        _menuItem('edit', Icons.edit_outlined, 'Edit Task'),
        _menuItem('inline', Icons.text_fields, 'Rename (inline)'),
        _menuItem('duplicate', Icons.copy_outlined, 'Duplicate'),
        _menuItem('split', Icons.call_split, 'Split Task'),
        if (task.isLocked)
          _menuItem('unlock', Icons.lock_open_outlined, 'Unlock Task')
        else
          _menuItem('lock', Icons.lock_outlined, 'Lock Task'),
        _menuItem('constraint', Icons.lock_clock_outlined, 'Set Constraint…'),
        _menuItem('baseline', Icons.bookmark_outlined, 'Set Baseline'),
        const PopupMenuDivider(height: 4),
        _menuItem('delete', Icons.delete_outlined, 'Delete', danger: true),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'edit':
          ref.read(selectedTaskIdProvider.notifier).state = task.id;
        case 'inline':
          setState(() {
            _editingTitle = true;
            _titleEditCtrl.text = task.title;
          });
        case 'duplicate':
          ref.read(tasksProvider.notifier).duplicateTask(task.id);
        case 'split':
          _showSplitDialog(ctx);
        case 'lock':
        case 'unlock':
          ref.read(tasksProvider.notifier).toggleLock(task.id);
        case 'constraint':
          _showConstraintDialog(ctx);
        case 'baseline':
          ref.read(tasksProvider.notifier).setBaseline(
              'Baseline ${DateTime.now().day}/${DateTime.now().month}');
        case 'delete':
          ref.read(tasksProvider.notifier).deleteTask(task.id);
          ref.read(selectedTaskIdProvider.notifier).state = null;
      }
    });
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label,
          {bool danger = false}) =>
      PopupMenuItem(
        value: value,
        height: 36,
        child: Row(children: [
          Icon(icon,
              size: 14,
              color:
                  danger ? const Color(0xFFEF4444) : const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: danger
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFF1F5F9))),
        ]),
      );

  void _showSplitDialog(BuildContext ctx) {
    final mid = widget.task.startDate
        .add(Duration(days: widget.task.durationDays ~/ 2));
    showDialog(
        context: ctx,
        builder: (_) => _SplitDialog(
              task: widget.task,
              initialDate: mid,
              onSplit: (d) =>
                  ref.read(tasksProvider.notifier).splitTask(widget.task.id, d),
            ));
  }

  void _showConstraintDialog(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (_) => _ConstraintDialog(
              task: widget.task,
              onSave: (c, d) => ref
                  .read(tasksProvider.notifier)
                  .setTaskConstraint(widget.task.id, c, d),
            ));
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isGroupHeader(widget.task)) return _buildGroupHeader();
    if (widget.task.isMilestone) return _buildMilestone();
    return _buildBar();
  }

  Widget _buildGroupHeader() {
    return Positioned(
      left: 0,
      top: widget.rowIndex * widget.rowHeight,
      width: double.infinity,
      height: widget.rowHeight,
      child: IgnorePointer(
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: GanttTheme.surface2.withOpacity(0.85),
            border: const Border(
                bottom: BorderSide(color: GanttTheme.surface4),
                top: BorderSide(color: GanttTheme.surface4)),
          ),
          child: Row(children: [
            const Icon(Icons.view_column_outlined,
                size: 13, color: GanttTheme.textMuted),
            const SizedBox(width: 8),
            Text(widget.task.title,
                style: GanttTheme.headerLabel
                    .copyWith(color: GanttTheme.textSecondary)),
          ]),
        ),
      ),
    );
  }

  Widget _buildBar() {
    final selectedId = ref.watch(selectedTaskIdProvider);
    final isSelected = selectedId == widget.task.id;
    final task = widget.task;
    final color = task.displayColor;
    final top = widget.rowIndex * widget.rowHeight;
    final barH = widget.rowHeight - 10;
    final isLocked = task.isLocked;

    return FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: Stack(children: [
          // Baseline ghost
          if (widget.showBaseline && task.baseline != null)
            _BaselineBar(
                task: task,
                ganttStart: widget.ganttStart,
                dayWidth: widget.dayWidth,
                rowIndex: widget.rowIndex,
                rowHeight: widget.rowHeight),

          // Main bar
          Positioned(
            left: _barLeft,
            top: top + 5,
            width: _barWidth,
            height: barH,
            child: MouseRegion(
              onEnter: _onEnter,
              onExit: _onExit,
              cursor: isLocked
                  ? SystemMouseCursors.forbidden
                  : _isDragging
                      ? SystemMouseCursors.grabbing
                      : SystemMouseCursors.grab,
              child: GestureDetector(
                onTap: widget.onTap,
                onDoubleTap: () => setState(() {
                  _editingTitle = true;
                  _titleEditCtrl.text = task.title;
                }),
                onSecondaryTapUp: (d) =>
                    _showContextMenu(context, d.globalPosition),
                onLongPressStart: (d) =>
                    _showContextMenu(context, d.globalPosition),
                onHorizontalDragStart: _startDrag,
                onHorizontalDragUpdate: _updateDrag,
                onHorizontalDragEnd: _endDrag,
                child: AnimatedBuilder(
                  animation: _hoverCtrl,
                  builder: (_, child) => Transform.scale(
                    scale: _isDragging ? 1.03 : _scaleAnim.value,
                    alignment: Alignment.centerLeft,
                    child: child,
                  ),
                  child: AnimatedContainer(
                    duration: GanttAnimations.fast,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? color.withOpacity(0.5)
                          : color.withOpacity(isSelected ? 1.0 : 0.85),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: isLocked
                            ? GanttTheme.textMuted
                            : isSelected
                                ? Colors.white.withOpacity(0.9)
                                : widget.isCritical
                                    ? const Color(0xFFEF4444)
                                    : color.withOpacity(0.4),
                        width: isSelected || widget.isCritical ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(_isDragging ? 0.5 : 0.2),
                          blurRadius: _isDragging ? 12 : _elevAnim.value,
                          offset: Offset(0, _isDragging ? 4 : 2),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(children: [
                        // Progress fill
                        if (task.progress > 0)
                          Positioned.fill(
                              child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: task.progress.clamp(0.0, 1.0),
                            child: Container(
                                color: Colors.white.withOpacity(0.15)),
                          )),

                        // Overdue shimmer
                        if (task.isOverdue) _OverdueShimmer(),

                        // Label / inline editor
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          child: Row(children: [
                            // Lock icon
                            if (isLocked) ...[
                              const Icon(Icons.lock_outlined,
                                  size: 10, color: Colors.white54),
                              const SizedBox(width: 4),
                            ],
                            // Constraint icon
                            if (task.constraint != TaskConstraint.asap) ...[
                              Icon(task.constraint.icon,
                                  size: 10, color: Colors.white70),
                              const SizedBox(width: 4),
                            ],
                            // Recurring icon
                            if (task.isRecurring ||
                                task.isRecurringInstance) ...[
                              const Icon(Icons.repeat,
                                  size: 10, color: Colors.white70),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: _editingTitle
                                  ? _InlineTitleEditor(
                                      controller: _titleEditCtrl,
                                      onDone: (v) {
                                        if (v.isNotEmpty) {
                                          ref
                                              .read(tasksProvider.notifier)
                                              .updateTask(task.copyWith(
                                                  title: v,
                                                  updatedAt: DateTime.now()));
                                        }
                                        setState(() => _editingTitle = false);
                                      },
                                    )
                                  : Text(task.title,
                                      style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                            ),
                            if (task.checklist.isNotEmpty && _barWidth > 100)
                              _ChecklistBadge(progress: task.checklistProgress),
                            if (task.assignees.isNotEmpty && _barWidth > 80)
                              _AssigneeStack(assignees: task.assignees),
                          ]),
                        ),

                        // Critical path accent
                        if (widget.isCritical)
                          Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: 3,
                              child: Container(
                                  decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5))))),

                        // Risk dot
                        if (task.riskLevel != RiskLevel.none)
                          Positioned(
                              top: 3,
                              right: 12,
                              child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                      color: task.riskLevel.color,
                                      shape: BoxShape.circle))),

                        // Left resize handle
                        if (!isLocked)
                          Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: 8,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.resizeColumn,
                                child: GestureDetector(
                                  onHorizontalDragStart: _startResizeLeft,
                                  onHorizontalDragUpdate: _updateResizeLeft,
                                  onHorizontalDragEnd: _endResizeLeft,
                                  child: Container(color: Colors.transparent),
                                ),
                              )),

                        // Right resize handle
                        if (!isLocked)
                          Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: 8,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.resizeColumn,
                                child: GestureDetector(
                                  onHorizontalDragStart: _startResizeRight,
                                  onHorizontalDragUpdate: _updateResizeRight,
                                  onHorizontalDragEnd: _endResizeRight,
                                  child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.white12,
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(5),
                                              bottomRight:
                                                  Radius.circular(5)))),
                                ),
                              )),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating date tooltip during drag
          if (_isDragging)
            _DragTooltip(
              left: _barLeft + _barWidth / 2 - 80,
              top: top - 26,
              text:
                  '${GanttDateUtils.formatShortDate(_draggedStart)} → ${GanttDateUtils.formatShortDate(_draggedEnd)}',
            ),

          // Floating date tooltip during right resize
          if (_isResizingRight)
            _DragTooltip(
              left: _barLeft + _barWidth - 80,
              top: top - 26,
              text: 'End: ${GanttDateUtils.formatShortDate(_resizeEnd)}',
            ),

          // Floating date tooltip during left resize
          if (_isResizingLeft)
            _DragTooltip(
              left: _barLeft - 80,
              top: top - 26,
              text: 'Start: ${GanttDateUtils.formatShortDate(_resizeStart)}',
            ),
        ]),
      ),
    );
  }

  Widget _buildMilestone() {
    final selectedId = ref.watch(selectedTaskIdProvider);
    final isSelected = selectedId == widget.task.id;
    final color = widget.task.displayColor;
    final top = widget.rowIndex * widget.rowHeight;
    final sz = widget.rowHeight - 16;
    final cx = _baseLeft + widget.dayWidth / 2;
    final cy = top + widget.rowHeight / 2;

    return FadeTransition(
      opacity: _entranceFade,
      child: Positioned(
        left: cx - sz / 2,
        top: cy - sz / 2,
        width: sz,
        height: sz,
        child: MouseRegion(
          onEnter: _onEnter,
          onExit: _onExit,
          child: GestureDetector(
            onTap: widget.onTap,
            onSecondaryTapUp: (d) =>
                _showContextMenu(context, d.globalPosition),
            child: AnimatedBuilder(
              animation: _hoverCtrl,
              builder: (_, child) =>
                  Transform.rotate(angle: 0.785398, child: child),
              child: AnimatedContainer(
                duration: GanttAnimations.fast,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                      color: isSelected ? Colors.white : color.withOpacity(0.6),
                      width: isSelected ? 2 : 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: _hoverCtrl.value * 10 + 4,
                        spreadRadius: _hoverCtrl.value * 2)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Inline Title Editor ───────────────────────────────────────────────────────
class _InlineTitleEditor extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onDone;
  const _InlineTitleEditor({required this.controller, required this.onDone});
  @override
  State<_InlineTitleEditor> createState() => _InlineTitleEditorState();
}

class _InlineTitleEditorState extends State<_InlineTitleEditor> {
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    _focus.requestFocus();
    _focus.addListener(() {
      if (!_focus.hasFocus) widget.onDone(widget.controller.text);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: widget.controller,
        focusNode: _focus,
        style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white),
        decoration: const InputDecoration.collapsed(
            hintText: '', fillColor: Colors.transparent),
        onSubmitted: widget.onDone,
      );
}

// ─── Drag tooltip ─────────────────────────────────────────────────────────────
class _DragTooltip extends StatelessWidget {
  final double left, top;
  final String text;
  const _DragTooltip(
      {required this.left, required this.top, required this.text});
  @override
  Widget build(BuildContext context) => Positioned(
        left: left.clamp(0.0, double.infinity),
        top: top.clamp(0.0, double.infinity),
        child: IgnorePointer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: GanttTheme.surface3,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: GanttTheme.accent.withOpacity(0.5)),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8)
              ],
            ),
            child: Text(text,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: GanttTheme.textPrimary)),
          ),
        ),
      );
}

// ─── Baseline ghost bar ────────────────────────────────────────────────────────
class _BaselineBar extends StatelessWidget {
  final Task task;
  final DateTime ganttStart;
  final double dayWidth;
  final int rowIndex;
  final double rowHeight;
  const _BaselineBar(
      {required this.task,
      required this.ganttStart,
      required this.dayWidth,
      required this.rowIndex,
      required this.rowHeight});
  @override
  Widget build(BuildContext context) {
    final b = task.baseline!;
    final left = GanttDateUtils.dayOffset(ganttStart, b.startDate, dayWidth);
    final width = ((b.endDate.difference(b.startDate).inDays + 1) * dayWidth)
        .clamp(dayWidth, double.infinity);
    final top = rowIndex * rowHeight + rowHeight - 9;
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: 5,
      child: Tooltip(
        message:
            'Baseline: ${GanttDateUtils.formatShortDate(b.startDate)} – ${GanttDateUtils.formatShortDate(b.endDate)}\n${b.label}',
        child: Container(
            decoration: BoxDecoration(
          color: const Color(0xFF94A3B8).withOpacity(0.35),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
              color: const Color(0xFF94A3B8).withOpacity(0.6), width: 0.5),
        )),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _AssigneeStack extends StatelessWidget {
  final List<Assignee> assignees;
  const _AssigneeStack({required this.assignees});
  @override
  Widget build(BuildContext context) {
    final shown = assignees.take(2).toList();
    return SizedBox(
        width: shown.length * 10.0 + 10,
        height: 18,
        child: Stack(
            children: shown
                .asMap()
                .entries
                .map((e) => Positioned(
                      left: e.key * 10.0,
                      child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                              color: e.value.avatarColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1)),
                          child: Center(
                              child: Text(e.value.initials[0],
                                  style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)))),
                    ))
                .toList()));
  }
}

class _ChecklistBadge extends StatelessWidget {
  final double progress;
  const _ChecklistBadge({required this.progress});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3)),
        child: Text('${(progress * 100).toInt()}%',
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      );
}

class _OverdueShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFEF4444).withOpacity(0.15),
              Colors.transparent
            ],
            stops: const [0, 0.5, 1],
          ),
        )),
      );
}

// ─── Split Dialog ──────────────────────────────────────────────────────────────
class _SplitDialog extends StatefulWidget {
  final Task task;
  final DateTime initialDate;
  final void Function(DateTime) onSplit;
  const _SplitDialog(
      {required this.task, required this.initialDate, required this.onSplit});
  @override
  State<_SplitDialog> createState() => _SplitDialogState();
}

class _SplitDialogState extends State<_SplitDialog> {
  late DateTime _splitDate;
  @override
  void initState() {
    super.initState();
    _splitDate = widget.initialDate;
  }

  Future<void> _pick() async {
    final p = await showDatePicker(
        context: context,
        initialDate: _splitDate,
        firstDate: widget.task.startDate.add(const Duration(days: 1)),
        lastDate: widget.task.endDate.subtract(const Duration(days: 1)),
        builder: (ctx, child) => Theme(data: GanttTheme.dark, child: child!));
    if (p != null) setState(() => _splitDate = p);
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
              width: 340,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Split Task',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF1F5F9))),
                    const SizedBox(height: 8),
                    Text('Splitting "${widget.task.title}" at:',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF94A3B8))),
                    const SizedBox(height: 16),
                    InkWell(
                        onTap: _pick,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                              labelText: 'Split Date',
                              suffixIcon: Icon(Icons.calendar_today, size: 14)),
                          child: Text(
                              GanttDateUtils.formatShortDate(_splitDate),
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Color(0xFFF1F5F9))),
                        )),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                          onPressed: () {
                            widget.onSplit(_splitDate);
                            Navigator.pop(context);
                          },
                          child: const Text('Split')),
                    ]),
                  ]),
            )),
      );
}

// ─── Constraint Dialog ─────────────────────────────────────────────────────────
class _ConstraintDialog extends StatefulWidget {
  final Task task;
  final void Function(TaskConstraint, DateTime?) onSave;
  const _ConstraintDialog({required this.task, required this.onSave});
  @override
  State<_ConstraintDialog> createState() => _ConstraintDialogState();
}

class _ConstraintDialogState extends State<_ConstraintDialog> {
  late TaskConstraint _selected;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    _selected = widget.task.constraint;
    _date = widget.task.constraintDate;
  }

  bool get _needsDate =>
      _selected == TaskConstraint.mustStartOn ||
      _selected == TaskConstraint.mustFinishOn ||
      _selected == TaskConstraint.startNoEarlierThan ||
      _selected == TaskConstraint.finishNoLaterThan;

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: const Color(0xFF1C2333),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF2E3854))),
        child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 380,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Task Constraint',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF1F5F9))),
                    const SizedBox(height: 4),
                    const Text('Controls how auto-scheduling treats this task.',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF94A3B8))),
                    const SizedBox(height: 16),
                    ...TaskConstraint.values
                        .map((c) => RadioListTile<TaskConstraint>(
                              value: c,
                              groupValue: _selected,
                              dense: true,
                              title: Row(children: [
                                Icon(c.icon,
                                    size: 14, color: GanttTheme.textSecondary),
                                const SizedBox(width: 8),
                                Text(c.label,
                                    style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: Color(0xFFF1F5F9))),
                              ]),
                              onChanged: (v) => setState(() => _selected = v!),
                              activeColor: GanttTheme.accent,
                            )),
                    if (_needsDate) ...[
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final p = await showDatePicker(
                              context: context,
                              initialDate: _date ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                              builder: (ctx, child) =>
                                  Theme(data: GanttTheme.dark, child: child!));
                          if (p != null) setState(() => _date = p);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                              labelText: 'Constraint Date',
                              suffixIcon: Icon(Icons.calendar_today, size: 14)),
                          child: Text(
                              _date != null
                                  ? GanttDateUtils.formatShortDate(_date!)
                                  : 'Select date',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Color(0xFFF1F5F9))),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          widget.onSave(_selected, _needsDate ? _date : null);
                          Navigator.pop(context);
                        },
                        child: const Text('Apply'),
                      ),
                    ]),
                  ]),
            )),
      );
}
