import 'package:flutter/material.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../gantt_dashboard.dart' as gantt;

/// View model for blocked Gantt schedule edit feedback.
class GanttTaskScheduleGuardFeedbackPresentation {
  const GanttTaskScheduleGuardFeedbackPresentation({
    required this.icon,
    required this.title,
    required this.details,
  });

  final IconData icon;
  final String title;
  final String details;
}

/// Maps schedule guard validation into user-facing feedback copy.
class GanttTaskScheduleGuardFeedbackPresentationService {
  const GanttTaskScheduleGuardFeedbackPresentationService();

  GanttTaskScheduleGuardFeedbackPresentation presentationFor({
    required gantt.GanttTask task,
    required ky.KyGanttTaskDateRangeValidation validation,
  }) {
    final message = validation.message?.trim();

    return GanttTaskScheduleGuardFeedbackPresentation(
      icon:
          validation.isBlocking
              ? Icons.verified_user_outlined
              : Icons.info_outline_rounded,
      title: validation.isBlocking ? 'Schedule Guard' : 'Schedule Check',
      details:
          message == null || message.isEmpty
              ? 'Date change needs review - ${task.title}'
              : '$message - ${task.title}',
    );
  }
}
