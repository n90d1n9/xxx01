import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_schedule_feedback_presentation_service.dart';

void main() {
  group('GanttTaskScheduleFeedbackPresentationService', () {
    const service = GanttTaskScheduleFeedbackPresentationService();

    test('builds schedule feedback presentation for date edits', () {
      final presentation = service.presentationFor(
        _activity(kind: gantt.GanttTaskEditKind.endDate),
      );

      expect(presentation.icon, Icons.event_available_outlined);
      expect(presentation.title, 'Schedule Updated');
      expect(presentation.details, 'Finish resized +2d - Build');
    });

    test('maps non-schedule edit kinds to focused feedback titles', () {
      expect(
        service
            .presentationFor(_activity(kind: gantt.GanttTaskEditKind.progress))
            .title,
        'Progress Updated',
      );
      expect(
        service
            .presentationFor(
              _activity(kind: gantt.GanttTaskEditKind.dependency),
            )
            .title,
        'Dependency Updated',
      );
      expect(
        service
            .presentationFor(_activity(kind: gantt.GanttTaskEditKind.undo))
            .title,
        'Edit Reverted',
      );
    });
  });
}

gantt.GanttTaskEditActivity _activity({required gantt.GanttTaskEditKind kind}) {
  return gantt.GanttTaskEditActivity(
    taskId: 'build',
    taskTitle: 'Build',
    kind: kind,
    label: 'Finish resized +2d',
    timestamp: DateTime(2026, 6, 11),
  );
}
