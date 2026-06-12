import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';

/// Popup action for moving selected tasks to another board lane.
class BulkStatusMenuButton extends StatelessWidget {
  const BulkStatusMenuButton({
    super.key,
    required this.statuses,
    required this.statusLabelFor,
    required this.onMoveToStatus,
  });

  final List<ScrumTaskStatus> statuses;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final ValueChanged<ScrumTaskStatus> onMoveToStatus;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ScrumTaskStatus>(
      tooltip: 'Move selected tasks',
      onSelected: onMoveToStatus,
      itemBuilder: (context) => [
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
      ],
      child: const BulkActionSurface(
        icon: Icons.swap_horiz_rounded,
        label: 'Move',
      ),
    );
  }
}

/// Popup action for applying a priority to selected tasks.
class BulkPriorityMenuButton extends StatelessWidget {
  const BulkPriorityMenuButton({super.key, required this.onPriorityChanged});

  final ValueChanged<ScrumTaskPriority> onPriorityChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ScrumTaskPriority>(
      tooltip: 'Set selected priority',
      onSelected: onPriorityChanged,
      itemBuilder: (context) => [
        for (final priority in ScrumTaskPriority.values)
          PopupMenuItem<ScrumTaskPriority>(
            value: priority,
            child: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 18,
                  color: ScrumBoardPalette.priorityColor(priority),
                ),
                const SizedBox(width: 8),
                Text(priority.label),
              ],
            ),
          ),
      ],
      child: const BulkActionSurface(
        icon: Icons.flag_outlined,
        label: 'Priority',
      ),
    );
  }
}

/// Destructive bulk action button for deleting selected tasks.
class BulkDeleteButton extends StatelessWidget {
  const BulkDeleteButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.delete_outline_rounded, size: 18),
      label: const Text('Delete'),
      style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
    );
  }
}

/// Compact icon-and-label surface used by bulk popup menu actions.
class BulkActionSurface extends StatelessWidget {
  const BulkActionSurface({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withValues(alpha: .08),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: .18),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }
}

/// Preview for the reusable bulk action controls.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Bulk action controls',
  size: Size(420, 100),
)
Widget bulkActionButtonsPreview() {
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
            BulkStatusMenuButton(
              statuses: const [
                ScrumTaskStatus.todo,
                ScrumTaskStatus.inProgress,
                ScrumTaskStatus.done,
              ],
              statusLabelFor: (status) => status.label,
              onMoveToStatus: (_) {},
            ),
            BulkPriorityMenuButton(onPriorityChanged: (_) {}),
            BulkDeleteButton(onPressed: () {}),
          ],
        ),
      ),
    ),
  );
}
