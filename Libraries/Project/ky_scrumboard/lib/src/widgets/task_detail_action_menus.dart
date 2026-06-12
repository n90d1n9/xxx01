import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';

/// Popup menu for changing a task priority from the detail panel.
class TaskDetailPriorityMenu extends StatelessWidget {
  const TaskDetailPriorityMenu({
    super.key,
    required this.priorities,
    required this.onPriorityChanged,
  });

  final List<ScrumTaskPriority> priorities;
  final ValueChanged<ScrumTaskPriority> onPriorityChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ScrumTaskPriority>(
      tooltip: 'Change priority',
      enabled: priorities.isNotEmpty,
      onSelected: onPriorityChanged,
      itemBuilder: (context) {
        return [
          for (final priority in priorities)
            PopupMenuItem<ScrumTaskPriority>(
              value: priority,
              child: Row(
                children: [
                  Icon(
                    _priorityIcon(priority),
                    size: 18,
                    color: ScrumBoardPalette.priorityColor(priority),
                  ),
                  const SizedBox(width: 8),
                  Text(priority.label),
                ],
              ),
            ),
        ];
      },
      child: TaskDetailMenuSurface(
        icon: Icons.flag_rounded,
        label: 'Priority',
        color: const Color(0xFF7C3AED),
        enabled: priorities.isNotEmpty,
      ),
    );
  }
}

/// Popup menu for moving a task to another board lane from the detail panel.
class TaskDetailMoveMenu extends StatelessWidget {
  const TaskDetailMoveMenu({
    super.key,
    required this.statuses,
    required this.statusLabelFor,
    required this.onMove,
  });

  final List<ScrumTaskStatus> statuses;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final ValueChanged<ScrumTaskStatus> onMove;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ScrumTaskStatus>(
      tooltip: 'Move task',
      onSelected: onMove,
      itemBuilder: (context) {
        return [
          for (final status in statuses)
            PopupMenuItem<ScrumTaskStatus>(
              value: status,
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: ScrumBoardPalette.statusColor(status),
                  ),
                  const SizedBox(width: 8),
                  Text(statusLabelFor(status)),
                ],
              ),
            ),
        ];
      },
      child: const TaskDetailMenuSurface(
        icon: Icons.swap_horiz_rounded,
        label: 'Move',
        color: Color(0xFF2563EB),
      ),
    );
  }
}

/// Compact icon-and-label menu surface used by task detail popup actions.
class TaskDetailMenuSurface extends StatelessWidget {
  const TaskDetailMenuSurface({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          border: Border.all(color: color.withValues(alpha: .22)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

/// Preview for the reusable task detail action menus.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task detail action menus',
  size: Size(360, 100),
)
Widget taskDetailActionMenusPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            TaskDetailPriorityMenu(
              priorities: const [
                ScrumTaskPriority.high,
                ScrumTaskPriority.critical,
              ],
              onPriorityChanged: (_) {},
            ),
            TaskDetailMoveMenu(
              statuses: const [
                ScrumTaskStatus.inProgress,
                ScrumTaskStatus.done,
              ],
              statusLabelFor: (status) => status.label,
              onMove: (_) {},
            ),
          ],
        ),
      ),
    ),
  );
}

IconData _priorityIcon(ScrumTaskPriority priority) {
  switch (priority) {
    case ScrumTaskPriority.low:
      return Icons.keyboard_arrow_down_rounded;
    case ScrumTaskPriority.medium:
      return Icons.drag_handle_rounded;
    case ScrumTaskPriority.high:
      return Icons.keyboard_arrow_up_rounded;
    case ScrumTaskPriority.critical:
      return Icons.priority_high_rounded;
  }
}
