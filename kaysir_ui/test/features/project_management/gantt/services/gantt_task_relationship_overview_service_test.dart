import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/gantt/services/gantt_task_relationship_overview_service.dart';

void main() {
  const service = GanttTaskRelationshipOverviewService();

  test('builds compact relationship overview signals', () {
    final planning = gantt.GanttTask(
      id: 'planning',
      title: 'Planning',
      startDate: DateTime(2026, 5, 1),
      endDate: DateTime(2026, 5, 3),
      progress: 1,
    );
    final design = gantt.GanttTask(
      id: 'design',
      title: 'Design Phase',
      startDate: DateTime(2026, 5, 4),
      endDate: DateTime(2026, 5, 12),
      progress: 0.5,
      dependsOn: 'planning',
      subtasks: [
        gantt.GanttTask(
          id: 'review',
          title: 'Design Review',
          startDate: DateTime(2026, 5, 7),
          endDate: DateTime(2026, 5, 8),
          progress: 0.2,
        ),
      ],
    );
    final build = gantt.GanttTask(
      id: 'build',
      title: 'Build',
      startDate: DateTime(2026, 5, 11),
      endDate: DateTime(2026, 5, 18),
      dependsOn: 'design',
    );

    final overview = service.build(
      task: design,
      dependencyTasks: [planning, design, build],
      today: DateTime(2026, 5, 5),
    );

    expect(overview.attentionCount, 2);
    expect(overview.attentionLabel, '2 signals');
    expect(overview.headline, '2 relationship signals need review.');
    expect(overview.upstreamLabel, 'Upstream: 1');
    expect(overview.downstreamLabel, 'Downstream: 1');
    expect(overview.branchLabel, 'Branch: 2');
    expect(overview.branchDetail, contains('35% avg'));
  });

  test('builds clear overview for standalone tasks', () {
    final overview = service.build(
      task: gantt.GanttTask(
        id: 'planning',
        title: 'Planning',
        startDate: DateTime(2026, 5, 1),
        endDate: DateTime(2026, 5, 3),
      ),
      dependencyTasks: const [],
      today: DateTime(2026, 5, 1),
    );

    expect(overview.attentionCount, 0);
    expect(overview.attentionLabel, 'No signals');
    expect(overview.upstreamLabel, 'No upstream');
    expect(overview.downstreamLabel, 'No downstream');
    expect(overview.branchLabel, 'No branch');
  });
}
