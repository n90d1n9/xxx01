import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

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
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _elevAnim;
  late Animation<double> _scaleAnim;

  bool _isDragging = false;
  bool _isResizing = false;
  double _dragDeltaX = 0;
  double _resizeDeltaX = 0;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: GanttAnimations.fast);
    _elevAnim = Tween<double>(begin: 0, end: 6).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _hoverCtrl.dispose(); super.dispose(); }

  double get _barLeft {
    final base = GanttDateUtils.dayOffset(widget.ganttStart, widget.task.startDate, widget.dayWidth);
    return base + (_isDragging ? _dragDeltaX : 0);
  }

  double get _barWidth {
    final base = GanttDateUtils.taskBarWidth(widget.task, widget.dayWidth);
    return (base + (_isResizing ? _resizeDeltaX : 0)).clamp(widget.dayWidth, double.infinity);
  }

  void _onEnter() { ref.read(hoveredTaskIdProvider.notifier).state = widget.task.id; _hoverCtrl.forward(); }
  void _onExit() { ref.read(hoveredTaskIdProvider.notifier).state = null; _hoverCtrl.reverse(); }

  void _startDrag(DragStartDetails d) { setState(() { _isDragging = true; _dragDeltaX = 0; }); ref.read(draggingTaskIdProvider.notifier).state = widget.task.id; }
  void _updateDrag(DragUpdateDetails d) { setState(() => _dragDeltaX += d.delta.dx); }
  void _endDrag(DragEndDetails _) {
    final days = (_dragDeltaX / widget.dayWidth).round();
    ref.read(tasksProvider.notifier).rescheduleTask(widget.task.id, widget.task.startDate.add(Duration(days: days)));
    setState(() { _isDragging = false; _dragDeltaX = 0; });
    ref.read(draggingTaskIdProvider.notifier).state = null;
  }

  void _startResize(DragStartDetails _) { setState(() { _isResizing = true; _resizeDeltaX = 0; }); }
  void _updateResize(DragUpdateDetails d) { setState(() => _resizeDeltaX += d.delta.dx); }
  void _endResize(DragEndDetails _) {
    final days = (_resizeDeltaX / widget.dayWidth).round();
    ref.read(tasksProvider.notifier).resizeTaskEnd(widget.task.id, widget.task.endDate.add(Duration(days: days)));
    setState(() { _isResizing = false; _resizeDeltaX = 0; });
  }

  void _showContextMenu(BuildContext ctx, Offset globalPos) {
    final overlay = Overlay.of(ctx).context.findRenderObject() as RenderBox;
    showMenu<String>(
      context: ctx,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPos.dx, globalPos.dy, 1, 1),
        Offset.zero & overlay.size,
      ),
      color: const Color(0xFF252D40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF2E3854))),
      items: [
        _menuItem('edit', Icons.edit_outlined, 'Edit Task'),
        _menuItem('duplicate', Icons.copy_outlined, 'Duplicate'),
        _menuItem('split', Icons.call_split, 'Split Task'),
        _menuItem('baseline', Icons.bookmark_outlined, 'Set Baseline'),
        const PopupMenuDivider(height: 4),
        _menuItem('delete', Icons.delete_outlined, 'Delete', danger: true),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'edit':
          ref.read(selectedTaskIdProvider.notifier).state = widget.task.id;
        case 'duplicate':
          ref.read(tasksProvider.notifier).duplicateTask(widget.task.id);
        case 'split':
          _showSplitDialog(ctx);
        case 'baseline':
          ref.read(tasksProvider.notifier).setBaseline('Baseline ${DateTime.now().day}/${DateTime.now().month}');
        case 'delete':
          ref.read(tasksProvider.notifier).deleteTask(widget.task.id);
          ref.read(selectedTaskIdProvider.notifier).state = null;
      }
    });
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, {bool danger = false}) =>
      PopupMenuItem(value: value, height: 36,
        child: Row(children: [
          Icon(icon, size: 14, color: danger ? const Color(0xFFEF4444) : const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: danger ? const Color(0xFFEF4444) : const Color(0xFFF1F5F9))),
        ]));

  void _showSplitDialog(BuildContext ctx) {
    final mid = widget.task.startDate.add(Duration(days: widget.task.durationDays ~/ 2));
    showDialog(context: ctx, builder: (_) => _SplitDialog(task: widget.task, initialDate: mid, onSplit: (d) => ref.read(tasksProvider.notifier).splitTask(widget.task.id, d)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.task.isMilestone) return _buildMilestone();
    return _buildBar();
  }

  Widget _buildBar() {
    final selectedId = ref.watch(selectedTaskIdProvider);
    final isSelected = selectedId == widget.task.id;
    final task = widget.task;
    final color = task.displayColor;
    final top = widget.rowIndex * widget.rowHeight;
    final barH = widget.rowHeight - 10;

    return Stack(children: [
      // Baseline ghost bar (behind main bar)
      if (widget.showBaseline && task.baseline != null)
        _BaselineBar(task: task, ganttStart: widget.ganttStart, dayWidth: widget.dayWidth, rowIndex: widget.rowIndex, rowHeight: widget.rowHeight),

      // Main bar
      Positioned(
        left: _barLeft, top: top + 5, width: _barWidth, height: barH,
        child: MouseRegion(
          onEnter: (_) => _onEnter(), onExit: (_) => _onExit(),
          cursor: _isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
          child: GestureDetector(
            onTap: widget.onTap,
            onSecondaryTapUp: (d) => _showContextMenu(context, d.globalPosition),
            onLongPressStart: (d) => _showContextMenu(context, d.globalPosition),
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
              child: Tooltip(
                message: '${task.title}\n${GanttDateUtils.formatShortDate(task.startDate)} – ${GanttDateUtils.formatShortDate(task.endDate)}\n${GanttDateUtils.durationLabel(task)} • ${(task.progress * 100).toInt()}%',
                waitDuration: const Duration(milliseconds: 600),
                child: AnimatedContainer(
                  duration: GanttAnimations.fast,
                  decoration: BoxDecoration(
                    color: color.withOpacity(isSelected ? 1.0 : 0.85),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected ? Colors.white.withOpacity(0.9) : (widget.isCritical ? const Color(0xFFEF4444) : color.withOpacity(0.4)),
                      width: isSelected || widget.isCritical ? 1.5 : 1.0,
                    ),
                    boxShadow: [BoxShadow(color: color.withOpacity(_isDragging ? 0.5 : 0.2), blurRadius: _isDragging ? 12 : _elevAnim.value, offset: Offset(0, _isDragging ? 4 : 2))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(children: [
                      // Progress fill
                      if (task.progress > 0)
                        Positioned.fill(child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: task.progress.clamp(0.0, 1.0),
                          child: Container(color: Colors.white.withOpacity(0.15)),
                        )),
                      // Shimmer on near-deadline tasks
                      if (task.isOverdue) _OverdueShimmer(),
                      // Label
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        child: Row(children: [
                          Expanded(child: Text(task.title,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white, overflow: TextOverflow.ellipsis),
                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                          // Checklist progress badge
                          if (task.checklist.isNotEmpty && _barWidth > 100)
                            _ChecklistBadge(progress: task.checklistProgress),
                          if (task.assignees.isNotEmpty && _barWidth > 80)
                            _AssigneeStack(assignees: task.assignees),
                        ]),
                      ),
                      // Critical path accent
                      if (widget.isCritical)
                        Positioned(left: 0, top: 0, bottom: 0, width: 3,
                          child: Container(decoration: const BoxDecoration(color: Color(0xFFEF4444), borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5))))),
                      // Risk level dot
                      if (task.riskLevel != RiskLevel.none)
                        Positioned(top: 3, right: 12,
                          child: Container(width: 5, height: 5, decoration: BoxDecoration(color: task.riskLevel.color, shape: BoxShape.circle))),
                      // Resize handle
                      Positioned(right: 0, top: 0, bottom: 0, width: 8,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeColumn,
                          child: GestureDetector(
                            onHorizontalDragStart: _startResize, onHorizontalDragUpdate: _updateResize, onHorizontalDragEnd: _endResize,
                            child: Container(decoration: const BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)))),
                          ),
                        )),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildMilestone() {
    final selectedId = ref.watch(selectedTaskIdProvider);
    final isSelected = selectedId == widget.task.id;
    final color = widget.task.displayColor;
    final top = widget.rowIndex * widget.rowHeight;
    final sz = widget.rowHeight - 16;
    final cx = _barLeft + widget.dayWidth / 2;
    final cy = top + widget.rowHeight / 2;

    return Positioned(
      left: cx - sz / 2, top: cy - sz / 2, width: sz, height: sz,
      child: MouseRegion(
        onEnter: (_) => _onEnter(), onExit: (_) => _onExit(),
        child: GestureDetector(
          onTap: widget.onTap,
          onSecondaryTapUp: (d) => _showContextMenu(context, d.globalPosition),
          child: AnimatedBuilder(
            animation: _hoverCtrl,
            builder: (_, child) => Transform.rotate(angle: 0.785398, child: child),
            child: AnimatedContainer(
              duration: GanttAnimations.fast,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: isSelected ? Colors.white : color.withOpacity(0.6), width: isSelected ? 2 : 1.5),
                boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: _hoverCtrl.value * 10 + 4, spreadRadius: _hoverCtrl.value * 2)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Baseline ghost bar ──────────────────────────────────────────────────────

class _BaselineBar extends StatelessWidget {
  final Task task;
  final DateTime ganttStart;
  final double dayWidth;
  final int rowIndex;
  final double rowHeight;

  const _BaselineBar({required this.task, required this.ganttStart, required this.dayWidth, required this.rowIndex, required this.rowHeight});

  @override
  Widget build(BuildContext context) {
    final b = task.baseline!;
    final left = GanttDateUtils.dayOffset(ganttStart, b.startDate, dayWidth);
    final width = ((b.endDate.difference(b.startDate).inDays + 1) * dayWidth).clamp(dayWidth, double.infinity);
    final top = rowIndex * rowHeight + rowHeight - 9;

    return Positioned(
      left: left, top: top, width: width, height: 5,
      child: Tooltip(
        message: 'Baseline: ${GanttDateUtils.formatShortDate(b.startDate)} – ${GanttDateUtils.formatShortDate(b.endDate)}\n${b.label}',
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF94A3B8).withOpacity(0.35),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: const Color(0xFF94A3B8).withOpacity(0.6), width: 0.5),
          ),
        ),
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
    return SizedBox(width: shown.length * 10.0 + 10, height: 18,
      child: Stack(children: shown.asMap().entries.map((e) => Positioned(
        left: e.key * 10.0,
        child: Container(width: 16, height: 16,
          decoration: BoxDecoration(color: e.value.avatarColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)),
          child: Center(child: Text(e.value.initials[0], style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)))),
      )).toList()));
  }
}

class _ChecklistBadge extends StatelessWidget {
  final double progress;
  const _ChecklistBadge({required this.progress});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 4),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
    child: Text('${(progress * 100).toInt()}%', style: const TextStyle(fontFamily: 'Inter', fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white)),
  );
}

class _OverdueShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, const Color(0xFFEF4444).withOpacity(0.15), Colors.transparent],
          stops: const [0, 0.5, 1],
        ),
      ),
    ),
  );
}

