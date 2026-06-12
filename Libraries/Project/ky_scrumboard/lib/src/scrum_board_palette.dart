import 'package:flutter/material.dart';

import '../models/scrum_board_insight.dart';
import '../models/scrum_task_priority.dart';
import '../models/scrum_task_status.dart';

class ScrumBoardPalette {
  const ScrumBoardPalette._();

  static const background = Color(0xFFF6F8FB);
  static const ink = Color(0xFF172033);
  static const mutedInk = Color(0xFF667085);
  static const border = Color(0xFFE4E7EC);

  static Color statusColor(ScrumTaskStatus status) {
    switch (status) {
      case ScrumTaskStatus.backlog:
        return const Color(0xFF64748B);
      case ScrumTaskStatus.todo:
        return const Color(0xFF2563EB);
      case ScrumTaskStatus.inProgress:
        return const Color(0xFF0891B2);
      case ScrumTaskStatus.review:
        return const Color(0xFFD97706);
      case ScrumTaskStatus.done:
        return const Color(0xFF16A34A);
    }
  }

  static Color priorityColor(ScrumTaskPriority priority) {
    switch (priority) {
      case ScrumTaskPriority.low:
        return const Color(0xFF64748B);
      case ScrumTaskPriority.medium:
        return const Color(0xFF2563EB);
      case ScrumTaskPriority.high:
        return const Color(0xFFD97706);
      case ScrumTaskPriority.critical:
        return const Color(0xFFDC2626);
    }
  }

  static Color insightColor(ScrumBoardInsightSeverity severity) {
    switch (severity) {
      case ScrumBoardInsightSeverity.positive:
        return const Color(0xFF16A34A);
      case ScrumBoardInsightSeverity.info:
        return const Color(0xFF2563EB);
      case ScrumBoardInsightSeverity.warning:
        return const Color(0xFFD97706);
      case ScrumBoardInsightSeverity.critical:
        return const Color(0xFFDC2626);
    }
  }
}
