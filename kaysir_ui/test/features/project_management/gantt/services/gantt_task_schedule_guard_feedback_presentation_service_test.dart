import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_schedule_guard_feedback_presentation_service.dart';
import 'package:ky_gantt/ky_gantt.dart' as ky;

void main() {
  group('GanttTaskScheduleGuardFeedbackPresentationService', () {
    const service = GanttTaskScheduleGuardFeedbackPresentationService();

    test('builds blocking guard feedback from validation messages', () {
      final presentation = service.presentationFor(
        task: _task,
        validation: const ky.KyGanttTaskDateRangeValidation.blocked(
          'Would overlap Testing',
        ),
      );

      expect(presentation.icon, Icons.verified_user_outlined);
      expect(presentation.title, 'Schedule Guard');
      expect(presentation.details, 'Would overlap Testing - Build');
    });

    test('falls back when validation has no message', () {
      final presentation = service.presentationFor(
        task: _task,
        validation: const ky.KyGanttTaskDateRangeValidation(
          severity: ky.KyGanttTaskDateRangeValidationSeverity.error,
          canCommit: false,
        ),
      );

      expect(presentation.title, 'Schedule Guard');
      expect(presentation.details, 'Date change needs review - Build');
    });
  });
}

final _task = gantt.GanttTask(
  id: 'build',
  title: 'Build',
  startDate: DateTime(2026, 6, 11),
  endDate: DateTime(2026, 6, 18),
);
