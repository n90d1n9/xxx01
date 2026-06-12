import 'package:flutter/material.dart';

import '../../models/scrum_activity.dart';

String scrumActivityTypeLabel(ScrumActivityType type) {
  switch (type) {
    case ScrumActivityType.taskCreated:
      return 'Created task';
    case ScrumActivityType.taskUpdated:
      return 'Updated task';
    case ScrumActivityType.taskMoved:
      return 'Moved task';
    case ScrumActivityType.taskReordered:
      return 'Reordered task';
    case ScrumActivityType.taskPriorityChanged:
      return 'Changed priority';
    case ScrumActivityType.taskCommented:
      return 'Added note';
    case ScrumActivityType.taskDeleted:
      return 'Deleted task';
    case ScrumActivityType.boardReplaced:
      return 'Replaced board';
  }
}

IconData scrumActivityTypeIcon(ScrumActivityType type) {
  switch (type) {
    case ScrumActivityType.taskCreated:
      return Icons.add_task_rounded;
    case ScrumActivityType.taskUpdated:
      return Icons.edit_note_rounded;
    case ScrumActivityType.taskMoved:
      return Icons.swap_horiz_rounded;
    case ScrumActivityType.taskReordered:
      return Icons.reorder_rounded;
    case ScrumActivityType.taskPriorityChanged:
      return Icons.flag_rounded;
    case ScrumActivityType.taskCommented:
      return Icons.chat_bubble_outline_rounded;
    case ScrumActivityType.taskDeleted:
      return Icons.delete_outline_rounded;
    case ScrumActivityType.boardReplaced:
      return Icons.inventory_2_outlined;
  }
}

Color scrumActivityTypeColor(ScrumActivityType type) {
  switch (type) {
    case ScrumActivityType.taskCreated:
      return const Color(0xFF059669);
    case ScrumActivityType.taskUpdated:
      return const Color(0xFF2563EB);
    case ScrumActivityType.taskMoved:
      return const Color(0xFF0891B2);
    case ScrumActivityType.taskReordered:
      return const Color(0xFF7C3AED);
    case ScrumActivityType.taskPriorityChanged:
      return const Color(0xFFD97706);
    case ScrumActivityType.taskCommented:
      return const Color(0xFF0D9488);
    case ScrumActivityType.taskDeleted:
      return const Color(0xFFDC2626);
    case ScrumActivityType.boardReplaced:
      return const Color(0xFF475569);
  }
}
