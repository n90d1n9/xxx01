import 'package:flutter/material.dart';

import '../gantt_dashboard.dart' as gantt;

/// View model for the compact schedule edit feedback surface.
class GanttTaskScheduleFeedbackPresentation {
  const GanttTaskScheduleFeedbackPresentation({
    required this.icon,
    required this.title,
    required this.details,
  });

  final IconData icon;
  final String title;
  final String details;
}

/// Maps recent task edit activity into user-facing feedback copy and iconography.
class GanttTaskScheduleFeedbackPresentationService {
  const GanttTaskScheduleFeedbackPresentationService();

  GanttTaskScheduleFeedbackPresentation presentationFor(
    gantt.GanttTaskEditActivity activity,
  ) {
    return GanttTaskScheduleFeedbackPresentation(
      icon: _iconFor(activity.kind),
      title: _titleFor(activity.kind),
      details: '${activity.label} - ${activity.taskTitle}',
    );
  }

  IconData _iconFor(gantt.GanttTaskEditKind kind) {
    switch (kind) {
      case gantt.GanttTaskEditKind.details:
        return Icons.edit_note_rounded;
      case gantt.GanttTaskEditKind.progress:
        return Icons.trending_up_rounded;
      case gantt.GanttTaskEditKind.taskType:
        return Icons.category_outlined;
      case gantt.GanttTaskEditKind.startDate:
      case gantt.GanttTaskEditKind.endDate:
      case gantt.GanttTaskEditKind.milestoneDate:
        return Icons.event_available_outlined;
      case gantt.GanttTaskEditKind.dependency:
        return Icons.link_rounded;
      case gantt.GanttTaskEditKind.undo:
        return Icons.undo_rounded;
    }
  }

  String _titleFor(gantt.GanttTaskEditKind kind) {
    switch (kind) {
      case gantt.GanttTaskEditKind.details:
        return 'Task Updated';
      case gantt.GanttTaskEditKind.progress:
        return 'Progress Updated';
      case gantt.GanttTaskEditKind.taskType:
        return 'Task Type Updated';
      case gantt.GanttTaskEditKind.startDate:
      case gantt.GanttTaskEditKind.endDate:
      case gantt.GanttTaskEditKind.milestoneDate:
        return 'Schedule Updated';
      case gantt.GanttTaskEditKind.dependency:
        return 'Dependency Updated';
      case gantt.GanttTaskEditKind.undo:
        return 'Edit Reverted';
    }
  }
}
