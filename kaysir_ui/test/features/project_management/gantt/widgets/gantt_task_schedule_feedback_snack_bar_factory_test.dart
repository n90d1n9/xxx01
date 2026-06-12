import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_schedule_guard_feedback.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_schedule_feedback.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_task_schedule_feedback_snack_bar_factory.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

void main() {
  group('GanttTaskScheduleFeedbackSnackBarFactory', () {
    const factory = GanttTaskScheduleFeedbackSnackBarFactory();

    test(
      'builds a floating snackbar with feedback content and undo action',
      () {
        var undoCount = 0;

        final snackBar = factory.snackBarFor(
          activity: _activity,
          onUndo: () => undoCount++,
        );

        expect(snackBar.behavior, SnackBarBehavior.floating);
        expect(snackBar.content, isA<GanttTaskScheduleFeedback>());
        expect(snackBar.action?.label, 'Undo');

        snackBar.action?.onPressed();

        expect(undoCount, 1);
      },
    );

    test('builds a guard snackbar with feedback content and review action', () {
      var reviewCount = 0;

      final snackBar = factory.rejectedSnackBarFor(
        task: _task,
        validation: const ky.KyGanttTaskDateRangeValidation.blocked(
          'Would overlap Testing',
        ),
        onReview: () => reviewCount++,
      );

      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.content, isA<GanttTaskScheduleGuardFeedback>());
      expect(snackBar.action?.label, 'Review');

      snackBar.action?.onPressed();

      expect(reviewCount, 1);
    });
  });
}

final _task = gantt.GanttTask(
  id: 'build',
  title: 'Build',
  startDate: DateTime(2026, 6, 11),
  endDate: DateTime(2026, 6, 18),
);

final _activity = gantt.GanttTaskEditActivity(
  taskId: 'build',
  taskTitle: 'Build',
  kind: gantt.GanttTaskEditKind.endDate,
  label: 'Finish resized +2d',
  timestamp: DateTime(2026, 6, 11),
);