// ─── Split Dialog ─────────────────────────────────────────────────────────────

class _SplitDialog extends StatefulWidget {
  final Task task;
  final DateTime initialDate;
  final void Function(DateTime) onSplit;
  const _SplitDialog({required this.task, required this.initialDate, required this.onSplit});
  @override
  State<_SplitDialog> createState() => _SplitDialogState();
}

class _SplitDialogState extends State<_SplitDialog> {
  late DateTime _splitDate;

  @override
  void initState() { super.initState(); _splitDate = widget.initialDate; }

  Future<void> _pick() async {
    final p = await showDatePicker(
      context: context, initialDate: _splitDate,
      firstDate: widget.task.startDate.add(const Duration(days: 1)),
      lastDate: widget.task.endDate.subtract(const Duration(days: 1)),
      builder: (ctx, child) => Theme(data: GanttTheme.dark, child: child!),
    );
    if (p != null) setState(() => _splitDate = p);
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: const Color(0xFF1C2333),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF2E3854))),
    child: Padding(padding: const EdgeInsets.all(24), child: SizedBox(width: 340,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Split Task', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFF1F5F9))),
        const SizedBox(height: 8),
        Text('Splitting "${widget.task.title}" into two linked tasks at:', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF94A3B8))),
        const SizedBox(height: 16),
        InkWell(onTap: _pick, child: InputDecorator(
          decoration: const InputDecoration(labelText: 'Split Date', suffixIcon: Icon(Icons.calendar_today, size: 14)),
          child: Text(GanttDateUtils.formatShortDate(_splitDate), style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFFF1F5F9))),
        )),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () { widget.onSplit(_splitDate); Navigator.pop(context); }, child: const Text('Split')),
        ]),
      ]),
    )),
  );
}
