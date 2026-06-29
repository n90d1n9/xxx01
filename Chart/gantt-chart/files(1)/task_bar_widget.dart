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
  final VoidCallback? onTap;

  const TaskBarWidget({
    super.key,
    required this.task,
    required this.ganttStart,
    required this.dayWidth,
    required this.rowHeight,
    required this.rowIndex,
    this.isCritical = false,
    this.onTap,
  });

  @override
  ConsumerState<TaskBarWidget> createState() => _TaskBarWidgetState();
}

class _TaskBarWidgetState extends ConsumerState<TaskBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnim;
  late Animation<double> _scaleAnim;

  bool _isDragging = false;
  bool _isResizing = false;
  double _dragDeltaX = 0;
  double _resizeDeltaX = 0;
  Offset? _dragStartLocal;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: GanttAnimations.fast,
    );
    _elevationAnim = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  double get _barLeft {
    final base = GanttDateUtils.dayOffset(
        widget.ganttStart, widget.task.startDate, widget.dayWidth);
    return base + (_isDragging ? _dragDeltaX : 0);
  }

  double get _barWidth {
    final base = GanttDateUtils.taskBarWidth(widget.task, widget.dayWidth);
    return (base + (_isResizing ? _resizeDeltaX : 0))
        .clamp(widget.dayWidth, double.infinity);
  }

  void _onHoverEnter() {
    ref.read(hoveredTaskIdProvider.notifier).state = widget.task.id;
    _hoverController.forward();
  }

  void _onHoverExit() {
    ref.read(hoveredTaskIdProvider.notifier).state = null;
    _hoverController.reverse();
  }

  void _startDrag(DragStartDetails d) {
    setState(() {
      _isDragging = true;
      _dragDeltaX = 0;
      _dragStartLocal = d.localPosition;
    });
    ref.read(draggingTaskIdProvider.notifier).state = widget.task.id;
  }

  void _updateDrag(DragUpdateDetails d) {
    setState(() => _dragDeltaX += d.delta.dx);
  }

  void _endDrag(DragEndDetails d) {
    final daysDelta = (_dragDeltaX / widget.dayWidth).round();
    final newStart = widget.task.startDate.add(Duration(days: daysDelta));
    ref.read(tasksProvider.notifier).rescheduleTask(widget.task.id, newStart);
    setState(() {
      _isDragging = false;
      _dragDeltaX = 0;
    });
    ref.read(draggingTaskIdProvider.notifier).state = null;
  }

  void _startResize(DragStartDetails d) {
    setState(() {
      _isResizing = true;
      _resizeDeltaX = 0;
    });
  }

  void _updateResize(DragUpdateDetails d) {
    setState(() => _resizeDeltaX += d.delta.dx);
  }

  void _endResize(DragEndDetails d) {
    final daysDelta = (_resizeDeltaX / widget.dayWidth).round();
    final newEnd = widget.task.endDate.add(Duration(days: daysDelta));
    ref.read(tasksProvider.notifier).resizeTaskEnd(widget.task.id, newEnd);
    setState(() {
      _isResizing = false;
      _resizeDeltaX = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.task.isMilestone) {
      return _buildMilestoneBar();
    }
    return _buildTaskBar();
  }

  Widget _buildTaskBar() {
    final selectedId = ref.watch(selectedTaskIdProvider);
    final isSelected = selectedId == widget.task.id;
    final task = widget.task;
    final color = task.displayColor;
    final top = widget.rowIndex * widget.rowHeight;
    final barHeight = widget.rowHeight - 10;
    final topPad = 5.0;

    return Positioned(
      left: _barLeft,
      top: top + topPad,
      width: _barWidth,
      height: barHeight,
      child: MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        cursor: SystemMouseCursors.grab,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) => Transform.scale(
            scale: _isDragging ? 1.03 : _scaleAnim.value,
            alignment: Alignment.centerLeft,
            child: child,
          ),
          child: GestureDetector(
            onTap: widget.onTap,
            onHorizontalDragStart: _startDrag,
            onHorizontalDragUpdate: _updateDrag,
            onHorizontalDragEnd: _endDrag,
            child: AnimatedContainer(
              duration: GanttAnimations.fast,
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 1.0 : 0.85),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : (widget.isCritical
                          ? GanttTheme.danger
                          : color.withOpacity(0.4)),
                  width: isSelected ? 1.5 : (widget.isCritical ? 1.5 : 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(_isDragging ? 0.5 : 0.2),
                    blurRadius: _isDragging ? 12 : _elevationAnim.value,
                    offset: Offset(0, _isDragging ? 4 : 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Stack(
                  children: [
                    // Progress fill
                    if (task.progress > 0)
                      Positioned.fill(
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: task.progress.clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),

                    // Label + assignees
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (task.assignees.isNotEmpty && _barWidth > 80)
                            _buildAssigneeStack(task.assignees),
                        ],
                      ),
                    ),

                    // Critical path indicator
                    if (widget.isCritical)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: GanttTheme.danger,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                            ),
                          ),
                        ),
                      ),

                    // Resize handle (right edge)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 8,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeColumn,
                        child: GestureDetector(
                          onHorizontalDragStart: _startResize,
                          onHorizontalDragUpdate: _updateResize,
                          onHorizontalDragEnd: _endResize,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssigneeStack(List<Assignee> assignees) {
    final shown = assignees.take(2).toList();
    return SizedBox(
      width: shown.length * 14.0 + 4,
      height: 18,
      child: Stack(
        children: shown.asMap().entries.map((e) {
          return Positioned(
            left: e.key * 10.0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: e.value.avatarColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              ),
              child: Center(
                child: Text(
                  e.value.initials[0],
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMilestoneBar() {
    final selectedId = ref.watch(selectedTaskIdProvider);
    final isSelected = selectedId == widget.task.id;
    final color = widget.task.displayColor;
    final top = widget.rowIndex * widget.rowHeight;
    final size = widget.rowHeight - 16;
    final cx = _barLeft + widget.dayWidth / 2;
    final cy = top + widget.rowHeight / 2;

    return Positioned(
      left: cx - size / 2,
      top: cy - size / 2,
      width: size,
      height: size,
      child: MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _hoverController,
            builder: (context, child) => Transform.rotate(
              angle: 0.785398, // 45 degrees
              child: AnimatedContainer(
                duration: GanttAnimations.fast,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: isSelected ? Colors.white : color.withOpacity(0.6),
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: _hoverController.value * 10 + 4,
                      spreadRadius: _hoverController.value * 2,
                    ),
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
