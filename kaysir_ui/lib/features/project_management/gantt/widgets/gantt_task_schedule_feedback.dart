import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../gantt_dashboard.dart' as gantt;
import '../services/gantt_task_schedule_feedback_presentation_service.dart';

/// Compact snackbar content that confirms a recent Gantt task edit.
class GanttTaskScheduleFeedback extends StatelessWidget {
  const GanttTaskScheduleFeedback({required this.activity, super.key});

  static const feedbackKey = ValueKey('gantt-task-schedule-feedback');
  static const _presentationService =
      GanttTaskScheduleFeedbackPresentationService();

  final gantt.GanttTaskEditActivity activity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final presentation = _presentationService.presentationFor(activity);

    return Row(
      key: feedbackKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(presentation.icon, size: 18, color: colorScheme.primary),
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

@Preview(name: 'Gantt task schedule feedback')
Widget ganttTaskScheduleFeedbackPreview() {
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
              child: GanttTaskScheduleFeedback(
                activity: gantt.GanttTaskEditActivity(
                  taskId: 'build',
                  taskTitle: 'Build customer portal',
                  kind: gantt.GanttTaskEditKind.endDate,
                  label: 'Finish resized +2d',
                  timestamp: DateTime(2026, 6, 11, 9),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
