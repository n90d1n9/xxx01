import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_task_context_label_service.dart';
import 'package:ky_gantt/ky_gantt.dart';

void main() {
  test('gantt task context labels summarize task metadata', () {
    final task = GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 1, 14),
      progress: 0.42,
    );

    expect(ganttTaskProgressContextLabel(task), '42% complete');
    expect(ganttTaskScheduleContextLabel(task), 'Jan 1-14 / 2w');
    expect(ganttTaskDependencyContextLabel('Design'), 'After Design');
    expect(
      ganttTaskScheduleStatusContextLabel(task, today: DateTime(2026, 1, 6)),
      'In progress',
    );
  });

  test('gantt task context labels summarize milestones', () {
    final milestone = GanttTask(
      id: 'launch',
      title: 'Launch',
      startDate: DateTime(2026, 1, 30),
      endDate: DateTime(2026, 1, 30),
      kind: GanttTaskKind.milestone,
    );

    expect(ganttTaskScheduleContextLabel(milestone), 'Milestone Jan 30');
  });
}
