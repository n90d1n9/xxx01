import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/gantt_dashboard.dart'
    as gantt;
import 'package:kaysir/features/project_management/project/models/project_portfolio_item.dart';
import 'package:kaysir/features/project_management/project/services/project_attention_service.dart';

void main() {
  test('project attention insights prioritize blockers and overdue work', () {
    final insights = buildProjectAttentionInsights(
      project: _project(
        health: ProjectHealth.blocked,
        budgetUsed: 0.42,
        progress: 0.3,
        risks: const [
          ProjectDeliveryRisk(
            title: 'API contract drift',
            detail: 'Payload contract is not signed.',
            severity: ProjectHealth.blocked,
          ),
        ],
      ),
      timelineTasks: [
        _task(start: DateTime(2026, 5, 1), end: DateTime(2026, 5, 20)),
      ],
      today: DateTime(2026, 5, 31),
    );

    expect(insights.first.title, 'Unblock delivery path');
    expect(insights.first.detail, contains('API contract drift'));
    expect(
      insights.map((insight) => insight.title),
      contains('Recover overdue timeline'),
    );
    expect(insights.first.level, ProjectAttentionLevel.critical);
  });

  test('project attention insights keep healthy projects actionable', () {
    final insights = buildProjectAttentionInsights(
      project: _project(
        milestones: [
          ProjectMilestone(
            label: 'Pilot',
            dueDate: DateTime(2026, 6, 15),
            isComplete: false,
          ),
        ],
      ),
      timelineTasks: [
        _task(start: DateTime(2026, 5, 28), end: DateTime(2026, 6, 5)),
      ],
      today: DateTime(2026, 5, 31),
    );

    expect(
      insights.map((insight) => insight.title),
      containsAll([
        'Protect active work',
        'Next milestone',
        'Delivery rhythm is steady',
      ]),
    );
    expect(
      insights
          .singleWhere((insight) => insight.title == 'Next milestone')
          .detail,
      'Pilot is due Jun 15.',
    );
  });
}

ProjectPortfolioItem _project({
  ProjectHealth health = ProjectHealth.onTrack,
  double progress = 0.45,
  double budgetUsed = 0.38,
  List<ProjectDeliveryRisk> risks = const [],
  List<ProjectMilestone>? milestones,
}) {
  return ProjectPortfolioItem(
    id: 'project',
    name: 'Project',
    owner: 'Owner',
    client: 'Client',
    startDate: DateTime(2026, 5, 1),
    endDate: DateTime(2026, 7, 1),
    progress: progress,
    budgetUsed: budgetUsed,
    health: health,
    risks: risks,
    milestones:
        milestones ??
        [
          ProjectMilestone(
            label: 'Release',
            dueDate: DateTime(2026, 6, 10),
            isComplete: false,
          ),
        ],
  );
}

gantt.GanttTask _task({required DateTime start, required DateTime end}) {
  return gantt.GanttTask(
    id: 'task',
    title: 'Implementation',
    startDate: start,
    endDate: end,
    progress: 0.4,
  );
}
