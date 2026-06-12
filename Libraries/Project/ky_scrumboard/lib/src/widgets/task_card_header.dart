import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task.dart';
import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'task_card_badge.dart';

/// Header row for a scrum task card with selection, label, and story points.
class ScrumTaskCardHeader extends StatelessWidget {
  const ScrumTaskCardHeader({
    super.key,
    required this.task,
    required this.selected,
    this.onSelectedChanged,
  });

  final ScrumTask task;
  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    final priorityColor = ScrumBoardPalette.priorityColor(task.priority);

    return Row(
      children: [
        _ScrumTaskSelectionButton(
          selected: selected,
          onSelectedChanged: onSelectedChanged,
        ),
        const SizedBox(width: 8),
        ScrumTaskCardBadge(
          label: task.label ?? task.priority.label,
          color: task.accentColor,
        ),
        const Spacer(),
        ScrumTaskCardBadge(
          label: '${task.storyPoints} SP',
          color: priorityColor,
          tonal: true,
        ),
      ],
    );
  }
}

/// Preview for the card header in a selected state.
@Preview(group: 'Ky Scrumboard', name: 'Task card header', size: Size(340, 90))
Widget scrumTaskCardHeaderPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 300,
          child: ScrumTaskCardHeader(
            task: ScrumTask(
              id: 'header-preview',
              title: 'Header preview',
              description: 'Preview task card header.',
              assignee: 'Alya',
              storyPoints: 8,
              createdAt: DateTime(2026, 1),
              status: ScrumTaskStatus.todo,
              priority: ScrumTaskPriority.high,
              label: 'Platform',
              accentColor: const Color(0xFF2563EB),
            ),
            selected: true,
            onSelectedChanged: (_) {},
          ),
        ),
      ),
    ),
  );
}

/// Body copy for a scrum task card.
class ScrumTaskCardContent extends StatelessWidget {
  const ScrumTaskCardContent({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleSmall?.copyWith(
            color: ScrumBoardPalette.ink,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: ScrumBoardPalette.mutedInk,
          ),
        ),
      ],
    );
  }
}

/// Preview for task-card title and description content.
@Preview(
  group: 'Ky Scrumboard',
  name: 'Task card content',
  size: Size(340, 130),
)
Widget scrumTaskCardContentPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: const Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: SizedBox(
          width: 300,
          child: ScrumTaskCardContent(
            title: 'Checkout readiness review',
            description: 'Validate final payment copy and release signals.',
          ),
        ),
      ),
    ),
  );
}

/// Selection icon button used by task cards when bulk actions are enabled.
class _ScrumTaskSelectionButton extends StatelessWidget {
  const _ScrumTaskSelectionButton({
    required this.selected,
    required this.onSelectedChanged,
  });

  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;

  @override
  Widget build(BuildContext context) {
    final callback = onSelectedChanged;
    if (callback == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: selected ? 'Deselect task' : 'Select task',
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
      padding: EdgeInsets.zero,
      onPressed: () => callback(!selected),
      icon: Icon(
        selected
            ? Icons.check_box_rounded
            : Icons.check_box_outline_blank_rounded,
        size: 20,
        color: selected ? const Color(0xFF2563EB) : ScrumBoardPalette.mutedInk,
      ),
    );
  }
}
