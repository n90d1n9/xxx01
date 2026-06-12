import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/models/task_model.dart';
import '../../core/providers/gantt_providers.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/theme/gantt_theme.dart';

/// Rich hover popover shown when mouse dwells over a task bar.
/// Appears above the bar, uses an overlay entry to float above all content.
class HoverPopover extends ConsumerStatefulWidget {
  final Task task;
  final Offset globalPosition;
  final VoidCallback onClose;

  const HoverPopover({
    super.key,
    required this.task,
    required this.globalPosition,
    required this.onClose,
  });

  @override
  ConsumerState<HoverPopover> createState() => _HoverPopoverState();
}

class _HoverPopoverState extends ConsumerState<HoverPopover>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 160));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final pos = widget.globalPosition;

    // Clamp so it doesn't go off-screen
    final screenSize = MediaQuery.of(context).size;
    const w = 280.0;
    const h = 200.0;
    final left = (pos.dx - w / 2).clamp(8.0, screenSize.width - w - 8);
    final top = (pos.dy - h - 12).clamp(8.0, screenSize.height - h - 8);

    return Positioned(
      left: left,
      top: top,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: w,
              decoration: BoxDecoration(
                color: GanttTheme.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GanttTheme.surface4),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black45,
                      blurRadius: 20,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: task.displayColor.withOpacity(0.12),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    border: Border(
                        bottom: BorderSide(
                            color: task.displayColor.withOpacity(0.2))),
                  ),
                  child: Row(children: [
                    Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                            color: task.displayColor, shape: BoxShape.circle)),
                    Expanded(
                        child: Text(task.title,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: GanttTheme.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis)),
                    if (task.isLocked)
                      const Icon(Icons.lock_outline,
                          size: 12, color: GanttTheme.textMuted),
                  ]),
                ),

                // Body
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dates
                        _Row(Icons.calendar_today_outlined,
                            '${GanttDateUtils.formatShortDate(task.startDate)}  →  ${GanttDateUtils.formatShortDate(task.endDate)}',
                            color: GanttTheme.textSecondary),
                        const SizedBox(height: 6),

                        // Duration
                        _Row(Icons.timelapse_outlined,
                            '${task.durationDays} days${task.estimatedHours > 0 ? "  ·  ${task.estimatedHours.toStringAsFixed(0)}h est." : ""}',
                            color: GanttTheme.textMuted),
                        const SizedBox(height: 6),

                        // Status + Priority row
                        Row(children: [
                          _Chip(task.status.label, task.status.color),
                          const SizedBox(width: 6),
                          _Chip(task.priority.label, task.priority.color),
                          if (task.isMilestone) ...[
                            const SizedBox(width: 6),
                            _Chip('Milestone', GanttTheme.accent),
                          ],
                        ]),
                        const SizedBox(height: 8),

                        // Progress bar
                        Row(children: [
                          Expanded(
                              child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: task.progress,
                              minHeight: 5,
                              backgroundColor: GanttTheme.surface4,
                              color: task.progress >= 1.0
                                  ? GanttTheme.success
                                  : task.displayColor,
                            ),
                          )),
                          const SizedBox(width: 8),
                          Text('${(task.progress * 100).toInt()}%',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: GanttTheme.textSecondary)),
                        ]),

                        // Assignees
                        if (task.assignees.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.person_outline,
                                size: 11, color: GanttTheme.textMuted),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(
                              task.assignees.map((a) => a.name).join(', '),
                              style: const TextStyle(
                                  fontSize: 10, color: GanttTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                          ]),
                        ],

                        // Overdue warning
                        if (task.isOverdue) ...[
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.warning_amber_outlined,
                                size: 11, color: GanttTheme.danger),
                            const SizedBox(width: 6),
                            const Text('Overdue',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: GanttTheme.danger)),
                          ]),
                        ],

                        // Baseline slip
                        if (task.baseline != null && task.slipDays != 0) ...[
                          const SizedBox(height: 6),
                          Row(children: [
                            Icon(
                                task.slipDays > 0
                                    ? Icons.arrow_forward
                                    : Icons.arrow_back,
                                size: 11,
                                color: task.slipDays > 0
                                    ? GanttTheme.danger
                                    : GanttTheme.success),
                            const SizedBox(width: 6),
                            Text(
                              task.slipDays > 0
                                  ? '${task.slipDays}d behind baseline'
                                  : '${-task.slipDays}d ahead of baseline',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: task.slipDays > 0
                                      ? GanttTheme.danger
                                      : GanttTheme.success),
                            ),
                          ]),
                        ],

                        // Constraint indicator
                        if (task.constraint != TaskConstraint.asap) ...[
                          const SizedBox(height: 6),
                          Row(children: [
                            Icon(task.constraint.icon,
                                size: 11, color: GanttTheme.warning),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(task.constraint.label,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: GanttTheme.warning))),
                          ]),
                        ],
                      ]),
                ),

                // Footer hint
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: GanttTheme.surface3,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(10)),
                  ),
                  child: const Row(children: [
                    Text(
                        'Click to select  ·  Right-click for menu  ·  Drag to move',
                        style: TextStyle(
                            fontSize: 9, color: GanttTheme.textDisabled)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Row(this.icon, this.text, {required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 11, color: GanttTheme.textMuted),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 11, color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ]);
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 9, fontWeight: FontWeight.w600, color: color)),
      );
}

/// Manages an overlay entry for the hover popover.
/// Wrap your Stack with this controller.
class HoverPopoverController {
  OverlayEntry? _entry;
  String? _taskId;
  bool _dwell = false;

  void show(BuildContext context, Task task, Offset globalPos) {
    if (_taskId == task.id) return;
    hide();
    _taskId = task.id;
    _dwell = false;

    Future.delayed(const Duration(milliseconds: 420), () {
      if (!_dwell) return;
      _entry = OverlayEntry(
          builder: (_) => Stack(children: [
                // Dismiss on tap outside
                Positioned.fill(
                    child: GestureDetector(
                        onTap: hide,
                        behavior: HitTestBehavior.translucent,
                        child: const SizedBox.expand())),
                // The popover itself
                HoverPopover(
                    task: task, globalPosition: globalPos, onClose: hide),
              ]));
      Overlay.of(context).insert(_entry!);
    });

    Future.delayed(const Duration(milliseconds: 380), () => _dwell = true);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
    _taskId = null;
    _dwell = false;
  }
}
