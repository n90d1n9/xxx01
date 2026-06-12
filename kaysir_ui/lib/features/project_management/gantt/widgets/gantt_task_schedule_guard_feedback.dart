import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_task_schedule_guard_feedback_presentation_service.dart';

/// Compact snackbar content that explains a blocked Gantt schedule edit.
class GanttTaskScheduleGuardFeedback extends StatelessWidget {
  const GanttTaskScheduleGuardFeedback({
    required this.task,
    required this.validation,
    super.key,
  });

  static const feedbackKey = ValueKey('gantt-task-schedule-guard-feedback');
  static const _presentationService =
      GanttTaskScheduleGuardFeedbackPresentationService();

  final gantt.GanttTask task;
  final ky.KyGanttTaskDateRangeValidation validation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final presentation = _presentationService.presentationFor(
      task: task,
      validation: validation,
    );

    return Row(
      key: feedbackKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.error.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(presentation.icon, size: 18, color: colorScheme.error),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                presentation.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                presentation.details,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onInverseSurface.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Gantt task schedule guard feedback')
Widget ganttTaskScheduleGuardFeedbackPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Builder(
          builder: (context) {
            final colorScheme = Theme.of(context).colorScheme;

            return Container(
              width: 420,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.inverseSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: GanttTaskScheduleGuardFeedback(
                task: gantt.GanttTask(
                  id: 'build',
                  title: 'Build customer portal',
                  startDate: DateTime(2026, 6, 11),
                  endDate: DateTime(2026, 6, 18),
                ),
                validation: const ky.KyGanttTaskDateRangeValidation.blocked(
                  'Would overlap Launch Readiness',
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
